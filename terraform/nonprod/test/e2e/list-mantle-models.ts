import { $ } from "bun";

const stack = `${import.meta.dir}/../..`;

async function output(name: string) {
  return (await $`tofu -chdir=${stack} output -raw ${name}`.text()).trim();
}

const baseURL = process.env.OPENAI_BASE_URL ?? (await output("bedrock_inference_openai_mantle_base_url"));
const apiKey = process.env.OPENAI_API_KEY ?? (await output("bedrock_inference_api_key"));

const response = await fetch(`${baseURL}/models`, {
  headers: { Authorization: `Bearer ${apiKey}` },
});

if (!response.ok) {
  throw new Error(`GET ${baseURL}/models failed: ${response.status} ${await response.text()}`);
}

const body = (await response.json()) as { data: { id: string }[] };

for (const model of body.data.toSorted((a, b) => a.id.localeCompare(b.id))) {
  console.log(model.id);
}
