# Examples

These scripts demonstrate common Orca Note workflows from the command line.

Prerequisites:

- `orcanote config set-token <token>` has already been run.
- `jq` is installed.
- The target repository already has the `Log` and `File` tags defined, or you create them separately with `create_tags`.

Usage:

- `append_log_to_today.sh`
- `query_error_logs.sh`
- `insert_current_dir_links_to_today.sh [source-dir]`

Notes:

- The first script appends one Log entry to today's journal and tags it with `Level` and `App`.
- The second script queries all `Log` blocks where `App = Orca Note` and `Level = Error`.
- The third script inserts every file in the chosen folder as a Markdown link and tags each inserted block as `File` with an `Extension` property.
