# CLI internals & conventions (read before adding a tool)

Findings from reading the repo for the `invoke_commands` wrapper task. All paths under
`/Users/sethyuan/dev/orca-note-cli`.

## Toolchain

- Dart is **not** on `PATH` in this shell; the SDK lives at `~/dev/flutter/bin/dart`
  (`Dart SDK 3.12.1`). `pubspec.yaml` pins `sdk: ^3.11.3`, CI installs 3.11.3.
- `dart run bin/orcanote.dart <tool> --help` works fully offline (help is local, no MCP call),
  which makes `--help` the natural place for long reference docs.
- `orcanote help <tool>` also works (args `2.7.0` ships a `help` command) and prints the same
  text as `<tool> --help`; the `usage` getter already includes `metadata.sections`.
- `dart analyze` uses `package:lints/recommended.yaml`. No `test/` directory, no `test`
  dev-dependency, no test job in `.github/workflows/build.yml` (workflow only compiles the
  four platform binaries and publishes a GitHub release on `v*` tags).

## How a tool is wired (exact pattern)

1. `lib/src/tools/<tool_name>.dart` — `OrcaToolCommand createXxxCommand(OrcaNoteCommandContext context)`
   returning `OrcaToolCommand(context: context, metadata: const ToolMetadata(...))`.
2. `lib/src/tools/tool_registry.dart` — import + append to `createToolCommands()`.
3. `ToolMetadata`: `name`, `title`, `summary` (→ `Command.description`), `description` (→ `usage`),
   `fields` (`ToolFieldMetadata`, `providedByRepoFlag: true` on `repoId` makes `--repo` required),
   `requiredFields`, `examples`, `sections` (`ToolSectionMetadata` = title + free-form body).
4. `OrcaToolCommand` (`lib/src/tool_command.dart`) implements everything else: flags
   `--repo/-r`, `--input`, `--json`, `--help`; required/unknown field validation against
   metadata; `parseJsonObject(--input)`; `context.mcpClient.callTool(name, fullArguments)`;
   `decodeToolPayload(result)`; rendering; exit codes.

### `OrcaToolCommand.run()` flow / where an extension point is needed

```
help -> --repo checks -> parseJsonObject(--input)
     -> reject repoId inside --input -> unknown-field check -> missing-field check
     -> mcpClient.callTool -> decodeToolPayload
     -> render: --json ? formatJson : (name == 'get_blocks_text' ? formatBlockText : formatText)
     -> write to stdout (stderr + usage if result.isError) -> 0 / 1 / 64
```

### Extension points (implemented for `invoke_commands`)

`OrcaToolCommand` now exposes three overridable hooks, so a bespoke tool no longer
needs to fork `run()`:

| hook | default | used for |
| --- | --- | --- |
| `normalizeArguments(Map)` | identity | reshape / pre-validate `--input` before the generic field checks; throw `UsageException` to reject |
| `renderText(payload)` | old ternary (`get_blocks_text` → `formatBlockText`, else `formatText`) | per tool human readable output; `--json` bypasses it |
| `exitCodeFor({payload, isError})` | `isError ? 1 : 0` | tools whose failure is visible only in the payload (`invoke_commands`: `success == false`) |

Two details worth remembering when touching this code:

- the `UsageException` catch in `run()` prints `error.usage`, not `this.usage`, so a tool
  can throw a short usage instead of the full (long) help. Existing tools pass
  `UsageException(msg, usage)`, so their behaviour is unchanged.
- the usage block after a tool error (`isError`) still uses the full `usage`; that is the
  pre-existing behaviour for every tool.

### Exit codes in use today

`0` ok · `1` MCP/tool error or unexpected failure · `64` `UsageException` (bad CLI usage).
`FormatException` (bad `--input` JSON) → `1`.

## Output conventions

- `--json` → `OrcaNoteOutputFormatter.formatJson(payload)` (2-space indent, raw tool payload).
- Text → `formatText`: recursive `key: value` / `- item` tree, and it **always drops the top-level
  `success` and `repoId` keys**. That is fine for the existing tools but wrong for
  `invoke_commands`, whose per-item `status`/`code`/`warnings`/counters are the payload.
- No non-ASCII characters anywhere in current output (Windows console safety). Keep it ASCII.
- `formatBlockText` is the `get_blocks_text` special case.

## Doc / metadata hygiene findings

- `README.md` → `## Available Tools` list is missing **`s3_sync`** (registered since
  commit `d7b9224`). Adding `invoke_commands` means touching that list anyway.
- `CHANGELOG.md` exists but is **git-ignored** (`.gitignore` line 4) and untracked
  (`git ls-files CHANGELOG.md` → empty); the only entry is `1.0.0`. → no changelog convention
  to follow; do not maintain it unless the boss asks.
- `lib/src/constants.dart` → `packageVersion = '1.3.0'` while `pubspec.yaml` says `1.4.0`;
  `orcanote --version` therefore prints a stale version. Pre-existing bug, unrelated to this
  task (drive-by fix only if approved).
- Version bumps are separate "chore: inc version" commits touching only `pubspec.yaml`.

## Docs live in `--help`, not in the skill

Commit `80caa1e` "feat: move skill docs to tools help so that AI can learn from its errors"
established the convention: detailed per-tool reference (input shapes, enum values, variants,
failure modes) goes into `ToolMetadata.sections` → `orcanote <tool> --help`;
`skills/orcanote-cli/SKILL.md` stays short and tells the agent to run `orcanote help <tool>`
first. Current SKILL.md is 37 lines. Any `invoke_commands` reference material should follow
that split, otherwise SKILL.md (loaded in every agent session) grows by hundreds of lines.

## Skill files that must stay in sync

- Repo copy: `/Users/sethyuan/dev/orca-note-cli/skills/orcanote-cli/SKILL.md`
- Installed copy: `/Users/sethyuan/.imboss/agent/skills/orcanote-cli/SKILL.md`
- They are byte-identical today (`diff` → no differences) and both are **regular files**
  (not symlinks), so every change needs an explicit copy; there is no build step doing it.
- `~/dev/orcanote-agent-skills/` exists but has no `orcanote-cli` skill — not a sync target
  unless told otherwise.

## Testing reality

- No `test/` directory, no `test` dev-dependency (a `test/` + `test: ^1.25.x` setup was
  approved and then **cancelled** by the boss for this task: keep the repo test-free).
- Verification is manual: `dart run bin/orcanote.dart ...` against a running Orca Note app;
  `examples/*.sh` are manual smoke scripts (they need `jq` + a repo).
- `dart analyze` clean is the enforced gate (CI runs no analysis either).
- **Proxy trap (fixed in 1.5.0):** with `HTTP_PROXY`/`HTTPS_PROXY`/`ALL_PROXY` set, Dart's
  `HttpClient` defaults to `findProxyFromEnvironment`, sent
  `POST http://localhost:18672/mcp` through the proxy and the call failed with
  `McpError 0: Error POSTing to endpoint (HTTP 502)`. `OrcaNoteMcpClient` now wraps every
  session in `HttpOverrides.runZoned` with a `findProxyFromEnvironment` that returns
  `DIRECT` for loopback hosts (`localhost`, `127.0.0.0/8`, `::1`) and delegates to
  `HttpClient.findProxyFromEnvironment` for anything else — no public API change.
  Verified by running `orcanote parse_datetime --input '{"text":"now"}' --json` in a
  shell that still exports the proxy variables.
- CI only builds; adding `dart analyze` / `dart test` steps to `build.yml` would be a
  workflow change (explicitly out of scope).
