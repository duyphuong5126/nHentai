import 'dart:async';
import 'dart:collection';
import 'dart:io' show Platform;

import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiDownloadProgress.dart';
import 'package:nhentai/domain/usecase/DownloadDoujinshiUseCase.dart';
import 'package:nhentai/notification/notification_helper.dart';
import 'package:nhentai/notification/notification_helper_factory.dart';

class DownloadManager {
  static final DataCubit<DoujinshiDownloadProgress> downloadProgressCubit =
      DataCubit(DoujinshiDownloadProgress(
          doujinshiId: -1,
          pagesDownloadProgress: 0,
          isFinished: false,
          isFailed: false));

  static final Queue<Doujinshi> _downloadQueue = Queue();

  static final List<Function(int, bool)> _finishDownloadObservers = [];

  static StreamSubscription? downloadSubscription;

  static late NotificationHelper _downloadNotificationHelper =
      NotificationHelperFactory.doujinshiNotificationHelper;

  static const int _downloadProgressNotificationId = 123;

  static void downloadDoujinshi(
      {required Doujinshi doujinshi,
      Function(int doujinshiId)? onPending,
      Function()? onDownloadDuplicated,
      Function()? onDownloadStarted,
      Function(int doujinshiId, bool isFailed)? onFinished}) {
    if (onFinished != null && !_finishDownloadObservers.contains(onFinished)) {
      print('DownloadManager: adding onFinishObserver $onFinished');
      _finishDownloadObservers.add(onFinished);
    }
    DoujinshiDownloadProgress currentProgress = downloadProgressCubit.state;
    if (currentProgress.doujinshiId == doujinshi.id) {
      onDownloadDuplicated?.call();
      return;
    } else if (currentProgress.doujinshiId >= 0 &&
        currentProgress.pagesDownloadProgress > 0 &&
        !currentProgress.isFinished &&
        !currentProgress.isFailed) {
      _downloadQueue.add(doujinshi);
      onPending?.call(currentProgress.doujinshiId);
      return;
    }
    onDownloadStarted?.call();
    DownloadManager.downloadProgressCubit.emit(DoujinshiDownloadProgress(
        doujinshiId: doujinshi.id,
        pagesDownloadProgress: 0.0,
        isFailed: false,
        isFinished: false));
    DownloadDoujinshiUseCase _downloadDoujinshiUseCase =
        DownloadDoujinshiUseCaseImpl();
    int progress = 0;
    int total = doujinshi.fullSizePageUrlList.length + 4;
    downloadSubscription = _downloadDoujinshiUseCase.execute(doujinshi).listen(
        (savedPageLocalPath) {
      print(
          'DownloadManager: doujinshi ${doujinshi.id} - savedPageLocalPath=$savedPageLocalPath');
      progress++;
      _sendDownloadingNotification(progress / total, doujinshi.id);
      DownloadManager.downloadProgressCubit.emit(DoujinshiDownloadProgress(
          doujinshiId: doujinshi.id,
          pagesDownloadProgress: progress / total,
          isFailed: false,
          isFinished: false));
    }, onError: (error) {
      downloadSubscription?.cancel();
      downloadSubscription = null;
      print(
          'DownloadManager: failed to download doujinshi ${doujinshi.id} with error $error');
      DownloadManager.downloadProgressCubit.emit(DoujinshiDownloadProgress(
          doujinshiId: doujinshi.id,
          pagesDownloadProgress: (progress / total),
          isFailed: true,
          isFinished: true));

      print('DownloadManager: observers=${_finishDownloadObservers.length}');
      _sendDownloadDoujinshiNotification(doujinshi.id, true);
      _finishDownloadObservers.forEach(
          (onFinishObserver) => onFinishObserver.call(doujinshi.id, true));
      _finishDownloadObservers.clear();

      DownloadManager.downloadProgressCubit.emit(DoujinshiDownloadProgress(
          doujinshiId: -1,
          pagesDownloadProgress: 0,
          isFailed: false,
          isFinished: false));
    }, onDone: () async {
      downloadSubscription?.cancel();
      downloadSubscription = null;
      print('DownloadManager: downloaded doujinshi ${doujinshi.id}');
      await Future.delayed(Duration(seconds: 1), () {
        progress++;
        DownloadManager.downloadProgressCubit.emit(DoujinshiDownloadProgress(
            doujinshiId: doujinshi.id,
            pagesDownloadProgress: (progress / total),
            isFailed: false,
            isFinished: false));
      }).then((value) => Future.delayed(Duration(seconds: 1), () {
            DownloadManager.downloadProgressCubit.emit(
                DoujinshiDownloadProgress(
                    doujinshiId: doujinshi.id,
                    pagesDownloadProgress: (progress / total),
                    isFailed: false,
                    isFinished: true));
            print(
                'DownloadManager: observers=${_finishDownloadObservers.length}');
            _sendDownloadDoujinshiNotification(doujinshi.id, false);
            _finishDownloadObservers.forEach((onFinishObserver) =>
                onFinishObserver.call(doujinshi.id, false));
            _finishDownloadObservers.clear();

            DownloadManager.downloadProgressCubit.emit(
                DoujinshiDownloadProgress(
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
            } else {
              print('DownloadManager: no more doujinshi');
            }
          }));
    });
  }

  static void subscribeOnFinishObserver(
      Function(int, bool) onFinishObserver) async {
    if (!_finishDownloadObservers.contains(onFinishObserver)) {
      _finishDownloadObservers.add(onFinishObserver);
    }
  }

  static void unsubscribeOnFinishObserver(
      Function(int, bool) onFinishObserver) async {
    _finishDownloadObservers.remove(onFinishObserver);
  }

  static void _sendDownloadingNotification(
      double absoluteProgress, int doujinshiId) {
    String absoluteProgressText = '${(absoluteProgress * 100).toInt()}%';
    String notificationTitle = 'Downloading';
    String notificationBody =
        'Downloading doujinshi $doujinshiId, progress: $absoluteProgressText';
    if (Platform.isAndroid) {
      _downloadNotificationHelper.sendAndroidNotification(
          _downloadProgressNotificationId, notificationTitle, notificationBody,
          onlyAlertOnce: true);
    } else if (Platform.isIOS) {
      _downloadNotificationHelper.sendIOSNotification(
          doujinshiId, notificationTitle, notificationBody,
          presentAlert: true, presentSound: false, presentBadge: false);
    }
  }

  static void _sendDownloadDoujinshiNotification(
      int doujinshiId, bool isFailed) {
    String notificationTitle =
        isFailed ? 'Download failed' : 'Download finished';
    String notificationBody = isFailed
        ? 'Could not download doujinshi $doujinshiId'
        : 'Doujinshi $doujinshiId was downloaded successfully, you can read it in offline.\nGo to Home -> Download tab to find it.';
    _cancelDownloadProgressNotification();
    if (Platform.isAndroid) {
      _downloadNotificationHelper.sendAndroidNotification(
          doujinshiId, notificationTitle, notificationBody,
          onlyAlertOnce: false);
    } else if (Platform.isIOS) {
      _downloadNotificationHelper.sendIOSNotification(
          doujinshiId, notificationTitle, notificationBody,
          presentAlert: true, presentSound: true, presentBadge: true);
    }
  }

  static void _cancelDownloadProgressNotification() {
    _downloadNotificationHelper
        .cancelNotification(_downloadProgressNotificationId);
  }
}
