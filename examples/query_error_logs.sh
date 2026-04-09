#!/usr/bin/env bash

orcanote query_blocks --repo demo-repo --input '{"description":{"q":{"kind":100,"conditions":[{"kind":4,"name":"Log","properties":[{"name":"App","op":1,"value":"Orca Note"},{"name":"Level","op":1,"value":"Error"}]}]},"page":1,"pageSize":100}}' --json
