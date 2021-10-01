import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/bloc/DoujinshiBloc.dart';
import 'package:nhentai/bloc/DoujinshiListBloc.dart';
import 'package:nhentai/component/doujinshi/CoverImage.dart';
import 'package:nhentai/component/doujinshi/DateTimeSection.dart';
import 'package:nhentai/component/doujinshi/DownloadButton.dart';
import 'package:nhentai/component/doujinshi/FavoriteToggleButton.dart';
import 'package:nhentai/component/doujinshi/FirstTitle.dart';
import 'package:nhentai/component/doujinshi/HorizontalDoujinshiList.dart';
import 'package:nhentai/component/doujinshi/IDSection.dart';
import 'package:nhentai/component/doujinshi/PageCountSection.dart';
import 'package:nhentai/component/doujinshi/PreviewSection.dart';
import 'package:nhentai/component/doujinshi/SecondTitle.dart';
import 'package:nhentai/component/doujinshi/TagsSection.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/RecommendDoujinshiList.dart';
import 'package:nhentai/domain/entity/Tag.dart';
import 'package:nhentai/domain/usecase/GetRecommendedDoujinshiListUseCase.dart';
import 'package:nhentai/page/uimodel/ReadingModel.dart';

class DoujinshiPage extends StatefulWidget {
  final DoujinshiBloc doujinshiBloc;

  const DoujinshiPage({Key? key, required this.doujinshiBloc})
      : super(key: key);

  @override
  _DoujinshiPageState createState() => _DoujinshiPageState();
}

class _DoujinshiPageState extends State<DoujinshiPage> {
  late List<Widget> itemList;
  final DoujinshiListBloc recommendedDoujinshiListBloc = DoujinshiListBloc();
  GetRecommendedDoujinshiListUseCase _recommendedDoujinshiListUseCase =
      GetRecommendedDoujinshiListUseCase();

  void _getRecommendedList(int doujinshiId) async {
    RecommendedDoujinshiList recommendedDoujinshiList =
        await _recommendedDoujinshiListUseCase.execute(doujinshiId);
    recommendedDoujinshiListBloc.updateData(recommendedDoujinshiList.result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: widget.doujinshiBloc.output,
            initialData:
                ModalRoute.of(context)?.settings.arguments as Doujinshi,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Doujinshi doujinshi = snapshot.data;
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
    print('Test>>> backUpCoverImage ${doujinshi.backUpCoverImage}');
    itemList.add(CoverImage(
      coverImageUrl: doujinshi.coverImage,
      backUpCoverImageUrl: doujinshi.backUpCoverImage,
    ));
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
      itemList.add(
          TagsSection(tagName: tagName, tagList: tags != null ? tags : []));
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
        FavoriteToggleButton(),
        SizedBox(
          width: 10,
        ),
        DownloadButton()
      ],
    ));
    itemList.add(SizedBox(
      height: 10,
    ));
    itemList.add(PreviewSection(
      pages: doujinshi.previewThumbnailList,
      onPageSelected: (pageIndex) {
        Navigator.of(context).pushNamed(MainNavigator.DOUJINSHI_READER_PAGE,
            arguments:
                ReadingModel(doujinshi: doujinshi, startPageIndex: pageIndex));
      },
    ));
    itemList.add(SizedBox(
      height: 10,
    ));
    itemList.add(HorizontalDoujinshiList(
        doujinshiListBloc: recommendedDoujinshiListBloc,
        onDoujinshiSelected: (doujinshi) {
          widget.doujinshiBloc.updateData(doujinshi);
        }));
    itemList.add(SizedBox(
      height: 10,
    ));
    _getRecommendedList(doujinshi.id);
    return ListView(
      children: List.generate(itemList.length, (index) {
        return itemList[index];
      }),
    );
  }
}
