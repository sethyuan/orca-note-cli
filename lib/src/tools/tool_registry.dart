import '../command_context.dart';
import '../tool_command.dart';
import 'create_page.dart';
import 'create_tags.dart';
import 'delete_blocks.dart';
import 'get_blocks_text.dart';
import 'get_page.dart';
import 'get_tags_and_pages.dart';
import 'get_today_journal.dart';
import 'insert_markdown.dart';
import 'insert_tags.dart';
import 'move_blocks.dart';
import 'query_blocks.dart';
import 'remove_tags.dart';

List<OrcaToolCommand> createToolCommands(OrcaNoteCommandContext context) {
  return <OrcaToolCommand>[
    createGetTagsAndPagesCommand(context),
    createGetPageCommand(context),
    createGetBlocksTextCommand(context),
    createGetTodayJournalCommand(context),
    createQueryBlocksCommand(context),
    createInsertMarkdownCommand(context),
    createMoveBlocksCommand(context),
    createCreatePageCommand(context),
    createDeleteBlocksCommand(context),
    createInsertTagsCommand(context),
    createRemoveTagsCommand(context),
    createCreateTagsCommand(context),
  ];
}
