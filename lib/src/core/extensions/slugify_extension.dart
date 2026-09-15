extension SlugifyExtension on String {
  String slugify() {
    return toLowerCase()
        .trim()
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
}
