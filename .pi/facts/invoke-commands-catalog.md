# `invoke_commands` — desktop contract + command catalogue

Source of truth for the desktop side: `/Users/sethyuan/dev/orca-note/.pi/facts/mcp-invoke-commands.md`
(authoritative, with file/line references). This file records what the **CLI wrapper** needs from it,
plus the command catalogue the skill/help text will expose.

ALL of the below was read from `/Users/sethyuan/dev/orca-note` on 2026-11-03.

## 1. Tool contract

- Registered **only** for requests authenticating with the user's custom token
  (`req.isCustomToken`); the built-in default token (`orca-note-mcp`) does not see it. The CLI
  always uses the configured custom token (``orcanote config set-token``), so it can call it.
- Input:
  - `repoId: string` (required) — the repo must have an **open window**; the tool never opens one.
  - `commands: [{ id: string, args: string | null }]` — 1..20 items. `args` is a
    **JSON-encoded array string** (`null`/`""` = no args), ≤20000 chars per item,
    ≤256KB for the whole payload. A native array is rejected by the Zod schema.
  - `panelId?: string` — target panel inside that window; omitted = the window's active panel.
    A wrong `panelId` is an error (`panel_not_found`) in `invoke_commands` (it does not fall back).
  - `undoable?: boolean` — default **false** (changes are not added to the window's undo history).
  - `focus?: boolean` — default **false**; `true` raises + focuses the window and waits 150ms.
- Target window: the repo's **focused** window, else its first window; PDF/PNG export windows are
  skipped. `windowSelection: "focused" | "first"` reports which was used.
- Commands run sequentially in the renderer with a 200ms pause after each (`COMMAND_INTERVAL`).
  Requests to the same window are serialized (per-window queue).
- Timeout: **15s** for the whole round trip (`DefaultInvokeCommandsTimeout`). A single slow command
  (e.g. `core.rebuildIndex`) can time out while the renderer keeps working.
- Deny list (the only blocked ids): `core.quitApp`, `core.closeWindow`, `core.checkForUpdates`.

### Success payload (single text content item, JSON)

```json
{
  "success": true,
  "repoId": "my-repo",
  "windowId": 8388652,
  "windowSelection": "focused",
  "panelId": null,
  "undoable": false,
  "results": [
    { "id": "core.editor.toggleTaskState", "status": "ok" },
    { "id": "core.editor.formatBold", "status": "skipped", "code": "editor_not_focused",
      "error": "The panel editor does not have focus, so this command would do nothing" },
    { "id": "core.editor.nope", "status": "error", "code": "unknown_command",
      "error": "No command named \"core.editor.nope\"" }
  ],
  "okCount": 1,
  "failedCount": 1,
  "skippedCount": 1,
  "warnings": [
    "1 command(s) were skipped because the panel editor has no focus. Re-run them with focus: true."
  ]
}
```

`success` is true only when `failedCount == 0 && skippedCount == 0`.

### Top-level error payload (returned with `isError: true`)

```json
{ "success": false, "repoId": "my-repo", "error": { "code": "repo_not_open", "message": "Repository \"my-repo\" has no open window" } }
```

### Error / status codes (full set)

Per item: `invalid_command_id`, `command_denied`, `invalid_args` (not a JSON array / not valid
JSON), `args_too_long`, `unknown_command`, `panel_not_found`, `command_failed`.
Top level: `invalid_commands`, `too_many_commands`, `payload_too_large`, `unknown_repo`,
`repo_not_open`, `window_closed`, `timeout`, `invalid_result`, `send_failed`, `renderer_error`.
Per-item statuses: `ok` / `skipped` / `error`.

### Focus gate (the #1 gotcha)

`src/renderer/infra/run-commands.ts` skips an **editor** command when **all three** hold:

1. it is not registered with `noFocusNeeded: true`, and
2. it is not registered with `hasArgs: true`, and
3. the caller passed **zero** args, and the target panel's editor does not contain
   `document.activeElement`.

=> `status: "skipped"`, `code: "editor_not_focused"`, nothing changed.
Two ways out: `focus: true` (steals focus from the user), or **pass an argument** — most
cursor-free editor commands accept an explicit block id (`makeHeading2`, `toggleTaskState`,
`insertTable`, …) and then never need a caret. Prefer the argument.

## 2. Catalogue — curated groups (proposed for `--help` + skill)

"no caret" = works without `focus: true` **when you pass the listed args**.
"needs caret/selection" = arg-less, operates on the live selection → needs `focus: true`.

### Block type & structure (all take a block id, no caret)
| id | args | note |
| --- | --- | --- |
| `core.editor.makeHeading1` … `makeHeading4` | `[blockId]` | also `makeHeadingAuto`, `makeText` |
| `core.editor.makeBulletedList` | `[blockId]` | `makeNumberedList` takes `[blockId, start?]` |
| `core.editor.makeQuote`, `makeMath`, `makeColumns`, `makeTabsH`, `makeTabsV`, `makeGallery`, `makeKanban`, `makeTimeline` | `[blockId]` | these 8 are `noFocusNeeded` |
| `core.editor.insertTable`, `insertQuery`, `insertCode`, `insertQuote`, `insertHR`, `insertImage`, `insertMermaid`, `insertSpreadsheet`, `insertWhiteboard`, `insertAudio`, `insertVideo`, `insertPDF`, `insertEPUB`, `insertGallery`, `insertKanban`, `insertTabsH/V`, `insertColumns`, `insertTimeline`, `insertDate` | `[blockId]` | converts the given block if empty, else inserts a sibling **after** it; arg bypasses the focus gate |
| `core.editor.toggleTask`, `toggleTaskState` | `[blockId]` | `toggleTaskState` only acts on `task` repr |
| `core.editor.toggleFavorite`, `toggleFold`, `foldBlock`, `unfoldBlock`, `toggleShowAsLongForm`, `toggleAsTemplate` | `[blockId]` | |
| `core.editor.foldAll`, `unfoldAll` | `[]` | whole panel |
| `core.editor.deleteBlocks` | `[blockIds]` | real deletion, no panel/caret needed |
| `core.editor.collapseEmptyBlock` | `[blockId, "promote"\|"absorb"]` | |
| `core.editor.indentSelection`, `outdentSelection` | `[ids]` | explicit ids, no caret |
| `core.editor.moveBlockUp`, `moveBlockDown` | `[ids]` | explicit ids, no caret |

### Properties / content (advanced)
| id | args | note |
| --- | --- | --- |
| `core.editor.setProperties` | `[blockIds, [{name, type, value}]]` or `[[{blockId, properties}]]` | `type` is the `PropType` number: 0 JSON, 1 Text, 2 BlockRefs, 3 Number, 4 Boolean, 5 DateTime, 6 TextChoices, 7 Computed. `_repr` (JSON) = block type, e.g. `{"type":"heading","level":2}` |
| `core.editor.deleteProperties` | `[blockIds, [propertyNames]]` | |
| `core.editor.setBlocksContent` | `[[{id, content}], setBackCursor?]` | content = `ContentFragment[]` (`[{"t":"t","v":"text"}]`); `null` clears |
| `core.editor.insertTag` | `[blockId, alias, data?]` | arg present → no caret needed |
| `core.editor.removeTag` | `[blockId, alias]` | |
| `core.editor.batchInsertTags` | `[blockIds, tags]` | `tags: (string \| {name, props})[]`, same shape as the `insert_tags` tool |

### Tags / aliases / refs management
| id | args | note |
| --- | --- | --- |
| `core.duplicateTag` | `[tagBlockId, newName?]` | |
| `core.editor.createAlias` | `[name, blockId, asPage?, pos?]` | |
| `core.editor.renameAlias` | `[oldName, newName]` | |
| `core.editor.deleteAlias` | `[name]` | |
| `core.editor.changeTagPropertyName` | `[[tagBlockIds], oldName, newName]` | |
| `core.editor.migrateTagInstances` | `[sourceTagId, targetTagName]` | |
| `core.editor.removeAllInstances` | `[tagBlockId]` | destructive |
| `core.editor.createRef` | `[fromId, toId, type, alias?]` | `type` = ref type number (see orca-note `.pi/facts/ref-type-system.md`) |
| `core.editor.setRefData`, `setRefAlias` | `[ref, data]` / `[ref, alias]` | `ref` is a `BlockRef` object |
| `core.editor.deleteRef` | `[{refId}]` | object, not a bare id |

### App / navigation (no editor needed)
`core.openTodayInPanel`, `core.goToday`, `core.goTomorrow`/`core.goYesterday` `[openAside?]`,
`core.openSearch`, `core.openSettings`, `core.openCommandPalette`, `core.openSidebar`/`toggleSidebar`,
`core.switchToNextPanel`/`switchToPreviousPanel`, `core.closePanel`, `core.panel.toggleMaximize`/`toggleWideView`/`toggleLock` `[panelId?]`, `core.goBack`/`goForward`, `core.toggleThemeMode`, `core.notify` `[type, message, title?, actionCommand?]`, `core.rebuildIndex`, `core.assets.cleanUnused`, `core.s3.sync` `[interruptive?, initial?, followMouse?]` (prefer the `s3_sync` tool — `followMouse` defaults true and shows UI).

### Needs a caret / live selection (`focus: true`)
All `core.editor.format*` (`formatBold`, `formatItalic`, `formatInlineCode`, `formatHighlight*`,
`formatText*`, `formatUnderline*`, `formatSub`/`formatSup`, `clearFormatting`,
`formatSelectedText [formatType, formatArgs?]`, font size ones), `insertFragments`,
`insertLink`, `splitBlock`, `mergeFollowingBlock`, `mergePrecedingBlock`, `mergeBlocks`,
`deleteSelection`, `deleteBlocksInSelection`, `selectAll`, `goTop`/`goBottom`, `undo`/`redo`,
`showBlockMenu`, `showTagInsertion`, `showAliasEditor`, `toggleFindReplace`, `toggleTOC`,
`openBlockInNewWindow`, `openOnTheSide`, `openBlockGraph*`, `export.*`
(fire-and-forget: they open windows/menus or touch the clipboard — avoid the `copy.*`/`paste*`
families, they only mutate the clipboard, and `export.*` opens an export window).

### Deliberately NOT recommended
`core.editor.insertBlock`, `batchInsertText`, `batchInsertHTML`, `batchInsertReprs`,
`copyBlocks`, `moveBlocks`, `crossRepoCopyBlocks` — they take a **`Block` object**
(`{id, parent, left, children}`), i.e. a snapshot of `orca.state.blocks[id]`; passing a bare id
silently does nothing useful. The CLI tools `insert_markdown` / `move_blocks` / `create_page`
already do these jobs properly.

## 3. Regeneration recipe (run inside `/Users/sethyuan/dev/orca-note`)

Command ids only exist in the renderer registry; the app deliberately exposes no list tool.
To refresh the tables below after an orca-note update:

```sh
grep -rhno '"core\.[^"]*"' src/renderer/core/commands | sed 's/.*"\(core\.[^"]*\)".*/\1/' | sort -u
```

and the argument signatures: search `registerEditorCommand(` / `registerCommand(` in
`src/renderer/core/commands/**/*.ts`; the first positional parameter group
(`[panelId, rootBlockId, cursor, isRedo]`, `[panelId]`, `_`) is injected by the renderer.
The table below was produced with a one-off Python pass doing exactly that.

## 4. Full registry dump (orca-note @ 2026-11-03) — do NOT paste this into SKILL.md

### Editor commands (`registerEditorCommand`) — 164 registered IDs

`ext args` = the positional args a caller passes; the leading context args (`[panelId, rootBlockId, cursor, isRedo]`, `[panelId]`, `_`) are injected by the renderer and must NOT be passed.

`noFocus` = registered with `noFocusNeeded: true` (focus gate never applies). `hasArgs` = registered with `hasArgs: true` (the caller always has to pass args).

| command id | ext args | hasArgs | noFocus | file |
| --- | --- | --- | --- | --- |
| `core.ai.batchInsert` | [, , , isRedo], redoArgs: any[], undoArgs: any, updatedIds: DbId[] | y |  | ai.ts |
| `core.ai.batchInsertText` | [, , , isRedo], redoArgs: any[], undoArgs: any, updatedIds: DbId[] | y |  | ai.ts |
| `core.ai.openChatAside` | id?: DbId |  |  | ai.ts |
| `core.duplicateTag` | tagBlockId: DbId, newName?: string | y |  | creation.ts |
| `core.editor.appendBlockAfterCursor` | id?: DbId, forceAfter: boolean = false |  |  | creation.ts |
| `core.editor.batchInsertHTML` | refBlock: Block, position: "before" | "after" | "firstChild" | "lastChild", html: string | y |  | foundation.ts |
| `core.editor.batchInsertReprs` | refBlock: Block, position: "before" | "after" | "firstChild" | "lastChild", reprs: Repr[] | y |  | foundation.ts |
| `core.editor.batchInsertTags` | blockIds: DbId[], tags: TagInput[] | y |  | creation.ts |
| `core.editor.batchInsertText` | refBlock: Block, position: "before" | "after" | "firstChild" | "lastChild", text: string, skipMarkdown: boolean = false, skipTags: boolean = false | y |  | foundation.ts |
| `core.editor.changeTagPropertyName` | tagBlockId: DbId[], oldName: string, newName: string | y |  | foundation.ts |
| `core.editor.clearFormatting` | - |  |  | text.ts |
| `core.editor.collapseEmptyBlock` | blockId: DbId, mode: "promote" | "absorb" | y |  | merge-split.ts |
| `core.editor.convertSelectionIntoLink` | - |  |  | text.ts |
| `core.editor.convertSelectionIntoMath` | - |  |  | text.ts |
| `core.editor.convertSelectionIntoReference` | - |  |  | text.ts |
| `core.editor.copy.md` | idOrIds?: DbId | DbId[] |  |  | misc.ts |
| `core.editor.copyBlockID` | id?: DbId |  |  | misc.ts |
| `core.editor.copyBlockLink` | id?: DbId |  |  | misc.ts |
| `core.editor.copyBlocks` | blockIds: DbId[], refBlockId: DbId | null, position: "before" | "after" | "firstChild" | "lastChild" | null, processVars: boolean = false, replaceEmpty: boolean = false |  |  | foundation.ts |
| `core.editor.copyFormatting` | - |  |  | text.ts |
| `core.editor.createAlias` | name: string, blockId: DbId, asPage?: boolean, pos?: number | y |  | foundation.ts |
| `core.editor.createRef` | from: DbId, to: DbId, type: number, alias?: string | y |  | foundation.ts |
| `core.editor.crossRepoCopyBlocks` | sourceRepoId: string, blockIds: DbId[], refBlockId: DbId | null, position: "before" | "after" | "firstChild" | "lastChild" | null | y |  | foundation.ts |
| `core.editor.deleteAlias` | name: string | y |  | foundation.ts |
| `core.editor.deleteBlocks` | blockIds: DbId[] | y |  | foundation.ts |
| `core.editor.deleteBlocksInSelection` | - | y |  | deletion.ts |
| `core.editor.deleteProperties` | blockIds: DbId[], propertyNames: string[] | y |  | foundation.ts |
| `core.editor.deleteRef` | { refId }: { refId: DbId } | y |  | foundation.ts |
| `core.editor.deleteRefData` | refId: DbId, names: string[] | y |  | foundation.ts |
| `core.editor.deleteSelection` | domDelete: boolean = false, text?: string | y |  | deletion.ts |
| `core.editor.export.html` | id?: DbId |  |  | misc.ts |
| `core.editor.export.md` | id?: DbId |  |  | misc.ts |
| `core.editor.export.pdf` | id?: DbId, landscape: boolean = false |  |  | misc.ts |
| `core.editor.export.png` | id?: DbId |  |  | misc.ts |
| `core.editor.export.txt` | id?: DbId |  |  | misc.ts |
| `core.editor.extractPage` | id?: DbId |  |  | misc.ts |
| `core.editor.focusIn` | id?: DbId |  |  | misc.ts |
| `core.editor.focusOut` | - |  |  | misc.ts |
| `core.editor.foldAll` | - |  |  | misc.ts |
| `core.editor.foldBlock` | id?: DbId |  |  | misc.ts |
| `core.editor.formatBold` | - |  |  | text.ts |
| `core.editor.formatDecreaseFontSize` | - |  |  | text.ts |
| `core.editor.formatHighlightBlue` | - |  |  | text.ts |
| `core.editor.formatHighlightCustomColor` | color?: string |  |  | text.ts |
| `core.editor.formatHighlightGreen` | - |  |  | text.ts |
| `core.editor.formatHighlightRed` | - |  |  | text.ts |
| `core.editor.formatHighlightYellow` | - |  |  | text.ts |
| `core.editor.formatIncreaseFontSize` | - |  |  | text.ts |
| `core.editor.formatInlineCode` | - |  |  | text.ts |
| `core.editor.formatItalic` | - |  |  | text.ts |
| `core.editor.formatResetFontSize` | - |  |  | text.ts |
| `core.editor.formatSelectedText` | formatType: string, formatArgs: Record<string, any> = {} |  |  | text.ts |
| `core.editor.formatStrikethrough` | - |  |  | text.ts |
| `core.editor.formatSub` | - |  |  | text.ts |
| `core.editor.formatSup` | - |  |  | text.ts |
| `core.editor.formatTextBlue` | - |  |  | text.ts |
| `core.editor.formatTextCustomColor` | color?: string |  |  | text.ts |
| `core.editor.formatTextGreen` | - |  |  | text.ts |
| `core.editor.formatTextRed` | - |  |  | text.ts |
| `core.editor.formatUnderlineCustomColor` | color?: string |  |  | text.ts |
| `core.editor.formatUnderlineSolid` | - |  |  | text.ts |
| `core.editor.formatUnderlineWavy` | - |  |  | text.ts |
| `core.editor.formatUnderlineWavyBlue` | - |  |  | text.ts |
| `core.editor.formatUnderlineWavyCustomColor` | color?: string |  |  | text.ts |
| `core.editor.formatUnderlineWavyGreen` | - |  |  | text.ts |
| `core.editor.formatUnderlineWavyRed` | - |  |  | text.ts |
| `core.editor.importMarkdown` | id?: DbId |  |  | creation.ts |
| `core.editor.indentSelection` | ids?: DbId[] |  |  | indent-outdent.ts |
| `core.editor.inlinePage` | id?: DbId |  |  | misc.ts |
| `core.editor.insertAudio` | id?: DbId |  |  | creation.ts |
| `core.editor.insertBlock` | refBlock: Block | null, position: "before" | "after" | "firstChild" | "lastChild" | null, content?: ContentFragment[], repr: Repr = { type: "text" }, created?: Date, modified?: Date | y |  | foundation.ts |
| `core.editor.insertBlockBeforeCursor` | moveCursor: boolean = true, id?: DbId |  |  | creation.ts |
| `core.editor.insertCode` | id?: DbId |  |  | creation.ts |
| `core.editor.insertColumns` | id?: DbId |  |  | creation.ts |
| `core.editor.insertCurrentTime` | - |  |  | misc.ts |
| `core.editor.insertDate` | id?: DbId |  |  | creation.ts |
| `core.editor.insertEPUB` | id?: DbId |  |  | creation.ts |
| `core.editor.insertFragments` | fragments: ContentFragment[], forceFormat: boolean = false |  |  | text.ts |
| `core.editor.insertGallery` | id?: DbId |  |  | creation.ts |
| `core.editor.insertHR` | id?: DbId |  |  | creation.ts |
| `core.editor.insertImage` | id?: DbId |  |  | creation.ts |
| `core.editor.insertInlineMath` | - |  |  | creation.ts |
| `core.editor.insertKanban` | id?: DbId |  |  | creation.ts |
| `core.editor.insertLink` | isRef: boolean, link: DbId | string, text?: string | y |  | creation.ts |
| `core.editor.insertMath` | id?: DbId |  |  | creation.ts |
| `core.editor.insertMediaTimestamp` | - |  |  | creation.ts |
| `core.editor.insertMermaid` | id?: DbId |  |  | creation.ts |
| `core.editor.insertPDF` | id?: DbId |  |  | creation.ts |
| `core.editor.insertParent` | ids?: DbId[] |  |  | creation.ts |
| `core.editor.insertQuery` | id?: DbId |  |  | creation.ts |
| `core.editor.insertQuote` | id?: DbId |  |  | creation.ts |
| `core.editor.insertSpreadsheet` | id?: DbId |  |  | creation.ts |
| `core.editor.insertTable` | id?: DbId |  |  | creation.ts |
| `core.editor.insertTabsH` | id?: DbId |  |  | creation.ts |
| `core.editor.insertTabsV` | id?: DbId |  |  | creation.ts |
| `core.editor.insertTag` | blockId: DbId, alias: string, data?: BlockRefData[] |  |  | creation.ts |
| `core.editor.insertTimeline` | id?: DbId |  |  | creation.ts |
| `core.editor.insertVideo` | id?: DbId |  |  | creation.ts |
| `core.editor.insertWhiteboard` | id?: DbId |  |  | creation.ts |
| `core.editor.makeAliased` | id?: DbId |  | y | text.ts |
| `core.editor.makeBulletedList` | id?: DbId |  | y | text.ts |
| `core.editor.makeColumns` | id?: DbId |  | y | text.ts |
| `core.editor.makeGallery` | id?: DbId |  | y | text.ts |
| `core.editor.makeHeading1` | id?: DbId |  | y | text.ts |
| `core.editor.makeHeading2` | id?: DbId |  | y | text.ts |
| `core.editor.makeHeading3` | id?: DbId |  | y | text.ts |
| `core.editor.makeHeading4` | id?: DbId |  | y | text.ts |
| `core.editor.makeHeadingAuto` | id?: DbId |  | y | text.ts |
| `core.editor.makeInlineReference` | id?: DbId |  |  | misc.ts |
| `core.editor.makeKanban` | id?: DbId |  | y | text.ts |
| `core.editor.makeMath` | id?: DbId |  | y | text.ts |
| `core.editor.makeMirror` | id?: DbId |  |  | misc.ts |
| `core.editor.makeNumberedList` | id?: DbId, start?: number |  | y | text.ts |
| `core.editor.makeQuote` | id?: DbId |  | y | text.ts |
| `core.editor.makeTabsH` | id?: DbId |  | y | text.ts |
| `core.editor.makeTabsV` | id?: DbId |  | y | text.ts |
| `core.editor.makeText` | id?: DbId |  |  | text.ts |
| `core.editor.makeTimeline` | id?: DbId |  | y | text.ts |
| `core.editor.mergeBlocks` | srcId: DbId, destId: DbId, srcContent?: ContentFragment[] | y |  | merge-split.ts |
| `core.editor.mergeFollowingBlock` | - |  |  | merge-split.ts |
| `core.editor.mergePrecedingBlock` | srcContent?: ContentFragment[] |  |  | merge-split.ts |
| `core.editor.migrateReferencesAndAliases` | from: DbId, to: DbId | y |  | foundation.ts |
| `core.editor.migrateTagInstances` | sourceTagId: DbId, targetTagName: string | y |  | deletion.ts |
| `core.editor.moveBlockDown` | ids?: DbId[] |  |  | misc.ts |
| `core.editor.moveBlockUp` | ids?: DbId[] |  |  | misc.ts |
| `core.editor.moveBlocks` | blockIds: DbId[], refBlockId: DbId | null, position: "before" | "after" | "firstChild" | "lastChild" | null, opts?: BlockMoveOptions |  |  | foundation.ts |
| `core.editor.newRootChild` | - |  |  | creation.ts |
| `core.editor.openBlockGraph` | id?: DbId |  |  | misc.ts |
| `core.editor.openBlockGraphAside` | id?: DbId |  |  | misc.ts |
| `core.editor.openBlockInNewWindow` | id?: DbId |  |  | misc.ts |
| `core.editor.openLastTagEditor` | - |  |  | misc.ts |
| `core.editor.openOnTheSide` | id?: DbId |  |  | misc.ts |
| `core.editor.outdentSelection` | ids?: DbId[] |  |  | indent-outdent.ts |
| `core.editor.pasteAsCopy` | - |  |  | misc.ts |
| `core.editor.pasteAsMirror` | - |  |  | misc.ts |
| `core.editor.pasteAsMove` | - |  |  | misc.ts |
| `core.editor.pasteAsReference` | - |  |  | misc.ts |
| `core.editor.pasteHTML` | - |  |  | misc.ts |
| `core.editor.pastePlainText` | - |  |  | misc.ts |
| `core.editor.pasteText` | - |  |  | misc.ts |
| `core.editor.removeAllInstances` | tagBlockId: DbId | y |  | deletion.ts |
| `core.editor.removeTag` | blockId: DbId, alias: string | y |  | deletion.ts |
| `core.editor.renameAlias` | oldName: string, newName: string | y |  | foundation.ts |
| `core.editor.selectAll` | - |  |  | text.ts |
| `core.editor.setBlocksContent` | blocksToUpdate: IdContent[], setBackCursor: boolean = false |  |  | foundation.ts |
| `core.editor.setProperties` | ...args: any[] |  |  | foundation.ts |
| `core.editor.setRefAlias` | ref: BlockRef, alias: string | y |  | foundation.ts |
| `core.editor.setRefData` | ref: BlockRef, data: BlockRefData[] | y |  | foundation.ts |
| `core.editor.showAIMenu` | - |  |  | misc.ts |
| `core.editor.showAliasEditor` | - |  |  | misc.ts |
| `core.editor.showBlockMenu` | - |  |  | misc.ts |
| `core.editor.showTagInsertion` | - |  |  | misc.ts |
| `core.editor.splitBlock` | - |  |  | merge-split.ts |
| `core.editor.toggleAsTemplate` | id?: DbId |  |  | misc.ts |
| `core.editor.toggleFavorite` | id?: DbId |  |  | misc.ts |
| `core.editor.toggleFold` | id?: DbId |  |  | misc.ts |
| `core.editor.toggleGoTo` | id?: DbId |  | y | misc.ts |
| `core.editor.toggleReadOnly` | - |  | y | misc.ts |
| `core.editor.toggleShowAsLongForm` | id?: DbId |  |  | misc.ts |
| `core.editor.toggleTask` | id?: DbId |  | y | text.ts |
| `core.editor.toggleTaskState` | id?: DbId |  |  | misc.ts |
| `core.editor.unfoldAll` | - |  |  | misc.ts |
| `core.editor.unfoldBlock` | id?: DbId |  |  | misc.ts |
| `core.panel.split` | - |  |  | misc.ts |

### Plain commands (`registerCommand`) — 55 registered IDs

| command id | args | file |
| --- | --- | --- |
| `core.assets.cleanUnused` | - | index.ts |
| `core.checkForUpdates` | - | index.ts |
| `core.closeOtherPanels` | - | index.ts |
| `core.closePanel` | - | index.ts |
| `core.closeSidebar` | - | index.ts |
| `core.closeWindow` | - | index.ts |
| `core.editor.copySelection` | - | index.ts |
| `core.editor.copySelectionForMove` | - | index.ts |
| `core.editor.createAndGoEmptyBlock` | - | index.ts |
| `core.editor.goBottom` | - | index.ts |
| `core.editor.goToCandidates` | - | index.ts |
| `core.editor.goToReferrers` | - | index.ts |
| `core.editor.goToSameKind` | - | index.ts |
| `core.editor.goTop` | - | index.ts |
| `core.editor.openAIAssistant` | - | index.ts |
| `core.editor.openMindMap` | - | index.ts |
| `core.editor.redo` | - | index.ts |
| `core.editor.side.openBlockGraph` | - | index.ts |
| `core.editor.stopAIStreaming` | - | index.ts |
| `core.editor.toggleFindReplace` | - | index.ts |
| `core.editor.toggleTOC` | - | index.ts |
| `core.editor.undo` | - | index.ts |
| `core.enableInteractivePreview` | - | index.ts |
| `core.global.quickNote` | - | index.ts |
| `core.global.toggleWindow` | - | index.ts |
| `core.goBack` | - | index.ts |
| `core.goForward` | - | index.ts |
| `core.goToday` | - | index.ts |
| `core.goTomorrow` | openAside: boolean = false | index.ts |
| `core.goYesterday` | openAside: boolean = false | index.ts |
| `core.layout._default` | - | index.ts |
| `core.notify` | type: "info" | "success" | "warn" | "error", message: string, title?: string, actionCommand?: string | index.ts |
| `core.openCommandPalette` | - | index.ts |
| `core.openPluginMarketplace` | - | index.ts |
| `core.openRepoSwitcher` | - | index.ts |
| `core.openSearch` | - | index.ts |
| `core.openSettings` | - | index.ts |
| `core.openSidebar` | - | index.ts |
| `core.openTodayInPanel` | - | index.ts |
| `core.openWebViewModal` | url?: string | index.ts |
| `core.panel.showRecents` | id?: string | index.ts |
| `core.panel.toggleLock` | id?: string | index.ts |
| `core.panel.toggleMaximize` | id?: string | index.ts |
| `core.panel.toggleWideView` | id?: string | index.ts |
| `core.quitApp` | - | index.ts |
| `core.rebuildAllBlocksIndexText` | - | index.ts |
| `core.rebuildIndex` | - | index.ts |
| `core.s3.sync` | interruptive: boolean = true, initial: boolean = false, followMouse: boolean = true | index.ts |
| `core.sidebar.goFavorites` | - | index.ts |
| `core.sidebar.goPages` | - | index.ts |
| `core.sidebar.goTags` | - | index.ts |
| `core.switchToNextPanel` | - | index.ts |
| `core.switchToPreviousPanel` | - | index.ts |
| `core.toggleSidebar` | - | index.ts |
| `core.toggleThemeMode` | - | index.ts |

## 5. CLI wrapper — what was implemented (v1.5.0)

- `lib/src/tools/invoke_commands.dart` — `InvokeCommandsCommand extends OrcaToolCommand`,
  overrides `normalizeArguments` / `renderText` / `exitCodeFor`; `--help` documents the tool
  itself only.
- `lib/src/invoke_commands_support.dart` — pure logic: `normalizeInvokeCommandsInput`
  (native `args` array or JSON-array string both accepted, native array is re-encoded to the
  JSON string the MCP schema requires; local checks for 20 items / 20000 chars per args /
  256KB payload / types), `renderInvokeCommandsText`, `invokeCommandsExitCode`.
- **Boss decision:** the command catalogue is NOT shipped anywhere the caller can read it.
  No command list and no arg signatures in `SKILL.md` (only an example), none in `--help`.
  This section 2 catalogue and the dump in section 4 stay in this internal fact file only;
  do not copy them into docs or link them from docs.
- Exit codes: `0` only when the desktop payload says `success: true` (so a skipped command
  exits `1`); `64` for locally rejected input; `1` for tool/window errors.
- Verification status: `dart analyze` clean; local validation + rendering exercised with a
  throwaway harness; **no live round trip possible** — the installed `/Applications/Orca Note.app`
  is built from Oct 31, before `invoke_commands` existed, so the running app answers
  `MCP error -32602: Tool invoke_commands not found` (its tool list has no `invoke_commands`).
  Re-run the manual checklist after the desktop app is rebuilt.
