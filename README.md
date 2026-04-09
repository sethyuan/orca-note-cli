# orca-note-cli

orca-note-cli is a Dart CLI wrapper around the Orca Note MCP server. The published executable name is `orcanote`.

## Configuration

Orca Note MCP uses Streamable HTTP with a Bearer token.

Configure the token once:

```sh
orcanote config set-token <token>
```

The token is stored in:

```text
~/.config/orcanote/config.json
```

On Windows the CLI falls back to `APPDATA\orcanote\config.json`.

## Usage

Each MCP tool is exposed as its own subcommand:

```sh
orcanote <tool-name> --repo <repoId> --input '<json object>' [--json]
```

- `--repo` or `-r`: repository ID, mapped to the MCP argument `repoId`
- `--input`: JSON object string with the rest of the tool arguments
- `--json`: print the raw JSON payload instead of formatted text

Examples:

```sh
orcanote get_today_journal --repo my-repo
orcanote get_blocks_text --repo my-repo --input '{"blockIds":[12345]}'
orcanote query_blocks --repo my-repo --input '{"description":{"q":{"kind":100,"conditions":[{"kind":8,"text":"deadline"}]}}}' --json
```

## Help

Show root help and the available tools:

```sh
orcanote --help
```

Show detailed help for a specific tool:

```sh
orcanote get_blocks_text --help
orcanote query_blocks --help
```

## Available Tools

- `get_tags_and_pages`
- `get_page`
- `get_blocks_text`
- `get_today_journal`
- `query_blocks`
- `insert_markdown`
- `move_blocks`
- `create_page`
- `delete_blocks`
- `insert_tags`
- `remove_tags`
- `create_tags`

## Orca Note

Click here to visit [Orca Note](https://github.com/sethyuan/orca-note)
