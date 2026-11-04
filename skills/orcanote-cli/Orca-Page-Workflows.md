# Orca Note page workflows: pages, long-form, journals, references, read-back

Use this together with `SKILL.md`, `Core-Commands.md` and `Core-Editor-Commands.md`. Each rule below
carries its evidence in place: either the command plus the read-back that confirmed it, or a plain
note that it rests on documentation / the app bundle only. When the evidence matters, repeat the
read-back in your own repo.

## 0. The read-back channel: `ret` from `invoke_commands`

For AI commands (`core.ai.*`) `invoke_commands` returns the command's value in `results[i].ret`. The
most useful one is `core.ai.getBlocks`, which returns a read-only JSON view of blocks: it does not
touch editor state and creates no undo step.

```sh
orcanote invoke_commands --repo <repoId> --input \
  '{"commands":[{"id":"core.ai.getBlocks","args":[[1234,5678],{"includeContent":true}]}]}' --json
```

- Arguments are positional: `[blockIdArray, opts?]`. An object form does **not** work —
  `args:[{"blockIds":[...]}]` answers `No valid block IDs.`. A single block still goes in an array
  (or as a bare id): `args:[[1234]]`.
- `ret.blocks[]` carries `id / type / text / parent / children / aliases / tags / links /
  properties`; empty fields are omitted. With `opts.includeContent=true` each block also gets
  `content`, the raw content fragments — inline formatting shows up there as e.g.
  `{"v":"…","f":"b"}` for bold. The command signature is documented in the **AI Commands** section
  of `Core-Commands.md`.
- ⚠️ `text` is "the block's own text + its tag property values", not the block content. A page block
  carrying a property set to a value read back as `<title>` + newline + `<property>: <value>;`
  (observed on a page whose tag property was `分类` = `科普`, which came back as
  `给小学生讲相对论\n分类: 科普;`). Nothing was corrupted — that string is assembled by the read.
- For journals and page bodies keep using `get_blocks_text`; the two views cross-check each other.

## 1. Creating pages

- **A page is a top-level block (no parent) plus an alias; the alias *is* the page title.**
  `create_page {"name":"<title>"}` → `{"blockId":N}`. Reading that block back gives: no `text`,
  `aliases:["<title>"]`, `_repr:{"type":"text"}`. That is already the complete state — **you do not
  need `setBlocksContent` to write the title**; the UI shows the alias as the page title. (Observed
  by reading the freshly created block back with `core.ai.getBlocks`.)
- Only if you also want title text inside the block content (some older pages were written that way)
  or a tag line, use `core.editor.setBlocksContent` + `insert_tags`; a plain new page can skip both.
- Sub-pages: the block becomes a **child of the parent page** and its alias is written as
  `/parent/child`. Existing examples in a repo of this shape: a page with alias `结构文章` and its
  sub-page with alias `/结构文章/文献综述`. After `create_page`, attach it with
  `move_blocks {"blockIds":[<child>],"parentId":<parent>}` — the read-back then shows `parent`
  pointing at the parent page and `aliases` holding the `/parent/child` value.
- `includeIn` on `create_page` (documented to place the page into the target page's `_is`): in one
  trial the property did not appear in the read-back at all, so do not rely on it for placement —
  use `move_blocks` or the alias prefix instead.
- Before deciding where a new page goes, what it is called and whether it carries a tag, run
  `get_tags_and_pages` and follow the conventions of comparable pages in that repo.

## 2. Showing a page as long-form

- Long-form is the `lf` field on the block repr: `_repr:{"type":"text","lf":true}`. Setting it on the
  **page block** applies to the whole page: the renderer adds the `orca-long-form` class to that
  block's div, and the CSS scope covers every descendant (non-list blocks all take the initial
  indent, bullet/scope lines are hidden, block spacing becomes 0.35em, headings get document-like
  top margins h1 1.4em / h2 1.2em / h3 1em / h4 0.8em). This comes from the stylesheet and render
  code inside the app bundle; it has not been confirmed by eye in the app.
- Turning it on (the same command the block menu's "As long-form" item invokes):
  `core.editor.toggleShowAsLongForm` with args `[<pageBlockId>]` → `status: ok`.
  ⚠️ It is a **toggle** (`lf: !lf` in the app). Running it twice on the same block turns long-form
  back **off**, so either call it exactly once or read `_repr.lf` first and only call it when it is
  not set yet.
- Idempotent alternative for re-runnable scripts: `core.editor.setProperties` with args
  `[[<pageBlockId>],[{"name":"_repr","type":0,"value":{"type":"text","lf":true}}]]`. It overwrites
  the whole repr, so it is only safe for a block whose repr really is plain text (a freshly created
  page is). The alias survives the write. Verified by reading the block back with
  `core.ai.getBlocks` → `"lf":true`.
- Read-back (an earlier note claiming "there is no interface to read `_repr`" is obsolete):
  `core.ai.getBlocks` → `blocks[0].properties._repr.lf`. On a real page this returned
  `{"_repr":{"type":"text","lf":true}}`, i.e. long-form was in fact on.

## 3. Journals

- `get_journal` (no `date` = today; pass `date` as Unix seconds for another day) returns
  `{blockId, date}` and **creates the day's journal if it does not exist**.
- A journal block is a top-level block and has **no alias** (it never shows up in the `pages` list of
  `get_tags_and_pages`); its date lives in an internal property.

## 4. References (pointing a journal at a page)

- A real reference: write `[[<blockId>]]` or `[[<page name>]]` in the text passed to
  `insert_markdown` — it becomes an inline block reference. Page names containing Chinese, spaces or
  parentheses all resolve (checked by resolving `links` in `get_blocks_text` / `core.ai.getBlocks`
  back to the target id).
- Counter-example: `[<text>](orca-note://<repo>/block?blockId=N)` is an ordinary Markdown link,
  `links` stays empty, and it is **not** a block reference.
- To show the body instead of a link, `core.editor.makeMirror` does that; documented only, not tried.
- Typical write: `insert_markdown {"refBlockId":<journalBlock>,"position":"lastChild","text":"… [[<page name>]]"}`
  and then read `links` back to confirm the target resolved.

## 5. Tags and properties, and how to check them

- Write: `insert_tags {"blockIds":[<pageBlock>],"tags":[{"name":"Article","props":{"<prop>":"<value>"}}]}`
  (tag and property names are often Chinese in a real repo, e.g. `分类` = `科普` — pass them verbatim).
- Check 1 — query back: `query_blocks` with a tag condition plus a property operator (1 = equals), e.g.
  `{"kind":4,"name":"Article","selfOnly":true,"properties":[{"name":"<prop>","op":1,"value":"<value>"}]}`.
  If the target block is in the result, the write landed.
- Check 2 — `tags` field of `core.ai.getBlocks`. Note it returns the tag block's **primary name**: a
  tag written as `Article` can read back as `文章` when both are aliases of the same tag block. That is
  not a failed write.

## 6. Clipboard commands need a focused window

- **Every clipboard-dependent command (`core.editor.copyBlockLink`, `copy.md`, `copyBlockID`,
  `copySelection`, `pasteText` / `pastePlainText`, …) requires the Orca Note window to be focused.**
  When the window is not focused they still answer `status: ok`, but what ends up on the clipboard is
  not trustworthy (it can be a fragment only).
- Controlled comparison, `core.editor.copyBlockLink` on block id 3814, everything else equal:
  - without `focus` (window in the background): `status: ok`, `pbpaste` returned only
    `8enq14x562fzl` — incomplete;
  - with `"focus": true`: `status: ok`, `pbpaste` returned the full
    `orca-note://8enq14x562fzl/block?blockId=3814` (the clipboard also carried an HTML `<a>` flavor).
- So: pass `"focus": true` when you actually need the clipboard result — it raises and focuses the
  window, which disturbs the user, so do it only when necessary. If you cannot check or do not want to
  change the focus state, **do not take results from the clipboard**; verify with readable commands
  instead (`core.ai.getBlocks`, `get_blocks_text`).
- A page link can of course be assembled by hand as `orca-note://<repo>/block?blockId=<id>`; that is
  just convenience, **not** a sign that `copyBlockLink` is broken.

## 7. Clean-up

- `delete_blocks {"blockIds":[...]}` removes blocks and pages; after deleting a page the `pages`
  count from `get_tags_and_pages` drops back, which makes it a good self-check for leftovers.
- Recon and drafting always happen on a throw-away page that is deleted afterwards; never test layout
  inside the page that matters.
- Clipboard commands **overwrite the user's clipboard** — say so when you use them instead of silently
  taking the user's content.

## 8. Recommended order for one end-to-end landing

1. `create_page`, keep the returned `blockId` (the alias is the title).
2. If a tag is needed: `insert_tags` (with properties).
3. `insert_markdown` the whole body in one go — even for a long article, do not split it, or the
   structure can collapse halfway.
4. Read back with `core.ai.getBlocks` (block count, parent/child tree, `_repr.type`) or
   `get_blocks_text` (text, `links`); confirm no block was attached at the wrong level and no Markdown
   marker stayed unparsed.
5. Read `_repr.lf`; only if it is not set, run `toggleShowAsLongForm` once.
6. `get_journal` → `insert_markdown` the `[[<page name>]]` reference → read `links` back.
7. Delete the temporary blocks and check that the page / tag counts are back to the expected values.
