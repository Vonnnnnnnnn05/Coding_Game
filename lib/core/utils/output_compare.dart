bool outputsMatch(String actual, String expected) {
  String normalize(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .trim()
        .split('\n')
        .map((line) => line.trimRight())
        .join('\n');
  }

  return normalize(actual) == normalize(expected);
}
