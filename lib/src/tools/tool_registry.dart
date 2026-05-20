import '../command_context.dart';
import '../tool_command.dart';
import 'create_page.dart';
import 'create_tags.dart';
import 'delete_blocks.dart';
import 'get_blocks_structure.dart';
import 'get_blocks_text.dart';
import 'get_journal.dart';
import 'get_page.dart';
import 'get_tags_and_pages.dart';
import 'insert_markdown.dart';
import 'insert_tags.dart';
import 'move_blocks.dart';
import 'parse_datetime.dart';
import 'query_blocks.dart';
import 'remove_tags.dart';
import 'shift_datetime.dart';

List<OrcaToolCommand> createToolCommands(OrcaNoteCommandContext context) {
  return <OrcaToolCommand>[
    createGetTagsAndPagesCommand(context),
    createGetPageCommand(context),
    createGetBlocksStructureCommand(context),
    createGetBlocksTextCommand(context),
    createGetJournalCommand(context),
    createParseDatetimeCommand(context),
    createQueryBlocksCommand(context),
    createShiftDatetimeCommand(context),
    createInsertMarkdownCommand(context),
    createMoveBlocksCommand(context),
    createCreatePageCommand(context),
    createDeleteBlocksCommand(context),
    createInsertTagsCommand(context),
    createRemoveTagsCommand(context),
    createCreateTagsCommand(context),
  ];
}
