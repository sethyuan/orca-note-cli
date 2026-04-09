#!/usr/bin/env bash
source_dir=${1:-.}

if [[ ! -d "$source_dir" ]]; then
  echo "source directory not found: $source_dir" >&2
  exit 1
fi

source_dir=$(cd "$source_dir" && pwd)

json_escape() {
  local value=${1//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  printf '%s' "$value"
}

source_files=()
while IFS= read -r file_path; do
  source_files+=("$file_path")
done < <(
  find "$source_dir" -maxdepth 1 -type f | sort
)

if [[ ${#source_files[@]} -eq 0 ]]; then
  echo "no files found in $source_dir" >&2
  exit 0
fi

today_journal_id=$(
  orcanote get_today_journal --repo demo-repo --json | jq -r '.blockId'
)

for file_path in "${source_files[@]}"; do
  file_name=$(basename "$file_path")
  file_extension=${file_name##*.}
  if [[ "$file_name" == "$file_extension" ]]; then
    file_extension=""
  fi

  insert_input=$(cat <<JSON
{
  "refBlockId": ${today_journal_id},
  "position": "lastChild",
  "text": "[$(json_escape "$file_name")]($(json_escape "$file_path"))"
}
JSON
)

  block_id=$(
    orcanote insert_markdown --repo demo-repo --input "$insert_input" --json | jq -r '.blockId'
  )

  tag_input="{\"blockIds\":[${block_id}],\"tags\":[{\"name\":\"File\",\"props\":{\"Extension\":\"$(json_escape "$file_extension")\"}}]}"

  orcanote insert_tags --repo demo-repo --input "$tag_input" --json >/dev/null
done

echo "inserted ${#source_files[@]} file links into today's journal $today_journal_id"
