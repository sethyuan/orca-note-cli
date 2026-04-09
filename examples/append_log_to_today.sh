#!/usr/bin/env bash

today_journal_id=$(
  orcanote get_today_journal -r demo-repo --json | jq -r '.blockId'
)

insert_input="{
  \"refBlockId\": ${today_journal_id},
  \"position\": \"lastChild\",
  \"text\": \"Build completed\"
}"

inserted_id=$(
  orcanote insert_markdown -r demo-repo --input "$insert_input" --json | jq -r '.blockId'
)

tag_input="{
  \"blockIds\": [${inserted_id}],
  \"tags\": [
    {
      \"name\": \"Log\",
      \"props\": {
        \"Level\": \"Info\",
        \"App\": \"Orca Note\"
      }
    }
  ]
}"

orcanote insert_tags -r demo-repo --input "$tag_input" --json
