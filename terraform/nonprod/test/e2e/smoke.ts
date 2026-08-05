import { $ } from "bun";
import OpenAI from "openai";

const stack = `${import.meta.dir}/../..`;

async function output(name: string) {
  return (await $`tofu -chdir=${stack} output -raw ${name}`.text()).trim();
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
      "Mantle returned 401 — redeploy nonprod so bedrock-invoke includes bedrock-mantle:CreateInference on bedrock-inference-nonprod.",
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
