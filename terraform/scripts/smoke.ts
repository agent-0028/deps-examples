import OpenAI from "openai";
import { parseArgs, tofuOutput } from "./stack";

const { stackEnv } = parseArgs(process.argv.slice(2));

async function output(name: string) {
  return tofuOutput(stackEnv, name);
}

function isCoralError(value: unknown): value is { Output: { __type: string } } {
  return (
    typeof value === "object" &&
    value !== null &&
    "Output" in value &&
    typeof (value as { Output?: { __type?: string } }).Output?.__type === "string"
  );
}

const baseURL = await output("bedrock_inference_openai_mantle_base_url");
const apiKey = await output("bedrock_inference_api_key");
const stackModel = await output("bedrock_inference_model_id");
const model = process.env.BEDROCK_SMOKE_MODEL ?? stackModel;

console.error(`stack=${stackEnv}`);
console.error(`baseURL=${baseURL}`);
console.error(`stack model=${stackModel}; smoke model=${model}`);

const client = new OpenAI({ baseURL, apiKey });

let completion;
try {
  completion = await client.chat.completions.create({
    model,
    messages: [{ role: "user", content: "Reply with exactly: pong" }],
    max_tokens: 64,
    reasoning: { effort: "none" },
  } as OpenAI.Chat.Completions.ChatCompletionCreateParamsNonStreaming);
} catch (error) {
  if (error instanceof OpenAI.AuthenticationError) {
    throw new Error(
      `Mantle returned 401 — redeploy ${stackEnv} so bedrock-invoke includes bedrock-mantle:CreateInference.`,
      { cause: error },
    );
  }
  throw error;
}

if (isCoralError(completion)) {
  throw new Error(
    `${completion.Output.__type} — model ${model} is not supported on mantle Chat Completions at ${baseURL}. ` +
      "Check the tier map uses mantle model IDs from GET /v1/models.",
  );
}

const message = completion.choices?.[0]?.message as
  | (OpenAI.Chat.Completions.ChatCompletionMessage & { reasoning?: string })
  | undefined;
const text = message?.content ?? message?.reasoning;

if (!text) {
  console.error("Unexpected completion payload:");
  console.error(JSON.stringify(completion, null, 2));
  throw new Error("No assistant content in response");
}

console.log(text.trim());
