import 'package:nhentai/domain/entity/masterdata/Version.dart';

class VersionHistory {
  late Version activeVersion;

  late List<Version> otherVersions;

  VersionHistory({required this.activeVersion, required this.otherVersions});

  VersionHistory.fromJson(Map<String, dynamic> json) {
    activeVersion = Version.fromJson(json['active_version']);
    otherVersions = [];

    json['other_versions'].forEach((dynamic anotherVersion) {
      otherVersions.add(Version.fromJson(anotherVersion));
    });
  }
}
