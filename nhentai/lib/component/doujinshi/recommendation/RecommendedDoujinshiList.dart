import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/analytics/AnalyticsUtils.dart';
import 'package:nhentai/component/doujinshi/HorizontalDoujinshiList.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/RecommendationType.dart';
import 'package:nhentai/component/doujinshi/recommendation/RecommendedDoujinshiListViewModel.dart';
import 'package:nhentai/page/uimodel/OpenDoujinshiModel.dart';
import 'package:nhentai/support/Extensions.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RecommendedDoujinshiList extends StatefulWidget {
  final String listName;
  final RecommendationType recommendationType;

  const RecommendedDoujinshiList(
      {Key? key, required this.listName, required this.recommendationType})
      : super(key: key);

  @override
  _RecommendedDoujinshiListState createState() =>
      _RecommendedDoujinshiListState();
}

class _RecommendedDoujinshiListState extends State<RecommendedDoujinshiList> {
  RecommendedDoujinshiListViewModel? _recommendedDoujinshiListViewModel;

  WebViewController? _recommendationWebViewController;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
    _recommendedDoujinshiListViewModel = RecommendedDoujinshiListViewModelImpl(
        name: widget.listName, recommendationType: widget.recommendationType);
    _recommendedDoujinshiListViewModel?.init();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        BlocConsumer(
          bloc: _recommendedDoujinshiListViewModel?.recommendedUrl(),
          listener: (context, String url) {
            log('Test>>> Recommend url=$url');
            _recommendationWebViewController?.loadUrl(url);
          },
          builder: (context, String url) {
            return url.isNotEmpty
                ? SizedBox(
                    width: 1,
                    height: 1,
                    child: WebView(
                      backgroundColor: Colors.transparent,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (controller) {
                        _recommendationWebViewController = controller;
                        _recommendationWebViewController?.loadUrl(url);
                      },
                      onPageFinished: (url) async {
                        try {
                          String? body =
                              await _recommendationWebViewController?.bodyJson;
                          if (body != null) {
                            log('Test>>> Recommend body=$body');
                            _recommendedDoujinshiListViewModel
                                ?.onDataLoaded(body);
                          }
                        } catch (error) {
                          print('Recommendation WebView error=$error');
                        }
                      },
                    ),
                  )
                : Visibility(
                    child: Container(),
                    visible: false,
                  );
          },
        ),
        Column(
          children: [
            HorizontalDoujinshiList(
                title: 'You may like these',
                doujinshiListCubit: _recommendedDoujinshiListViewModel!
                    .recommendedDoujinshisCubit(),
                onDoujinshiSelected: (doujinshi) async {
                  AnalyticsUtils.openRecommendedDoujinshi(doujinshi.id);
                  await Navigator.of(context).pushNamed(
                      MainNavigator.DOUJINSHI_PAGE,
                      arguments: OpenDoujinshiModel(
                          doujinshi: doujinshi, isSearchable: false));

                  Color statusBarColor = Constant.mainDarkColor;
                  if (widget.recommendationType == RecommendationType.Gallery) {
                    statusBarColor = Colors.black;
                  }
                  Future.delayed(Duration(milliseconds: 1)).then((value) =>
                      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                          statusBarColor: statusBarColor,
                          systemStatusBarContrastEnforced: true)));
                }),
            BlocBuilder(
                bloc: _recommendedDoujinshiListViewModel!
                    .recommendedDoujinshisCubit(),
                builder: (context, List<Doujinshi> list) {
                  return Visibility(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              splashRadius: 25,
                              icon: Icon(
                                Icons.refresh,
                                size: 30,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _recommendedDoujinshiListViewModel
                                    ?.refreshCurrentList();
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    visible: list.isNotEmpty,
                  );
                })
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _recommendedDoujinshiListViewModel?.destroy();
  }
}
