import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/doujinshi/ReaderThumbnail.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/usecase/StoreReadDoujinshiUseCase.dart';
import 'package:nhentai/page/uimodel/ReaderType.dart';
import 'package:nhentai/page/uimodel/ReadingModel.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({Key? key}) : super(key: key);

  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage>
    with SingleTickerProviderStateMixin {
  static const int _EXTENT_CACHE_FACTOR = 4;
  static const double _DEFAULT_ITEM_HEIGHT = 300;
  static const double _DEFAULT_THUMBNAIL_WIDTH = 60;
  static const double _DEFAULT_THUMBNAIL_HEIGHT = 90;

  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  final StoreReadDoujinshiUseCase _storeReadDoujinshiUseCase =
      StoreReadDoujinshiUseCaseImpl();

  final TransformationController _transformationController =
      TransformationController();
  late TapDownDetails _doubleTapDownDetails;
  late AnimationController _animationController;
  late Animation<Offset> _topSlideAnimation;
  late Animation<Offset> _bottomSlideAnimation;
  late AutoScrollController _thumbnailScrollController;
  AutoScrollController? _scrollController;
  PageController? _pageController;

  DataCubit<int>? _currentPageCubit = DataCubit<int>(-1);
  DataCubit<ReaderType>? _readerTypeCubit =
      DataCubit<ReaderType>(ReaderType.LeftToRight);
  DataCubit<double>? _screenTransparencyCubit = DataCubit<double>(0);

  void _iniReaderType() async {
    _readerTypeCubit?.emit(await _preferenceManager.getReaderType());
    _screenTransparencyCubit
        ?.emit(await _preferenceManager.getReaderTransparency());
  }

  void _storeReadDoujinshi(Doujinshi doujinshi, int lastReadPageIndex) async {
    _storeReadDoujinshiUseCase.execute(doujinshi, lastReadPageIndex);
  }

  @override
  void initState() {
    super.initState();
    _iniReaderType();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _topSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -1.0))
            .animate(_animationController);
    _bottomSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
            .animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    ReadingModel readingModel =
        ModalRoute.of(context)?.settings.arguments as ReadingModel;
    Doujinshi doujinshi = readingModel.doujinshi;
    return WillPopScope(child: Scaffold(
      body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                  child: Align(
                    child: _buildReaderBody(doujinshi, readingModel.startPageIndex,
                            (visiblePage) {
                          _currentPageCubit?.emit(visiblePage);
                          _thumbnailScrollController.scrollToIndex(visiblePage);
                          _storeReadDoujinshi(doujinshi, visiblePage);
                        }),
                    alignment: Alignment.topLeft,
                  )),
              Positioned.fill(
                  child: Align(
                    child: _buildReaderHeader(doujinshi.title.english),
                    alignment: Alignment.topLeft,
                  )),
              Positioned.fill(
                  child: Align(
                    child: _buildReaderFooter(doujinshi),
                    alignment: Alignment.bottomLeft,
                  ))
            ],
          )),
      backgroundColor: Constant.grey1f1f1f,
    ), onWillPop: () => _onWillPop(context));
  }

  @override
  void dispose() {
    super.dispose();
    _currentPageCubit?.dispose();
    _currentPageCubit = null;
    _readerTypeCubit?.dispose();
    _readerTypeCubit = null;
    _screenTransparencyCubit?.dispose();
    _screenTransparencyCubit = null;
    _scrollController?.dispose();
    _scrollController = null;
    _pageController?.dispose();
    _pageController = null;
    _thumbnailScrollController.dispose();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    _doubleTapDownDetails = details;
  }

  void _onDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDownDetails.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  Widget _buildReaderHeader(String doujinshiTitle) {
    return SlideTransition(
      position: _topSlideAnimation,
      child: Container(
        child: Row(
          children: [
            Container(
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 25,
                  )),
              padding: EdgeInsets.symmetric(horizontal: 5),
            ),
            Expanded(
                child: Marquee(
              text: doujinshiTitle,
              style: TextStyle(
                  fontFamily: Constant.NUNITO_SEMI_BOLD,
                  fontSize: 20,
                  color: Colors.white),
            )),
            Container(
              child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.share,
                    color: Colors.white,
                    size: 25,
                  )),
              padding: EdgeInsets.symmetric(horizontal: 5),
            )
          ],
        ),
        color: Constant.black96000000,
        constraints: BoxConstraints.expand(height: 50),
      ),
    );
  }

  Widget _buildReaderFooter(Doujinshi doujinshi) {
    _thumbnailScrollController = AutoScrollController(keepScrollOffset: true);
    return SlideTransition(
      position: _bottomSlideAnimation,
      child: Container(
        child: BlocBuilder(
          bloc: _readerTypeCubit,
          builder: (BuildContext context, ReaderType readerType) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: ListView.separated(
                      reverse: readerType == ReaderType.RightToLeft,
                      controller: _thumbnailScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: doujinshi.previewThumbnailList.length,
                      separatorBuilder: (BuildContext c, int index) {
                        return SizedBox(
                          width: 5,
                        );
                      },
                      itemBuilder: (BuildContext c, int index) {
                        String thumbnailUrl =
                            doujinshi.previewThumbnailList[index];
                        return AutoScrollTag(
                          key: ValueKey(index),
                          controller: _thumbnailScrollController,
                          index: index,
                          child: ReaderThumbnail(
                              thumbnailUrl: thumbnailUrl,
                              width: _DEFAULT_THUMBNAIL_WIDTH,
                              height: _DEFAULT_THUMBNAIL_HEIGHT,
                              thumbnailIndex: index,
                              onThumbnailSelected: (selectedIndex) {
                                _scrollController?.scrollToIndex(selectedIndex);
                                _pageController?.jumpToPage(selectedIndex);
                                _currentPageCubit?.emit(selectedIndex);
                              },
                              selectedIndexBloc: _currentPageCubit!),
                        );
                      }),
                  constraints:
                      BoxConstraints.expand(height: _DEFAULT_THUMBNAIL_HEIGHT),
                ),
                Row(
                  children: [
                    Container(
                      child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 25,
                          )),
                      padding: EdgeInsets.symmetric(horizontal: 5),
                    ),
                    Expanded(
                        child: BlocBuilder(
                      bloc: _currentPageCubit!,
                      builder: (BuildContext co, int currentPage) {
                        return Column(
                          children: [
                            Text(
                              'Page ${currentPage + 1} of ${doujinshi.numPages}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: Constant.NUNITO_SEMI_BOLD,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            Text(
                              'Current direction: ${Constant.READER_TYPES[readerType]}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: Constant.NUNITO_SEMI_BOLD,
                                  fontSize: 14,
                                  color: Colors.white),
                            )
                          ],
                        );
                      },
                    )),
                    Container(
                      child: IconButton(
                          onPressed: () {
                            Radius topCornersRadius = Radius.circular(10);
                            showModalBottomSheet(
                                enableDrag: false,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: topCornersRadius,
                                        topRight: topCornersRadius)),
                                backgroundColor: Constant.grey4D4D4D,
                                barrierColor: Colors.transparent,
                                context: context,
                                builder: (context) {
                                  return _buildSettingsBottomSheet();
                                });
                          },
                          icon: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 25,
                          )),
                      padding: EdgeInsets.symmetric(horizontal: 5),
                    )
                  ],
                ),
              ],
            );
          },
        ),
        constraints: BoxConstraints.expand(height: 160),
        color: Constant.black96000000,
        padding: EdgeInsets.only(bottom: 10, top: 10),
      ),
    );
  }

  Widget _buildReaderBody(
      Doujinshi doujinshi, int startPageIndex, Function(int) onPageVisible) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return BlocBuilder(
        buildWhen: (ReaderType prevType, ReaderType newType) {
          return newType != prevType;
        },
        bloc: _readerTypeCubit,
        builder: (BuildContext c, ReaderType readerType) {
          Widget readerBody = (readerType == ReaderType.TopDown)
              ? _buildVerticalReader(doujinshi, startPageIndex, onPageVisible)
              : _buildHorizontalReader(doujinshi, startPageIndex, onPageVisible,
                  readerType == ReaderType.RightToLeft);
          return GestureDetector(
            onDoubleTapDown: _onDoubleTapDown,
            onDoubleTap: _onDoubleTap,
            onTap: () {
              switch (_animationController.status) {
                case AnimationStatus.completed:
                  {
                    _animationController.reverse();
                    break;
                  }

                case AnimationStatus.dismissed:
                  {
                    _animationController.forward();
                    break;
                  }
                default:
                  break;
              }
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4,
              panEnabled: true,
              child: BlocBuilder(
                buildWhen: (double preTransparency, double newTransparency) {
                  return preTransparency != newTransparency;
                },
                bloc: _screenTransparencyCubit,
                builder: (BuildContext c, double transparency) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      readerBody,
                      IgnorePointer(
                        child: Container(
                          color: Color.fromARGB(transparency.toInt(), 0, 0, 0),
                          width: screenWidth,
                          height: screenHeight,
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          );
        });
  }

  Widget _buildHorizontalReader(Doujinshi doujinshi, int startPageIndex,
      Function(int) onPageVisible, bool reserve) {
    if (_pageController == null) {
      _pageController = PageController(initialPage: startPageIndex);
    }
    onPageVisible(startPageIndex);
    return PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: doujinshi.fullSizePageUrlList.length,
        reverse: reserve,
        controller: _pageController,
        onPageChanged: onPageVisible,
        itemBuilder: (BuildContext c, int index) {
          return Container(
            child: CachedNetworkImage(
              imageUrl: doujinshi.fullSizePageUrlList[index],
              errorWidget: (context, url, error) => Image.asset(
                Constant.IMAGE_NOTHING,
                fit: BoxFit.fitWidth,
              ),
              fit: BoxFit.fitWidth,
              placeholder: (BuildContext context, String url) {
                return Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: Constant.NUNITO_BLACK,
                          color: Colors.white),
                    ),
                  ),
                  constraints:
                      BoxConstraints.expand(height: _DEFAULT_ITEM_HEIGHT),
                );
              },
            ),
            margin: EdgeInsets.only(bottom: 10),
          );
        });
  }

  Widget _buildVerticalReader(
      Doujinshi doujinshi, int startPageIndex, Function(int) onPageVisible) {
    double initialScrollOffset = _DEFAULT_ITEM_HEIGHT * startPageIndex;
    double height = MediaQuery.of(context).size.height;
    _scrollController =
        AutoScrollController(initialScrollOffset: initialScrollOffset);
    _pageController = null;
    return ListView.builder(
      controller: _scrollController,
      itemCount: doujinshi.fullSizePageUrlList.length,
      itemBuilder: (BuildContext buildContext, int index) {
        return AutoScrollTag(
          key: ValueKey(index),
          controller: _scrollController!,
          index: index,
          child: VisibilityDetector(
            key: ValueKey(index),
            onVisibilityChanged: (VisibilityInfo info) {
              onPageVisible((info.key as ValueKey).value);
            },
            child: Container(
              child: CachedNetworkImage(
                imageUrl: doujinshi.fullSizePageUrlList[index],
                errorWidget: (context, url, error) => Image.asset(
                  Constant.IMAGE_NOTHING,
                  fit: BoxFit.fitWidth,
                ),
                fit: BoxFit.fitWidth,
                placeholder: (BuildContext context, String url) {
                  return Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                            fontSize: 24,
                            fontFamily: Constant.NUNITO_BLACK,
                            color: Colors.white),
                      ),
                    ),
                    constraints:
                        BoxConstraints.expand(height: _DEFAULT_ITEM_HEIGHT),
                  );
                },
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
          ),
        );
      },
      cacheExtent: height * _EXTENT_CACHE_FACTOR,
    );
  }

  Widget _buildSettingsBottomSheet() {
    return Wrap(
      children: [
        Container(
          constraints: BoxConstraints(minWidth: double.infinity, minHeight: 80),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reading type',
                    style: TextStyle(
                        fontFamily: Constant.NUNITO_SEMI_BOLD,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  BlocBuilder(
                      buildWhen: (ReaderType prevType, ReaderType newType) {
                        return newType != prevType;
                      },
                      bloc: _readerTypeCubit,
                      builder: (BuildContext b, ReaderType selectedType) {
                        return DropdownButton<ReaderType>(
                            value: selectedType,
                            icon: Icon(Icons.keyboard_arrow_down),
                            iconSize: 18,
                            onChanged: (newType) {
                              if (newType != null) {
                                _preferenceManager.saveReaderType(newType);
                                _readerTypeCubit?.emit(newType);
                              }
                            },
                            items: ReaderType.values
                                .map((readerType) => generateDropDownItem(
                                    readerType, readerType == selectedType))
                                .toList());
                      })
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Eye comfort',
                    style: TextStyle(
                        fontFamily: Constant.NUNITO_SEMI_BOLD,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  BlocBuilder(
                      buildWhen:
                          (double preTransparency, double newTransparency) {
                        return preTransparency != newTransparency;
                      },
                      bloc: _screenTransparencyCubit,
                      builder: (BuildContext c, double transparency) {
                        return Expanded(
                            child: Container(
                          child: Slider(
                            value: transparency,
                            min: 0,
                            max: 255,
                            onChanged: (double value) {
                              _screenTransparencyCubit?.emit(value);
                              _preferenceManager.saveReaderTransparency(value);
                            },
                          ),
                          margin: EdgeInsets.only(left: 10),
                        ));
                      })
                ],
              )
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        )
      ],
    );
  }

  DropdownMenuItem<ReaderType> generateDropDownItem(
      ReaderType readerType, bool isSelected) {
    Color itemColor = isSelected ? Constant.mainColor : Constant.grey767676;
    return DropdownMenuItem<ReaderType>(
        value: readerType,
        child: Text(
          Constant.READER_TYPES[readerType]!,
          style: TextStyle(
              fontFamily: Constant.NUNITO_SEMI_BOLD,
              fontSize: 16,
              color: itemColor),
        ));
  }

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.of(context).pop(true);
    return false;
  }
}
