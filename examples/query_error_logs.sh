#!/usr/bin/env bash

log_ids=$(
  orcanote query_blocks --repo demo-repo --input '{"description":{"q":{"kind":100,"conditions":[{"kind":4,"name":"Log","properties":[{"name":"App","op":1,"value":"Orca Note"},{"name":"Level","op":1,"value":"Error"}]}]},"page":1,"pageSize":100}}' --json | jq -r -c '.resultIds'
)

orcanote get_blocks_text --repo demo-repo --input "{\"blockIds\": $log_ids}"
