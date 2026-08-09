import { $ } from "bun";

const stack = `${import.meta.dir}/../..`;
const showSecrets = process.argv.includes("--show-secrets");

async function output(name: string) {
  return (await $`tofu -chdir=${stack} output -raw ${name}`.text()).trim();
}

const [
  region,
  tier,
  vendor,
  mantleModelId,
  provisionModelId,
  inferenceProfileArn,
  piCommand,
  piEnv,
] = await Promise.all([
  output("bedrock_inference_region"),
  output("bedrock_inference_tier"),
  output("bedrock_inference_vendor"),
  output("bedrock_inference_model_id"),
  output("bedrock_inference_provision_model_id"),
  output("bedrock_inference_inference_profile_arn"),
  output("bedrock_inference_pi_command"),
  output("bedrock_inference_pi_env"),
]);

const apiKey = showSecrets ? await output("bedrock_inference_api_key") : null;

const authJson = {
  "amazon-bedrock": {
    type: "api_key",
    key: showSecrets ? apiKey : "<run with --show-secrets>",
    env: {
      AWS_REGION: region,
    },
  },
};

console.log("# Pi + Bedrock (from nonprod stack outputs)");
console.log(`# tier=${tier} vendor=${vendor}`);
console.log(`# mantle model_id=${mantleModelId} (OpenAI SDK smoke path)`);
console.log(`# provision_model_id=${provisionModelId} (Pi / Converse path)`);
console.log(`# inference_profile_arn=${inferenceProfileArn}`);
console.log("");

console.log("## Shell");
console.log("");
if (showSecrets) {
  console.log(piEnv);
} else {
  console.log("export AWS_BEARER_TOKEN_BEDROCK=<run with --show-secrets>");
  console.log(`export AWS_REGION=${region}`);
}
console.log("");

console.log("## Launch");
console.log("");
console.log(piCommand);
console.log("");

console.log("## auth.json (~/.pi/agent/auth.json)");
console.log("");
console.log(JSON.stringify(authJson, null, 2));
