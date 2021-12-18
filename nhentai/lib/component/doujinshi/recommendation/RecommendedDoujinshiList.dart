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

class RecommendedDoujinshiList extends StatefulWidget {
  final RecommendationType recommendationType;

  const RecommendedDoujinshiList({Key? key, required this.recommendationType})
      : super(key: key);

  @override
  _RecommendedDoujinshiListState createState() =>
      _RecommendedDoujinshiListState();
}

class _RecommendedDoujinshiListState extends State<RecommendedDoujinshiList> {
  RecommendedDoujinshiListViewModel? _recommendedDoujinshiListViewModel;

  @override
  void initState() {
    super.initState();
    _recommendedDoujinshiListViewModel =
        RecommendedDoujinshiListViewModelImpl();
    _recommendedDoujinshiListViewModel?.init(widget.recommendationType);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HorizontalDoujinshiList(
            title: 'You may like these',
            doujinshiListCubit: _recommendedDoujinshiListViewModel!
                .recommendedDoujinshisCubit(),
            onDoujinshiSelected: (doujinshi) async {
              AnalyticsUtils.openRecommendedDoujinshi(doujinshi.id);
              await Navigator.of(context).pushNamed(
                  MainNavigator.DOUJINSHI_PAGE,
                  arguments: doujinshi);

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
                          icon: Icon(
                            Icons.refresh,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _recommendedDoujinshiListViewModel
                                ?.init(widget.recommendationType);
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
    );
  }

  @override
  void dispose() {
    super.dispose();
    _recommendedDoujinshiListViewModel?.destroy();
  }
}
