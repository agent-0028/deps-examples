console.error(
  "list-mantle-models uses the stack Bedrock API key (bedrock-inference-*), which cannot list models.\n" +
    "Use: bun run admin-list-mantle-models\n" +
    "That script uses your shell AWS credentials (AWS_PROFILE / default chain) with SigV4.",
);
process.exit(1);
