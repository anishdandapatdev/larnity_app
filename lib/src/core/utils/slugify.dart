String slugify(String text) {
  return text
      .toLowerCase() // convert to lowercase
      .trim() // remove leading/trailing spaces
      .replaceAll(
        RegExp(r'[^\w\s-]'),
        '',
      ) // remove special characters except spaces and hyphens
      .replaceAll(RegExp(r'\s+'), '-') // replace spaces with hyphens
      .replaceAll(
        RegExp(r'-+'),
        '-',
      ); // replace multiple hyphens with single one
}
