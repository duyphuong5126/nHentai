import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiDownloadProgress.dart';
import 'package:nhentai/domain/usecase/DownloadDoujinshiUseCase.dart';

class DownloadManager {
  static final DataCubit<DoujinshiDownloadProgress> downloadProgressCubit =
      DataCubit(DoujinshiDownloadProgress(
          doujinshiId: -1,
          pagesDownloadProgress: 0,
          isFinished: false,
          isFailed: false));

  static void downloadDoujinshi(Doujinshi doujinshi) async {
    DownloadDoujinshiUseCase _downloadDoujinshiUseCase =
        DownloadDoujinshiUseCaseImpl();
    int progress = 0;
    int total = doujinshi.fullSizePageUrlList.length + 2;
    _downloadDoujinshiUseCase.execute(doujinshi).listen((savedPageLocalPath) {
      print(
          'DownloadManager: doujinshi ${doujinshi.id} - savedPageLocalPath=$savedPageLocalPath');
      progress++;
      DownloadManager.downloadProgressCubit.emit(DoujinshiDownloadProgress(
          doujinshiId: doujinshi.id,
          pagesDownloadProgress: progress / total,
          isFailed: false,
          isFinished: false));
    }, onError: (error) {
      print(
          'DownloadManager: failed to download doujinshi ${doujinshi.id} with error $error');
      DownloadManager.downloadProgressCubit.emit(DoujinshiDownloadProgress(
          doujinshiId: doujinshi.id,
          pagesDownloadProgress: (progress / total),
          isFailed: true,
          isFinished: true));
    }, onDone: () async {
      print('DownloadManager: downloaded doujinshi ${doujinshi.id}');
      await Future.delayed(
          Duration(seconds: 1),
          () => DownloadManager.downloadProgressCubit.emit(
              DoujinshiDownloadProgress(
                  doujinshiId: doujinshi.id,
                  pagesDownloadProgress: (progress / total),
                  isFailed: false,
                  isFinished: true)));
    });
  }
}
