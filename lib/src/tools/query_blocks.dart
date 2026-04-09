import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createQueryBlocksCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'query_blocks',
      title: 'Query Blocks',
      summary: 'Run structured block queries with QueryDescription2.',
      description:
          'Executes advanced repository queries using Orca Note\'s QueryDescription2 format. Pass the full query object as the description field inside --input. The root group should usually be kind 100 (SELF_AND).',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'description',
          description:
              'Complete query description object containing q, pagination, sorting, and related options.',
          required: true,
        ),
      ],
      requiredFields: <String>['repoId', 'description'],
      examples: <ToolExample>[
        ToolExample(
          description: 'Search for blocks containing a text fragment.',
          command:
              "orcanote query_blocks --repo=my-repo --input='{\"description\":{\"q\":{\"kind\":100,\"conditions\":[{\"kind\":8,\"text\":\"deadline\"}]}}}'",
        ),
        ToolExample(
          description: 'Find incomplete tasks and keep the raw JSON response.',
          command:
              "orcanote query_blocks --repo=my-repo --input='{\"description\":{\"q\":{\"kind\":100,\"conditions\":[{\"kind\":11,\"completed\":false}]},\"page\":1,\"pageSize\":20}}' --json",
        ),
      ],
    ),
  );
}
