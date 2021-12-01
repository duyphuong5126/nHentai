class Version {
  late String appVersionCode;
  late bool isActivated;
  late String whatsNew;
  late String detailsUrl;
  late String downloadUrl;

  Version(
      {required this.appVersionCode,
      required this.isActivated,
      required this.whatsNew,
      required this.detailsUrl,
      required this.downloadUrl});

  Version.fromJson(Map<String, dynamic> json) {
    appVersionCode = json['app_version_code'];
    isActivated = json['is_activated'];
    whatsNew = json['whats_new'];
    detailsUrl = json['url'];
    downloadUrl = json['download_url'];
  }
}
