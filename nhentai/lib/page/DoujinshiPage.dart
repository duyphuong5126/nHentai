import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:core';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/analytics/AnalyticsUtils.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/ConfirmationAlertDialog.dart';
import 'package:nhentai/component/YesNoActionsAlertDialog.dart';
import 'package:nhentai/component/doujinshi/CoverImage.dart';
import 'package:nhentai/component/doujinshi/DateTimeSection.dart';
import 'package:nhentai/component/doujinshi/DeleteDownloadedDoujinshiButton.dart';
import 'package:nhentai/component/doujinshi/DownloadButton.dart';
import 'package:nhentai/component/doujinshi/DownloadedPreviewThumbnail.dart';
import 'package:nhentai/component/doujinshi/FavoriteToggleButton.dart';
import 'package:nhentai/component/doujinshi/FirstTitle.dart';
import 'package:nhentai/component/doujinshi/HorizontalDoujinshiList.dart';
import 'package:nhentai/component/doujinshi/IDSection.dart';
import 'package:nhentai/component/doujinshi/PageCountSection.dart';
import 'package:nhentai/component/doujinshi/PreviewSection.dart';
import 'package:nhentai/component/doujinshi/PreviewThumbnail.dart';
import 'package:nhentai/component/doujinshi/SecondTitle.dart';
import 'package:nhentai/component/doujinshi/TagsSection.dart';
import 'package:nhentai/domain/entity/DeletedDoujinshi.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiDownloadProgress.dart';
import 'package:nhentai/domain/entity/DoujinshiStatuses.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshi.dart';
import 'package:nhentai/domain/entity/RecommendDoujinshiList.dart';
import 'package:nhentai/domain/entity/Tag.dart';
import 'package:nhentai/domain/usecase/ClearLastReadPageUseCase.dart';
import 'package:nhentai/domain/usecase/DeleteDownloadedDoujinshiUseCase.dart';
import 'package:nhentai/domain/usecase/GetDoujinshiStatusesUseCase.dart';
import 'package:nhentai/domain/usecase/GetRecommendedDoujinshiListUseCase.dart';
import 'package:nhentai/domain/usecase/UpdateDoujinshiDetailsUseCase.dart';
import 'package:nhentai/domain/usecase/UpdateFavoriteDoujinshiUseCase.dart';
import 'package:nhentai/manager/DownloadManager.dart';
import 'package:nhentai/page/uimodel/ReadingModel.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DoujinshiPage extends StatefulWidget {
  const DoujinshiPage({Key? key}) : super(key: key);

  @override
  _DoujinshiPageState createState() => _DoujinshiPageState();
}

class _DoujinshiPageState extends State<DoujinshiPage> {
  late List<Widget> _itemList;
  late DataCubit<Doujinshi> _doujinshiCubit;
  late DataCubit<int> _lastReadPageCubit = DataCubit(-1);
  late DataCubit<List<Doujinshi>> _recommendedDoujinshiListCubit =
      DataCubit([]);
  late GetRecommendedDoujinshiListUseCase _recommendedDoujinshiListUseCase =
      GetRecommendedDoujinshiListUseCaseImpl();
  late GetDoujinshiStatusesUseCase _getDoujinshiStatusesUseCase =
      GetDoujinshiStatusesUseCaseImpl();
  late ClearLastReadPageUseCase _clearLastReadPageUseCase =
      ClearLastReadPageUseCaseImpl();
  late UpdateDoujinshiDetailsUseCase _updateDoujinshiDetailsUseCase =
      UpdateDoujinshiDetailsUseCaseImpl();
  final UpdateFavoriteDoujinshiUseCase _updateFavoriteDoujinshiUseCase =
      UpdateFavoriteDoujinshiUseCaseImpl();
  final DeleteDownloadedDoujinshiUseCase _deleteDownloadedDoujinshiUseCase =
      DeleteDownloadedDoujinshiUseCaseImpl();
  late SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  late DataCubit<bool> _isCensoredCubit = DataCubit(false);
  late DataCubit<bool> _isFavoriteCubit = DataCubit(false);

  int _doujinshiId = -1;

  StreamSubscription? _deleteSubscription;

  void _getRecommendedList(int doujinshiId) async {
    RecommendedDoujinshiList recommendedDoujinshiList =
        await _recommendedDoujinshiListUseCase.execute(doujinshiId);
    _recommendedDoujinshiListCubit.emit(recommendedDoujinshiList.result);
  }

  void _updateDoujinshiStatuses(int doujinshiId) async {
    DoujinshiStatuses statuses =
        await _getDoujinshiStatusesUseCase.execute(doujinshiId);
    _lastReadPageCubit.emit(statuses.lastReadPageIndex);
    _isFavoriteCubit.emit(statuses.isFavorite);
    if (statuses.isDownloaded ||
        statuses.isFavorite ||
        statuses.lastReadPageIndex >= 0) {
      _updateDoujinshiDetailsUseCase.execute(doujinshiId);
    }
  }

  void _initCensoredStatus() async {
    _isCensoredCubit.emit(await _preferenceManager.isCensored());
  }

  @override
  Widget build(BuildContext context) {
    _initCensoredStatus();
    Doujinshi doujinshi =
        ModalRoute.of(context)?.settings.arguments as Doujinshi;
    _doujinshiCubit = DataCubit<Doujinshi>(doujinshi);
    _doujinshiId = doujinshi.id;

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: BlocBuilder(
            bloc: _doujinshiCubit,
            builder: (BuildContext context, Doujinshi doujinshi) {
              return _generateDetailSections(doujinshi);
            },
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
      backgroundColor: Constant.grey1f1f1f,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _isCensoredCubit.close();
    _isFavoriteCubit.close();
    _doujinshiId = -1;
    DownloadManager.unsubscribeOnFinishObserver(this._onDownloadFinished);
    _deleteSubscription?.cancel();
    _deleteSubscription = null;
  }

  Widget _generateDetailSections(Doujinshi doujinshi) {
    Map<String, List<Tag>> tagMap = {};
    doujinshi.tags.forEach((tag) {
      if (!tagMap.containsKey(tag.type)) {
        tagMap[tag.type] = [];
      }
      tagMap[tag.type]?.add(tag);
    });

    _itemList = [];
    _itemList.add(SizedBox(
      height: 10,
    ));
    _itemList.add(BlocBuilder(
        bloc: _isCensoredCubit,
        builder: (BuildContext context, bool isCensored) {
          Widget cover = isCensored
              ? Container(
                  constraints: BoxConstraints.expand(height: 300),
                  color: Constant.grey1f1f1f,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.block,
                    size: 50,
                    color: Constant.mainColor,
                  ),
                )
              : CoverImage(
                  doujinshi: doujinshi,
                );
          return GestureDetector(
            child: cover,
            onTap: () => _readDoujinshi(doujinshi, 0),
          );
        }));
    _itemList.add(SizedBox(
      height: 10,
    ));
    _itemList.add(FirstTitle(
      text: doujinshi.title.english,
    ));
    _itemList.add(SizedBox(
      height: 10,
    ));
    _itemList.add(SecondTitle(
      text: doujinshi.title.japanese,
    ));
    _itemList.add(SizedBox(
      height: 10,
    ));
    _itemList.add(IDSection(
      id: doujinshi.id,
    ));
    _itemList.add(SizedBox(
      height: 10,
    ));
    List<String> tagNames = tagMap.keys.toList(growable: false);
    tagNames.sort(
        (first, second) => first.toLowerCase().compareTo(second.toLowerCase()));
    tagNames.forEach((tagName) {
      List<Tag>? tags = tagMap[tagName];
      _itemList.add(TagsSection(
        tagName: tagName,
        tagList: tags != null ? tags : [],
        onTagSelected: this._onTagSelected,
      ));
      _itemList.add(SizedBox(
        height: 10,
      ));
    });
    _itemList.add(SizedBox(
      height: 5,
    ));
    _itemList.add(PageCountSection(
      pageCount: doujinshi.numPages,
    ));
    _itemList.add(SizedBox(
      height: 10,
    ));
    _itemList.add(DateTimeSection(
      timeMillis: doujinshi.uploadDate * 1000,
    ));
    _itemList.add(SizedBox(
      height: 10,
    ));
    List<Widget> favoriteDownloadRow = [];
    favoriteDownloadRow.add(BlocBuilder(
        bloc: _isFavoriteCubit,
        builder: (BuildContext b, bool isFavorite) {
          return FavoriteToggleButton(
            favoriteCount: doujinshi.numFavorites,
            isFavorite: isFavorite,
            onPressed: () {
              bool newFavoriteStatus = !isFavorite;
              if (newFavoriteStatus) {
                AnalyticsUtils.addFavorite(doujinshi.id);
              } else {
                AnalyticsUtils.removeFavorite(doujinshi.id);
              }
              _updateFavoriteStatus(doujinshi, newFavoriteStatus);
            },
          );
        }));
    favoriteDownloadRow.add(SizedBox(
      width: 10,
    ));
    if (!(doujinshi is DownloadedDoujinshi)) {
      favoriteDownloadRow.add(DownloadButton(
        onPressed: () {
          DownloadManager.downloadDoujinshi(
              doujinshi: doujinshi,
              onPending: this._onDownloadPending,
              onDownloadStarted: this._onDownloadStarted,
              onFinished: this._onDownloadFinished);
        },
      ));
    }
    _itemList.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: favoriteDownloadRow,
    ));
    _itemList.add(BlocBuilder(
        bloc: DownloadManager.downloadProgressCubit,
        builder:
            (BuildContext context, DoujinshiDownloadProgress downloadProcess) {
          print(
              'Test: id=${downloadProcess.doujinshiId} - progress: ${downloadProcess.pagesDownloadProgress}, failed: ${downloadProcess.isFailed}, finished: ${downloadProcess.isFinished}');
          DownloadManager.subscribeOnFinishObserver(this._onDownloadFinished);
          double absoluteProgress = downloadProcess.doujinshiId == doujinshi.id
              ? downloadProcess.pagesDownloadProgress.abs()
              : 0.0;
          if (absoluteProgress > 1.0) {
            absoluteProgress = 1.0;
          }
          return Visibility(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        child: LinearPercentIndicator(
                      padding: EdgeInsets.all(0.0),
                      percent: absoluteProgress,
                      backgroundColor: Constant.grey4D4D4D,
                      progressColor: _getProgressColor(absoluteProgress),
                    )),
                    Container(
                      width: 60,
                      child: Center(
                        child: Text(
                          '${(absoluteProgress * 100).toInt()}%',
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: Constant.BOLD,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            visible: downloadProcess.doujinshiId == doujinshi.id &&
                !downloadProcess.isFailed &&
                !downloadProcess.isFinished &&
                absoluteProgress > 0.0 &&
                absoluteProgress <= 1.0,
          );
        }));
    _itemList.add(SizedBox(
      height: 10,
    ));
    _itemList.add(BlocBuilder(
        bloc: _lastReadPageCubit,
        builder: (BuildContext c, int lastReadPageIndex) {
          List<Widget> lastReadPageWidgets = [];
          if (lastReadPageIndex >= 0) {
            String thumbnail = doujinshi is DownloadedDoujinshi
                ? doujinshi.downloadedPathList[lastReadPageIndex]
                : doujinshi.previewThumbnailList[lastReadPageIndex];
            lastReadPageWidgets.add(Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Last read page',
                  style: TextStyle(
                      fontFamily: Constant.BOLD,
                      fontSize: 18,
                      color: Colors.white),
                ),
                SizedBox(
                  width: 5,
                ),
                InkResponse(
                  highlightColor: Colors.transparent,
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) {
                        return YesNoActionsAlertDialog(
                            title: 'Forget this doujinshi',
                            content:
                                'This doujinshi is in your reading list. Do you want to remove it?',
                            yesLabel: 'Yes',
                            noLabel: 'No',
                            yesAction: () => _forgetDoujinshi(doujinshi.id),
                            noAction: () {});
                      }),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      Constant.ICON_UN_SEEN,
                      width: 30,
                      height: 20,
                    ),
                  ),
                )
              ],
            ));
            lastReadPageWidgets.add(SizedBox(
              height: 5,
            ));
            lastReadPageWidgets.add(SizedBox(
              height: 197.5,
              width: 148.125,
              child: doujinshi is DownloadedDoujinshi
                  ? DownloadedPreviewThumbnail(
                      thumbnailLocalPath: thumbnail,
                      imagePosition: lastReadPageIndex,
                      onThumbnailSelected: (int selectedIndex) {
                        _readDoujinshi(doujinshi, selectedIndex);
                      })
                  : PreviewThumbnail(
                      thumbnailUrl: thumbnail,
                      imagePosition: lastReadPageIndex,
                      onThumbnailSelected: (int selectedIndex) {
                        _readDoujinshi(doujinshi, selectedIndex);
                      }),
            ));

            lastReadPageWidgets.add(SizedBox(
              height: 15,
            ));
          }

          return Visibility(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lastReadPageWidgets,
            ),
            visible: lastReadPageIndex >= 0,
          );
        }));
    _itemList.add(PreviewSection(
      doujinshi: doujinshi,
      onPageSelected: (pageIndex) {
        _readDoujinshi(doujinshi, pageIndex);
      },
    ));
    _itemList.add(BlocBuilder(
        bloc: _recommendedDoujinshiListCubit,
        builder: (context, List<Doujinshi> list) {
          return Visibility(
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                HorizontalDoujinshiList(
                    doujinshiListCubit: _recommendedDoujinshiListCubit,
                    onDoujinshiSelected: (doujinshi) {
                      AnalyticsUtils.openDoujinshi(doujinshi.id);
                      _doujinshiCubit.emit(doujinshi);
                    })
              ],
            ),
            visible: list.isNotEmpty,
          );
        }));
    if (doujinshi is DownloadedDoujinshi) {
      _itemList.add(SizedBox(
        height: 10,
      ));
      _itemList.add(Visibility(
        child: DeleteDownloadedDoujinshiButton(
          onPressed: () {
            _deleteSubscription = _deleteDownloadedDoujinshiUseCase
                .execute(doujinshi)
                .listen((bool isDeletedSuccessfully) {
              showDialog(
                  context: context,
                  builder: (context) {
                    String title = isDeletedSuccessfully
                        ? 'Deleted Successfully'
                        : 'Failed To Delete';

                    String content = isDeletedSuccessfully
                        ? 'Doujinshi ${doujinshi.id} was deleted successfully'
                        : 'Failed to delete doujinshi ${doujinshi.id}';
                    return ConfirmationAlertDialog(
                        title: title,
                        content: content,
                        confirmLabel: 'OK',
                        confirmAction: () {
                          Navigator.of(context).pop(DeletedDoujinshi());
                        });
                  });
            }, onError: (error) {
              print(
                  'Could not delete doujinshi ${doujinshi.id} with error $error');
              showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationAlertDialog(
                        title: 'Failed To Delete',
                        content:
                            'Failed to delete doujinshi ${doujinshi.id} was deleted successfully',
                        confirmLabel: 'OK',
                        confirmAction: () {
                          Navigator.of(context).pop(DeletedDoujinshi());
                        });
                  });
            });
          },
        ),
        visible: doujinshi is DownloadedDoujinshi,
      ));
    }
    _itemList.add(SizedBox(
      height: 50,
    ));
    _getRecommendedList(doujinshi.id);
    _updateDoujinshiStatuses(doujinshi.id);
    return ListView(
      children: List.generate(_itemList.length, (index) {
        return _itemList[index];
      }),
    );
  }

  Color _getProgressColor(double progress) {
    return progress < 0.5
        ? Constant.mainColor
        : progress < 0.8
            ? Constant.yellowECC031
            : Constant.green53A105;
  }

  void _readDoujinshi(Doujinshi doujinshi, int startPageIndex) async {
    _lastReadPageCubit.emit(-1);
    AnalyticsUtils.readDoujinshi(doujinshi.id);
    await Navigator.of(context).pushNamed(MainNavigator.DOUJINSHI_READER_PAGE,
        arguments:
            ReadingModel(doujinshi: doujinshi, startPageIndex: startPageIndex));
    _updateDoujinshiStatuses(doujinshi.id);
  }

  void _onTagSelected(Tag tag) {
    Navigator.of(context).pop(tag);
  }

  void _forgetDoujinshi(int doujinshiId) async {
    bool updated = await _clearLastReadPageUseCase.execute(doujinshiId);
    if (updated) {
      _updateDoujinshiStatuses(doujinshiId);
    }
  }

  void _updateFavoriteStatus(Doujinshi doujinshi, bool isFavorite) async {
    bool updateSuccessfully =
        await _updateFavoriteDoujinshiUseCase.execute(doujinshi, isFavorite);
    print(
        'Debug: isFavorite=$isFavorite, updateSuccessfully=$updateSuccessfully');
    if (updateSuccessfully) {
      _isFavoriteCubit.emit(isFavorite);
    }
  }

  void _onDownloadPending(int currentDownloadId) {
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlertDialog(
              title: 'Download started',
              content:
                  'This doujinshi will be downloaded after the doujinshi $currentDownloadId',
              confirmLabel: 'OK',
              confirmAction: () {
                print('DoujinshiPage: download confirmation dialog was closed');
              });
        });
  }

  void _onDownloadStarted() {
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlertDialog(
              title: 'Download started',
              content: 'This doujinshi is being downloaded',
              confirmLabel: 'OK',
              confirmAction: () {
                print('DoujinshiPage: download confirmation dialog was closed');
              });
        });
  }

  void _onDownloadFinished(int downloadedDoujinshiId, bool isFailed) {
    if (_doujinshiId >= 0 && _doujinshiId == downloadedDoujinshiId) {
      String content = isFailed
          ? 'Could not download this doujinshi'
          : 'This doujinshi was downloaded successfully, you can read it in offline. Go to Home -> Download tab to find it.';
      showDialog(
          context: context,
          builder: (context) {
            return ConfirmationAlertDialog(
                title: 'Download finished',
                content: content,
                confirmLabel: 'OK',
                confirmAction: () {
                  print(
                      'DoujinshiPage: download confirmation dialog was closed');
                });
          });
    }
  }
}
