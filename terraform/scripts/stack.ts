import { $ } from "bun";
import { join } from "path";

export const STACK_ENVS = ["nonprod", "prod"] as const;
export type StackEnv = (typeof STACK_ENVS)[number];

function stackEnvFromProcessEnv(): StackEnv | null {
  const value = process.env.DEPS_STACK;
  if (value === "nonprod" || value === "prod") {
    return value;
  }
  return null;
}

export function parseArgs(argv: string[]): { stackEnv: StackEnv; flags: string[] } {
  let stackEnv: StackEnv = stackEnvFromProcessEnv() ?? "nonprod";
  const flags: string[] = [];

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--env") {
      const value = argv[++i];
      if (!value || !STACK_ENVS.includes(value as StackEnv)) {
        throw new Error(`--env requires one of: ${STACK_ENVS.join(", ")}`);
      }
      stackEnv = value as StackEnv;
      continue;
    }
    flags.push(arg);
  }

  return { stackEnv, flags };
}

export function stackDir(stackEnv: StackEnv): string {
  return join(import.meta.dir, "..", stackEnv);
}

export async function tofuOutput(stackEnv: StackEnv, name: string): Promise<string> {
  const stack = stackDir(stackEnv);
  return (await $`tofu -chdir=${stack} output -raw ${name}`.text()).trim();
}
