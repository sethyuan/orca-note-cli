import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createS3SyncCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 's3_sync',
      title: 'S3 Sync',
      summary: 'Sync the repository with remote S3 storage.',
      description:
          'Sync the repository with remote S3 storage. Supports download (pull from remote) and upload (push to remote).',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'operation',
          description:
              'The sync operation to perform: "download" to pull from remote, "upload" to push to remote.',
          required: true,
        ),
      ],
      requiredFields: <String>['repoId', 'operation'],
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "operation": "download"\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Error syncing repository: ..."\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Download (pull) repository from remote S3.',
          command:
              "orcanote s3_sync --repo my-repo --input '{\"operation\":\"download\"}'",
        ),
        ToolExample(
          description: 'Upload (push) repository to remote S3.',
          command:
              "orcanote s3_sync --repo my-repo --input '{\"operation\":\"upload\"}'",
        ),
        ToolExample(
          description: 'Sync and keep raw JSON output.',
          command:
              "orcanote s3_sync --repo my-repo --input '{\"operation\":\"download\"}' --json",
        ),
      ],
    ),
  );
}
