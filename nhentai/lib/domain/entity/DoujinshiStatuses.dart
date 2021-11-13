class DoujinshiStatuses {
  final int lastReadPageIndex;
  final bool isFavorite;
  final bool isDownloaded;

  const DoujinshiStatuses(
      {this.lastReadPageIndex = -1,
      this.isFavorite = false,
      this.isDownloaded = false});
}
