gh run view $(gh run list --workflow=containerregistry.yml --limit 1 --json databaseId | jq .[0].databaseId)