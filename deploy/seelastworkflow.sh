gh run view $(gh run list --limit 1 --json databaseId | jq .[0].databaseId)