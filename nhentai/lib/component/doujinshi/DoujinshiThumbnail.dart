import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/custom_widget/TriangleBackgroundWidget.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiStatuses.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshi.dart';
import 'package:nhentai/domain/usecase/GetDoujinshiStatusesUseCase.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';

import 'Thumbnal.dart';

class DoujinshiThumbnail extends StatefulWidget {
  final Doujinshi doujinshi;
  final Function(Doujinshi) onDoujinshiSelected;
  final double? width;
  final double? height;
  final DataCubit<bool>? refreshStatusesSignalCubit;

  const DoujinshiThumbnail(
      {Key? key,
      required this.doujinshi,
      required this.onDoujinshiSelected,
      this.width,
      this.height,
      this.refreshStatusesSignalCubit})
      : super(key: key);

  @override
  _DoujinshiThumbnailState createState() => _DoujinshiThumbnailState();
}

class _DoujinshiThumbnailState extends State<DoujinshiThumbnail> {
  final GetDoujinshiStatusesUseCase _getDoujinshiStatusesUseCase =
      GetDoujinshiStatusesUseCaseImpl();

  final DataCubit<DoujinshiStatuses> _statusesCubit =
      DataCubit(DoujinshiStatuses());

  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  final DataCubit<bool> _isCensoredCubit = DataCubit(false);

  void _refreshDoujinshiStatus(int doujinshiId) async {
    DoujinshiStatuses statuses =
        await _getDoujinshiStatusesUseCase.execute(doujinshiId);
    _statusesCubit.push(statuses);
  }

  void _initCensoredStatus() async {
    _isCensoredCubit.push(await _preferenceManager.isCensored());
  }

  @override
  Widget build(BuildContext context) {
    Doujinshi doujinshi = widget.doujinshi;
    _initCensoredStatus();
    _refreshDoujinshiStatus(doujinshi.id);
    widget.refreshStatusesSignalCubit?.stream.listen((needRefreshStatuses) {
      if (needRefreshStatuses) {
        _refreshDoujinshiStatus(doujinshi.id);
        widget.refreshStatusesSignalCubit?.push(false);
      }
    });
    List<InlineSpan> spans = [];
    if (doujinshi.languageIcon.isNotEmpty) {
      spans.add(WidgetSpan(
          child: SizedBox(
        child: Container(
          child: Image.asset(doujinshi.languageIcon),
          margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
        ),
        width: 30,
        height: 15,
      )));
    }
    spans.add(TextSpan(text: doujinshi.title.english));
    return widget.width != null && widget.height != null
        ? _fixedSizeThumbnail(doujinshi, spans)
        : _unknownSizeThumbnail(doujinshi, spans);
  }

  Widget _fixedSizeThumbnail(Doujinshi doujinshi, List<InlineSpan> titleSpans) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(3)),
        child: Container(
          color: Constant.grey767676,
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Container(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    BlocBuilder(
                        bloc: _isCensoredCubit,
                        builder: (BuildContext context, bool isCensored) {
                          return isCensored
                              ? Container(
                                  width: 300,
                                  height: 300,
                                  color: Constant.grey767676,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.block,
                                    size: 50,
                                    color: Constant.mainColor,
                                  ),
                                )
                              : doujinshi is DownloadedDoujinshi
                                  ? Image.file(
                                      File(doujinshi.downloadedThumbnail),
                                      height: double.infinity,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        Constant.IMAGE_NOTHING,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    )
                                  : Thumbnail(
                                      thumbnailUrl: doujinshi.thumbnailImage,
                                    );
                        }),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                              color: Constant.black96000000,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(3),
                                  bottomRight: Radius.circular(3))),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          child: RichText(
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                style: TextStyle(
                                    fontFamily: Constant.BOLD,
                                    fontSize: 14,
                                    color: Colors.white),
                                children: titleSpans),
                          ),
                        ))
                      ],
                    )
                  ],
                ),
              ),
              BlocBuilder(
                  bloc: _statusesCubit,
                  builder: (BuildContext context, DoujinshiStatuses statuses) {
                    bool isRecentlyRead = statuses.lastReadPageIndex >= 0;
                    bool isFavorite = statuses.isFavorite;
                    IconData iconData =
                        isFavorite ? Icons.favorite : Icons.history;
                    Color color =
                        isFavorite ? Constant.mainColor : Constant.blue0673B7;
                    return Visibility(
                      child: TriangleBackgroundWidget(
                        width: 40,
                        height: 40,
                        color: color,
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          iconData,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      visible: isRecentlyRead || isFavorite,
                    );
                  }),
              Positioned.fill(
                  child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  highlightColor: Colors.white,
                  splashColor: Colors.white,
                  onTap: () => widget.onDoujinshiSelected(doujinshi),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _unknownSizeThumbnail(
      Doujinshi doujinshi, List<InlineSpan> titleSpans) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(3)),
        child: Container(
          color: Constant.grey767676,
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Container(
                constraints: BoxConstraints(minHeight: 100),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    BlocBuilder(
                        bloc: _isCensoredCubit,
                        builder: (BuildContext context, bool isCensored) {
                          return isCensored
                              ? Container(
                                  width: 300,
                                  height: 300,
                                  color: Constant.grey767676,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.block,
                                    size: 50,
                                    color: Constant.mainColor,
                                  ),
                                )
                              : doujinshi is DownloadedDoujinshi
                                  ? Image.file(
                                      File(doujinshi.downloadedThumbnail),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        Constant.IMAGE_NOTHING,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: doujinshi.thumbnailImage,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) {
                                        return Container(
                                          color: Constant.getNothingColor(),
                                          padding: EdgeInsets.all(5),
                                          child: Image.asset(
                                            Constant.IMAGE_NOTHING,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                    );
                        }),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                              color: Constant.black96000000,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(3),
                                  bottomRight: Radius.circular(3))),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          child: RichText(
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                style: TextStyle(
                                    fontFamily: Constant.BOLD,
                                    fontSize: 14,
                                    color: Colors.white),
                                children: titleSpans),
                          ),
                        ))
                      ],
                    )
                  ],
                ),
              ),
              BlocBuilder(
                  bloc: _statusesCubit,
                  builder: (BuildContext context, DoujinshiStatuses statuses) {
                    bool isRecentlyRead = statuses.lastReadPageIndex >= 0;
                    bool isFavorite = statuses.isFavorite;
                    IconData iconData =
                        isFavorite ? Icons.favorite : Icons.history;
                    Color color =
                        isFavorite ? Constant.mainColor : Constant.blue0673B7;
                    return Visibility(
                      child: TriangleBackgroundWidget(
                        width: 40,
                        height: 40,
                        color: color,
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          iconData,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      visible: isRecentlyRead || isFavorite,
                    );
                  }),
              Positioned.fill(
                  child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  splashColor: Colors.white,
                  onTap: () => widget.onDoujinshiSelected(doujinshi),
                ),
              ))
            ],
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _statusesCubit.close();
  }
}
