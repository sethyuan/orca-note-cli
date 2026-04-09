class ToolFieldMetadata {
  const ToolFieldMetadata({
    required this.name,
    required this.description,
    required this.required,
    this.providedByRepoFlag = false,
  });

  final String name;
  final String description;
  final bool required;
  final bool providedByRepoFlag;
}

class ToolExample {
  const ToolExample({required this.description, required this.command});

  final String description;
  final String command;
}

class ToolMetadata {
  const ToolMetadata({
    required this.name,
    required this.title,
    required this.summary,
    required this.description,
    required this.fields,
    required this.requiredFields,
    required this.examples,
  });

  final String name;
  final String title;
  final String summary;
  final String description;
  final List<ToolFieldMetadata> fields;
  final List<String> requiredFields;
  final List<ToolExample> examples;

  Set<String> get fieldNames {
    return fields.map((field) => field.name).toSet();
  }
}
