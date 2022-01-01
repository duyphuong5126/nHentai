import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/ConfirmationAlertDialog.dart';
import 'package:nhentai/component/doujinshi/DownloadedReaderThumbnail.dart';
import 'package:nhentai/component/doujinshi/ReaderThumbnail.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshi.dart';
import 'package:nhentai/domain/usecase/StoreReadDoujinshiUseCase.dart';
import 'package:nhentai/page/uimodel/ReaderType.dart';
import 'package:nhentai/page/uimodel/ReadingModel.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share/share.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({Key? key}) : super(key: key);

  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage>
    with SingleTickerProviderStateMixin {
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
  final ItemScrollController _pageScrollController = ItemScrollController();
  final ItemPositionsListener _pageIndexListener =
      ItemPositionsListener.create();
  final ItemScrollController _thumbnailScrollController =
      ItemScrollController();
  final ItemPositionsListener _thumbnailIndexListener =
      ItemPositionsListener.create();
  PageController? _pageController;

  DataCubit<int>? _currentPageCubit = DataCubit<int>(-1);
  DataCubit<ReaderType>? _readerTypeCubit =
      DataCubit<ReaderType>(ReaderType.LeftToRight);
  DataCubit<double>? _screenTransparencyCubit = DataCubit<double>(0);

  final DataCubit<bool> _isCensoredCubit = DataCubit(false);

  void _initCensoredStatus() async {
    _isCensoredCubit.emit(await _preferenceManager.isCensored());
  }

  void _iniReaderType() async {
    _readerTypeCubit?.emit(await _preferenceManager.getReaderType());
    _screenTransparencyCubit
        ?.emit(await _preferenceManager.getReaderTransparency());
  }

  void _storeReadDoujinshi(Doujinshi doujinshi, int lastReadPageIndex) async {
    _storeReadDoujinshiUseCase.execute(doujinshi, lastReadPageIndex);
  }

  void _scrollInitially(int startIndex) async {
    Future.delayed(Duration(seconds: 1))
        .then((value) => _pageScrollController.jumpTo(index: startIndex));
  }

  void _scrollToThumbnailIndex(int thumbnailIndex) async {
    Future.delayed(Duration(milliseconds: 200)).then((value) =>
        _thumbnailScrollController.scrollTo(
            index: thumbnailIndex, duration: Duration(milliseconds: 200)));
  }

  @override
  void initState() {
    super.initState();
    _iniReaderType();
    _initCensoredStatus();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _topSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -5.0))
            .animate(_animationController);
    _bottomSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 5.0))
            .animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 1)).then((value) =>
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            systemStatusBarContrastEnforced: true)));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);

    ReadingModel readingModel =
        ModalRoute.of(context)?.settings.arguments as ReadingModel;
    Doujinshi doujinshi = readingModel.doujinshi;
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Positioned.fill(
              child: Align(
            child: _buildReaderBody(doujinshi, readingModel.startPageIndex,
                (visiblePage) {
              _currentPageCubit?.emit(visiblePage);
              _scrollToThumbnailIndex(visiblePage);
              _storeReadDoujinshi(doujinshi, visiblePage);
            }),
            alignment: Alignment.topLeft,
          )),
          Positioned.fill(
              child: Align(
            child: _buildReaderHeader(doujinshi),
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
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _currentPageCubit?.dispose();
    _currentPageCubit = null;
    _readerTypeCubit?.dispose();
    _readerTypeCubit = null;
    _screenTransparencyCubit?.dispose();
    _screenTransparencyCubit = null;
    _pageController?.dispose();
    _pageController = null;
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

  Widget _buildReaderHeader(Doujinshi doujinshi) {
    return SlideTransition(
      position: _topSlideAnimation,
      child: Container(
        child: Row(
          children: [
            Padding(
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 25,
                    )),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5),
            ),
            Expanded(
                child: Marquee(
              text: doujinshi.title.english,
              style: TextStyle(
                  fontFamily: Constant.ITALIC,
                  fontSize: 20,
                  color: Colors.white),
            )),
            Padding(
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                    onPressed: () {
                      Share.share(doujinshi.shareUrl,
                          subject: doujinshi.title.pretty);
                    },
                    icon: Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 25,
                    )),
              ),
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
                  child: ScrollablePositionedList.separated(
                      reverse: readerType == ReaderType.RightToLeft,
                      itemScrollController: _thumbnailScrollController,
                      itemPositionsListener: _thumbnailIndexListener,
                      scrollDirection: Axis.horizontal,
                      itemCount: doujinshi.previewThumbnailList.length,
                      separatorBuilder: (BuildContext c, int index) {
                        return SizedBox(
                          width: 5,
                        );
                      },
                      itemBuilder: (BuildContext c, int index) {
                        String thumbnailPath = doujinshi is DownloadedDoujinshi
                            ? doujinshi.downloadedPathList[index]
                            : doujinshi.previewThumbnailList[index];
                        return doujinshi is DownloadedDoujinshi
                            ? DownloadedReaderThumbnail(
                                thumbnailPath: thumbnailPath,
                                width: _DEFAULT_THUMBNAIL_WIDTH,
                                height: _DEFAULT_THUMBNAIL_HEIGHT,
                                thumbnailIndex: index,
                                onThumbnailSelected: (selectedIndex) {
                                  _pageScrollController.jumpTo(
                                      index: selectedIndex);
                                  _pageController?.jumpToPage(selectedIndex);
                                  _currentPageCubit?.emit(selectedIndex);
                                },
                                selectedIndexBloc: _currentPageCubit!)
                            : ReaderThumbnail(
                                thumbnailUrl: thumbnailPath,
                                width: _DEFAULT_THUMBNAIL_WIDTH,
                                height: _DEFAULT_THUMBNAIL_HEIGHT,
                                thumbnailIndex: index,
                                onThumbnailSelected: (selectedIndex) {
                                  _pageScrollController.jumpTo(
                                      index: selectedIndex);
                                  _pageController?.jumpToPage(selectedIndex);
                                  _currentPageCubit?.emit(selectedIndex);
                                },
                                selectedIndexBloc: _currentPageCubit!);
                      }),
                  constraints:
                      BoxConstraints.expand(height: _DEFAULT_THUMBNAIL_HEIGHT),
                ),
                Row(
                  children: [
                    Padding(
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                            onPressed: () => _showBookMarkComingSoonDialog(),
                            icon: Icon(
                              Icons.bookmark,
                              color: Colors.white,
                              size: 25,
                            )),
                      ),
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
                                  fontFamily: Constant.REGULAR,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            Text(
                              'Current direction: ${Constant.READER_TYPES[readerType]}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: Constant.BOLD,
                                  fontSize: 14,
                                  color: Colors.white),
                            )
                          ],
                        );
                      },
                    )),
                    Container(
                      child: Material(
                        color: Colors.transparent,
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
                      ),
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
    List<String> pageUrlList = doujinshi is DownloadedDoujinshi
        ? doujinshi.downloadedPathList
        : doujinshi.fullSizePageUrlList;
    return PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pageUrlList.length,
        reverse: reserve,
        controller: _pageController,
        onPageChanged: onPageVisible,
        itemBuilder: (BuildContext c, int index) {
          print('ReaderPage: horizontal - ${pageUrlList[index]}');
          Widget pageWidget = Container(
            child: doujinshi is DownloadedDoujinshi
                ? Image.file(
                    File(pageUrlList[index]),
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      Constant.IMAGE_NOTHING,
                      fit: BoxFit.fitWidth,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: pageUrlList[index],
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
                                fontFamily: Constant.BOLD,
                                color: Colors.white),
                          ),
                        ),
                        constraints:
                            BoxConstraints.expand(height: _DEFAULT_ITEM_HEIGHT),
                      );
                    },
                  ),
          );
          return BlocBuilder(
              bloc: _isCensoredCubit,
              builder: (BuildContext context, bool isCensored) {
                return isCensored
                    ? Container(
                        constraints: BoxConstraints.expand(),
                        color: Constant.grey4D4D4D,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.block,
                          size: 100,
                          color: Constant.mainColor,
                        ),
                      )
                    : pageWidget;
              });
        });
  }

  Widget _buildVerticalReader(
      Doujinshi doujinshi, int startPageIndex, Function(int) onPageVisible) {
    _pageController = null;
    List<String> pageUrlList = doujinshi is DownloadedDoujinshi
        ? doujinshi.downloadedPathList
        : doujinshi.fullSizePageUrlList;
    _scrollInitially(startPageIndex);
    return ScrollablePositionedList.builder(
      itemScrollController: _pageScrollController,
      itemPositionsListener: _pageIndexListener,
      itemCount: pageUrlList.length,
      itemBuilder: (BuildContext buildContext, int index) {
        print('ReaderPage: vertical - ${pageUrlList[index]}');
        return VisibilityDetector(
          key: ValueKey(index),
          onVisibilityChanged: (VisibilityInfo info) {
            onPageVisible((info.key as ValueKey).value);
          },
          child: BlocBuilder(
              bloc: _isCensoredCubit,
              builder: (BuildContext context, bool isCensored) {
                return isCensored
                    ? Container(
                        constraints: BoxConstraints.expand(height: 300),
                        color: Constant.grey4D4D4D,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.block,
                          size: 50,
                          color: Constant.mainColor,
                        ),
                        margin: EdgeInsets.only(bottom: 10),
                      )
                    : Container(
                        child: doujinshi is DownloadedDoujinshi
                            ? Image.file(
                                File(pageUrlList[index]),
                                fit: BoxFit.fitWidth,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  Constant.IMAGE_NOTHING,
                                  fit: BoxFit.fitWidth,
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: pageUrlList[index],
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  Constant.IMAGE_NOTHING,
                                  fit: BoxFit.fitWidth,
                                ),
                                fit: BoxFit.fitWidth,
                                placeholder:
                                    (BuildContext context, String url) {
                                  return Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontFamily: Constant.BOLD,
                                            color: Colors.white),
                                      ),
                                    ),
                                    constraints: BoxConstraints.expand(
                                        height: _DEFAULT_ITEM_HEIGHT),
                                  );
                                },
                              ),
                        margin: EdgeInsets.only(bottom: 10),
                      );
              }),
        );
      },
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
                        fontFamily: Constant.BOLD,
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
                        fontFamily: Constant.BOLD,
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
              fontFamily: Constant.BOLD, fontSize: 16, color: itemColor),
        ));
  }

  void _showBookMarkComingSoonDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlertDialog(
              title: 'Coming soon',
              content:
                  'The bookmark feature will be available soon. Stay tuned.',
              confirmLabel: 'OK',
              confirmAction: () {
                print('Bookmark feature coming soon message is confirmed');
              });
        });
  }
}
