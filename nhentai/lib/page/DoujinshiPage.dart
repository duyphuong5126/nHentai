import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/YesNoActionsAlertDialog.dart';
import 'package:nhentai/component/doujinshi/CoverImage.dart';
import 'package:nhentai/component/doujinshi/DateTimeSection.dart';
import 'package:nhentai/component/doujinshi/DownloadButton.dart';
import 'package:nhentai/component/doujinshi/FavoriteToggleButton.dart';
import 'package:nhentai/component/doujinshi/FirstTitle.dart';
import 'package:nhentai/component/doujinshi/HorizontalDoujinshiList.dart';
import 'package:nhentai/component/doujinshi/IDSection.dart';
import 'package:nhentai/component/doujinshi/PageCountSection.dart';
import 'package:nhentai/component/doujinshi/PreviewSection.dart';
import 'package:nhentai/component/doujinshi/PreviewThumbnail.dart';
import 'package:nhentai/component/doujinshi/SecondTitle.dart';
import 'package:nhentai/component/doujinshi/TagsSection.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiStatuses.dart';
import 'package:nhentai/domain/entity/RecommendDoujinshiList.dart';
import 'package:nhentai/domain/entity/Tag.dart';
import 'package:nhentai/domain/usecase/ClearLastReadPageUseCase.dart';
import 'package:nhentai/domain/usecase/GetDoujinshiStatusesUseCase.dart';
import 'package:nhentai/domain/usecase/GetRecommendedDoujinshiListUseCase.dart';
import 'package:nhentai/domain/usecase/UpdateDoujinshiDetailsUseCase.dart';
import 'package:nhentai/page/uimodel/ReadingModel.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';

class DoujinshiPage extends StatefulWidget {
  const DoujinshiPage({Key? key}) : super(key: key);

  @override
  _DoujinshiPageState createState() => _DoujinshiPageState();
}

class _DoujinshiPageState extends State<DoujinshiPage> {
  late List<Widget> itemList;
  late DataCubit<Doujinshi> doujinshiCubit;
  late DataCubit<int> lastReadPageCubit = DataCubit(-1);
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
  late SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  late DataCubit<bool> _isCensoredCubit = DataCubit(false);

  void _getRecommendedList(int doujinshiId) async {
    RecommendedDoujinshiList recommendedDoujinshiList =
        await _recommendedDoujinshiListUseCase.execute(doujinshiId);
    _recommendedDoujinshiListCubit.emit(recommendedDoujinshiList.result);
  }

  void _updateDoujinshiStatuses(int doujinshiId) async {
    DoujinshiStatuses statuses =
        await _getDoujinshiStatusesUseCase.execute(doujinshiId);
    lastReadPageCubit.emit(statuses.lastReadPageIndex);
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
    doujinshiCubit = DataCubit<Doujinshi>(
        ModalRoute.of(context)?.settings.arguments as Doujinshi);
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: BlocBuilder(
            bloc: doujinshiCubit,
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

  Widget _generateDetailSections(Doujinshi doujinshi) {
    Map<String, List<Tag>> tagMap = {};
    doujinshi.tags.forEach((tag) {
      if (!tagMap.containsKey(tag.type)) {
        tagMap[tag.type] = [];
      }
      tagMap[tag.type]?.add(tag);
    });

    itemList = [];
    itemList.add(SizedBox(
      height: 10,
    ));
    itemList.add(BlocBuilder(
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
                  coverImageUrl: doujinshi.coverImage,
                  backUpCoverImageUrl: doujinshi.backUpCoverImage,
                );
          return GestureDetector(
            child: cover,
            onTap: () => _readDoujinshi(doujinshi, 0),
          );
        }));
    itemList.add(SizedBox(
      height: 10,
    ));
    itemList.add(FirstTitle(
      text: doujinshi.title.english,
    ));
    itemList.add(SizedBox(
      height: 10,
    ));
    itemList.add(SecondTitle(
      text: doujinshi.title.japanese,
    ));
    itemList.add(SizedBox(
      height: 10,
    ));
    itemList.add(IDSection(
      id: doujinshi.id,
    ));
    itemList.add(SizedBox(
      height: 10,
    ));
    List<String> tagNames = tagMap.keys.toList(growable: false);
    tagNames.sort(
        (first, second) => first.toLowerCase().compareTo(second.toLowerCase()));
    tagNames.forEach((tagName) {
      List<Tag>? tags = tagMap[tagName];
      itemList.add(TagsSection(
        tagName: tagName,
        tagList: tags != null ? tags : [],
        onTagSelected: this._onTagSelected,
      ));
      itemList.add(SizedBox(
        height: 10,
      ));
    });
    itemList.add(SizedBox(
      height: 5,
    ));
    itemList.add(PageCountSection(
      pageCount: doujinshi.numPages,
    ));
    itemList.add(SizedBox(
      height: 10,
    ));
    itemList.add(DateTimeSection(
      timeMillis: doujinshi.uploadDate * 1000,
    ));
    itemList.add(SizedBox(
      height: 10,
    ));
    itemList.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FavoriteToggleButton(
          favoriteCount: doujinshi.numFavorites,
        ),
        SizedBox(
          width: 10,
        ),
        DownloadButton()
      ],
    ));
    itemList.add(SizedBox(
      height: 10,
    ));
    itemList.add(BlocBuilder(
        bloc: lastReadPageCubit,
        builder: (BuildContext c, int lastReadPageIndex) {
          List<Widget> lastReadPageWidgets = [];
          if (lastReadPageIndex >= 0) {
            String thumbnailUrl =
                doujinshi.previewThumbnailList[lastReadPageIndex];
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
                      builder: (content) {
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
              child: PreviewThumbnail(
                  thumbnailUrl: thumbnailUrl,
                  imagePosition: lastReadPageIndex,
                  onThumbnailSelected: (int selectedIndex) {
                    _readDoujinshi(doujinshi, selectedIndex);
                  }),
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
    itemList.add(SizedBox(
      height: 15,
    ));
    itemList.add(PreviewSection(
      pages: doujinshi.previewThumbnailList,
      onPageSelected: (pageIndex) {
        _readDoujinshi(doujinshi, pageIndex);
      },
    ));
    itemList.add(SizedBox(
      height: 15,
    ));
    itemList.add(HorizontalDoujinshiList(
        doujinshiListCubit: _recommendedDoujinshiListCubit,
        onDoujinshiSelected: (doujinshi) {
          doujinshiCubit.emit(doujinshi);
        }));
    itemList.add(SizedBox(
      height: 50,
    ));
    _getRecommendedList(doujinshi.id);
    _updateDoujinshiStatuses(doujinshi.id);
    return ListView(
      children: List.generate(itemList.length, (index) {
        return itemList[index];
      }),
    );
  }

  void _readDoujinshi(Doujinshi doujinshi, int startPageIndex) async {
    lastReadPageCubit.emit(-1);
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
}
