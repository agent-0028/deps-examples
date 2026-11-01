import { logLocalAwsAuth, resolveLocalAwsAuth, resolveRegion } from "./auth";
import { parseArgs } from "./stack";

const { stackEnv } = parseArgs(process.argv.slice(2));
const region = await resolveRegion(stackEnv);
const auth = await resolveLocalAwsAuth(region);

logLocalAwsAuth(auth);

const response = await auth.aws.fetch(`${auth.mantleBaseUrl}/models`);

if (!response.ok) {
  throw new Error(`GET ${auth.mantleBaseUrl}/models failed: ${response.status} ${await response.text()}`);
}

const body = (await response.json()) as { data: { id: string }[] };

for (const model of body.data.toSorted((a, b) => a.id.localeCompare(b.id))) {
  console.log(model.id);
}
