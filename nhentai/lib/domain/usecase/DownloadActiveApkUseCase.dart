import 'dart:io';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

abstract class DownloadActiveApkUseCase {
  Stream<String> execute(String versionName, String apkUrl);
}

class DownloadActiveApkUseCaseImpl extends DownloadActiveApkUseCase {
  static const int _FILE_FETCHING_TIME_OUT = 120;

  @override
  Stream<String> execute(String versionName, String apkUrl) {
    return Rx.fromCallable(() => getApplicationDocumentsDirectory())
        .flatMap((Directory appDir) {
      String apkFolderPath = appDir.path + '/download/apk';
      String filePath = apkFolderPath + '/$versionName.apk';
      Directory(apkFolderPath).createSync(recursive: true);
      File localFile = File(filePath);

      return Rx.fromCallable(() => get(Uri.parse(apkUrl))
              .timeout(Duration(seconds: _FILE_FETCHING_TIME_OUT)))
          .flatMap((remoteFile) {
        print(
            'DownloadActiveApkUseCase: pageUrl=$apkUrl - file size=${remoteFile.bodyBytes.length}');
        return Rx.fromCallable(
            () => localFile.writeAsBytes(remoteFile.bodyBytes));
      }).map((File file) => file.path);
    }).doOnError((error, stacktrace) {
      if (error is Exception) {
        print(
            '-------------------\nGET $apkUrl\nError: $error\n-------------------');
        print('$stacktrace');
      } else {
        print(
            '-------------------\nGET $apkUrl\nError: $error\n-------------------');
        print('$stacktrace');
      }
    });
  }
}
