class DoujinshiDownloadProgress {
  final int doujinshiId;
  final double pagesDownloadProgress;
  final bool isFailed;
  final bool isFinished;

  DoujinshiDownloadProgress(
      {required this.doujinshiId,
      required this.pagesDownloadProgress,
      required this.isFailed,
      required this.isFinished});
}
