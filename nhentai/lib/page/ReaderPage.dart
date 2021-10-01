import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:marquee/marquee.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/IntegerBloc.dart';
import 'package:nhentai/component/doujinshi/ReaderThumbnail.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/page/uimodel/ReadingModel.dart';
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

  final TransformationController _transformationController =
      TransformationController();
  late TapDownDetails _doubleTapDownDetails;
  late AnimationController _animationController;
  late Animation<Offset> _topSlideAnimation;
  late Animation<Offset> _bottomSlideAnimation;
  late ScrollController _scrollController;
  late ScrollController _thumbnailScrollController;

  final IntegerBloc _currentPageBloc = IntegerBloc();

  @override
  void initState() {
    super.initState();
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
    int maxThumbnailCount = doujinshi.fullSizePageUrlList.length;
    int reversePosition = -1;
    int forwardPosition = -1;
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Positioned.fill(
              child: Align(
            child: _buildReaderBody(doujinshi, readingModel.startPageIndex,
                (visiblePage) {
              _currentPageBloc.updateData(visiblePage);
              int jumpToPosition = visiblePage;
              ScrollDirection scrollDirection =
                  _scrollController.position.userScrollDirection;
              int jumpOffset = 3;
              print(
                  'visiblePage=$visiblePage, scrollDirection=$scrollDirection');
              if (scrollDirection == ScrollDirection.reverse) {
                jumpToPosition =
                    (jumpToPosition + jumpOffset < maxThumbnailCount)
                        ? jumpToPosition + jumpOffset
                        : maxThumbnailCount - 1;
                if (reversePosition == -1 || jumpToPosition > reversePosition) {
                  reversePosition = jumpToPosition;
                  forwardPosition = -1;
                  _thumbnailScrollController
                      .jumpTo(reversePosition * _DEFAULT_THUMBNAIL_WIDTH);
                }
              } else if (scrollDirection == ScrollDirection.forward) {
                jumpToPosition = (jumpToPosition - jumpOffset >= 0)
                    ? jumpToPosition - jumpOffset
                    : 0;
                if (forwardPosition == -1 || jumpToPosition < forwardPosition) {
                  forwardPosition = jumpToPosition;
                  reversePosition = -1;
                  _thumbnailScrollController
                      .jumpTo(forwardPosition * _DEFAULT_THUMBNAIL_WIDTH);
                }
              }
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
    );
  }

  @override
  void dispose() {
    super.dispose();
    _currentPageBloc.dispose();
    _scrollController.dispose();
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
                    Navigator.of(context).pop();
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
    _thumbnailScrollController = ScrollController(keepScrollOffset: false);
    return SlideTransition(
      position: _bottomSlideAnimation,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: ListView.builder(
                  controller: _thumbnailScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: doujinshi.previewThumbnailList.length,
                  itemBuilder: (BuildContext c, int index) {
                    String thumbnailUrl = doujinshi.previewThumbnailList[index];
                    return ReaderThumbnail(
                        thumbnailUrl: thumbnailUrl,
                        width: _DEFAULT_THUMBNAIL_WIDTH,
                        height: _DEFAULT_THUMBNAIL_HEIGHT,
                        thumbnailIndex: index,
                        onThumbnailSelected: (selectedIndex) {
                          print('selectedIndex=$selectedIndex');
                          /*_scrollController
                              .jumpTo(selectedIndex * _DEFAULT_ITEM_HEIGHT);
                          _currentPageBloc.updateData(selectedIndex);*/
                        },
                        selectedIndexBloc: _currentPageBloc);
                  }),
              constraints:
                  BoxConstraints.expand(height: _DEFAULT_THUMBNAIL_HEIGHT),
            ),
            Row(
              children: [
                Container(
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 25,
                      )),
                  padding: EdgeInsets.symmetric(horizontal: 5),
                ),
                Expanded(
                    child: StreamBuilder(
                  stream: _currentPageBloc.output,
                  initialData: 0,
                  builder: (BuildContext co, AsyncSnapshot snapshot) {
                    int currentPage = snapshot.data;
                    return Text(
                      'Page ${currentPage + 1} of ${doujinshi.numPages}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: Constant.NUNITO_SEMI_BOLD,
                          fontSize: 18,
                          color: Colors.white),
                    );
                  },
                )),
                Container(
                  child: IconButton(
                      onPressed: () {},
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
        ),
        constraints: BoxConstraints.expand(height: 150),
        color: Constant.black96000000,
      ),
    );
  }

  Widget _buildReaderBody(
      Doujinshi doujinshi, int startPageIndex, Function(int) onPageVisible) {
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
        child: _buildVerticalReader(doujinshi, startPageIndex, onPageVisible),
      ),
    );
  }

  Widget _buildVerticalReader(
      Doujinshi doujinshi, int startPageIndex, Function(int) onPageVisible) {
    double initialScrollOffset = _DEFAULT_ITEM_HEIGHT * startPageIndex;
    double height = MediaQuery.of(context).size.height;
    _scrollController =
        ScrollController(initialScrollOffset: initialScrollOffset);
    return ListView.builder(
      controller: _scrollController,
      itemCount: doujinshi.fullSizePageUrlList.length,
      itemBuilder: (BuildContext buildContext, int index) {
        return VisibilityDetector(
          key: ValueKey(index),
          onVisibilityChanged: (VisibilityInfo info) {
            if (_scrollController.position.userScrollDirection !=
                ScrollDirection.idle) {
              onPageVisible((info.key as ValueKey).value);
            }
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
        );
      },
      cacheExtent: height * _EXTENT_CACHE_FACTOR,
    );
  }
}
