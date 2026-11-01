import { fromNodeProviderChain } from "@aws-sdk/credential-providers";
import { GetCallerIdentityCommand, STSClient } from "@aws-sdk/client-sts";
import { AwsClient } from "aws4fetch";
import { tofuOutput, type StackEnv } from "./stack";

/** Stack scripts use the narrow Bedrock API key Terraform created for inference. */
export type StackAuth = {
  mode: "stack";
  stackEnv: StackEnv;
  /** IAM user behind the service-specific credential (e.g. bedrock-inference-nonprod). */
  iamUser: string;
  apiKey: string;
  mantleBaseUrl: string;
};

/** Admin scripts use whatever principal your shell AWS config resolves to. */
export type LocalAwsAuth = {
  mode: "local-aws";
  region: string;
  /** e.g. AWS_PROFILE=admin or default chain */
  profile: string | undefined;
  arn: string;
  account: string;
  aws: AwsClient;
  mantleBaseUrl: string;
};

export async function resolveStackAuth(stackEnv: StackEnv): Promise<StackAuth> {
  const [mantleBaseUrl, apiKey, envSuffix] = await Promise.all([
    tofuOutput(stackEnv, "bedrock_inference_openai_mantle_base_url"),
    tofuOutput(stackEnv, "bedrock_inference_api_key"),
    tofuOutput(stackEnv, "env-suffix"),
  ]);

  return {
    mode: "stack",
    stackEnv,
    iamUser: `bedrock-inference${envSuffix}`,
    apiKey,
    mantleBaseUrl,
  };
}

export async function resolveLocalAwsAuth(region: string): Promise<LocalAwsAuth> {
  const credentials = await fromNodeProviderChain()();
  const profile = process.env.AWS_PROFILE;

  const sts = new STSClient({ region, credentials });
  const identity = await sts.send(new GetCallerIdentityCommand({}));

  if (!identity.Arn || !identity.Account) {
    throw new Error("STS GetCallerIdentity did not return Arn/Account");
  }

  const aws = new AwsClient({
    accessKeyId: credentials.accessKeyId,
    secretAccessKey: credentials.secretAccessKey,
    sessionToken: credentials.sessionToken,
    region,
    service: "bedrock-mantle",
  });

  return {
    mode: "local-aws",
    region,
    profile,
    arn: identity.Arn,
    account: identity.Account,
    aws,
    mantleBaseUrl: `https://bedrock-mantle.${region}.api.aws/v1`,
  };
}

export function logStackAuth(auth: StackAuth): void {
  console.error(`auth=stack-api-key stack=${auth.stackEnv} iam_user=${auth.iamUser}`);
}

export function logLocalAwsAuth(auth: LocalAwsAuth): void {
  const profile = auth.profile ? ` profile=${auth.profile}` : "";
  console.error(`auth=local-aws${profile} region=${auth.region} principal=${auth.arn}`);
}

export async function resolveRegion(stackEnv: StackEnv): Promise<string> {
  return (
    process.env.AWS_REGION ??
    process.env.AWS_DEFAULT_REGION ??
    (await tofuOutput(stackEnv, "bedrock_inference_region"))
  );
}
