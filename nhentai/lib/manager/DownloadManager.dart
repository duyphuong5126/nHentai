import 'dart:collection';

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

  static final Queue<Doujinshi> _downloadQueue = Queue();

  static final List<Function(int)> _finishDownloadObservers = [];

  static void downloadDoujinshi(
      {required Doujinshi doujinshi,
      Function(int doujinshiId)? onPending,
      Function()? onDownloadStarted,
      Function(int doujinshiId)? onFinished}) async {
    if (onFinished != null) {
      _finishDownloadObservers.add(onFinished);
    }
    DoujinshiDownloadProgress currentProgress = downloadProgressCubit.state;
    if (currentProgress.doujinshiId == doujinshi.id) {
      onDownloadStarted?.call();
      return;
    } else if (currentProgress.doujinshiId >= 0 &&
        currentProgress.pagesDownloadProgress > 0 &&
        !currentProgress.isFinished &&
        !currentProgress.isFailed) {
      _downloadQueue.add(doujinshi);
      onPending?.call(currentProgress.doujinshiId);
      return;
    }
    DownloadManager.downloadProgressCubit.emit(DoujinshiDownloadProgress(
        doujinshiId: doujinshi.id,
        pagesDownloadProgress: 0.0,
        isFailed: false,
        isFinished: false));
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
      await Future.delayed(Duration(seconds: 1), () {
        DownloadManager.downloadProgressCubit.emit(DoujinshiDownloadProgress(
            doujinshiId: doujinshi.id,
            pagesDownloadProgress: (progress / total),
            isFailed: false,
            isFinished: true));

        print('DownloadManager: observers=${_finishDownloadObservers.length}');
        _finishDownloadObservers
            .forEach((onFinishObserver) => onFinishObserver.call(doujinshi.id));
        _finishDownloadObservers.clear();

        DownloadManager.downloadProgressCubit.emit(DoujinshiDownloadProgress(
            doujinshiId: -1,
            pagesDownloadProgress: 0,
            isFailed: false,
            isFinished: false));

        if (_downloadQueue.isNotEmpty) {
          try {
            Doujinshi nextDoujinshi = _downloadQueue.removeFirst();
            print('DownloadManager: next doujinshi ${nextDoujinshi.id}');
            downloadDoujinshi(doujinshi: nextDoujinshi);
          } catch (error) {
            print(
                'DownloadManager: failed to start download next doujinshi with error $error');
          }
        }
      });
    });
  }

  static void subscribeOnFinishObserver(Function(int) onFinishObserver) async {
    if (!_finishDownloadObservers.contains(onFinishObserver)) {
      _finishDownloadObservers.add(onFinishObserver);
    }
  }

  static void unsubscribeOnFinishObserver(
      Function(int) onFinishObserver) async {
    _finishDownloadObservers.remove(onFinishObserver);
  }
}
