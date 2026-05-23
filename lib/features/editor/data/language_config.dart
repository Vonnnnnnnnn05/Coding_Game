class LanguageConfig {
  const LanguageConfig({
    required this.id,
    required this.name,
    required this.key,
    required this.highlightMode,
  });

  final int id;
  final String name;
  final String key;
  final String highlightMode;
}

const supportedLanguages = [
  LanguageConfig(
    id: 71,
    name: 'Python',
    key: 'python',
    highlightMode: 'python',
  ),
  LanguageConfig(id: 54, name: 'C++', key: 'cpp', highlightMode: 'cpp'),
  LanguageConfig(id: 62, name: 'Java', key: 'java', highlightMode: 'java'),
  LanguageConfig(
    id: 63,
    name: 'JavaScript',
    key: 'javascript',
    highlightMode: 'javascript',
  ),
  LanguageConfig(id: 51, name: 'C#', key: 'csharp', highlightMode: 'cs'),
];
