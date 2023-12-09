import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/component/DefaultScreenTitle.dart';
import 'package:nhentai/component/LoadingMessage.dart';
import 'package:nhentai/domain/entity/masterdata/Version.dart';
import 'package:nhentai/page/more/MorePageViewModel.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  MorePageViewModel _viewModel = MorePageViewModelImpl();
  StreamSubscription? _localApkSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel.setUp();
    _localApkSubscription =
        _viewModel.apkPathCubit.stream.listen((String? apkFilePath) {
      if (apkFilePath != null) {
        OpenFile.open(apkFilePath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _viewModel.initStates();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: DefaultScreenTitle('About'),
        centerTitle: true,
        backgroundColor: Constant.mainColor,
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            ListView(
              children: [
                BlocBuilder(
                    bloc: _viewModel.packageCubit,
                    builder: (context, PackageInfo packageInfo) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            width: 80,
                            height: 80,
                            child: Center(
                              child: SvgPicture.asset(
                                Constant.IMAGE_LOGO,
                                width: 25,
                                height: 25,
                                fit: BoxFit.fill,
                              ),
                            ),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Constant.black96000000),
                          ),
                          Text(
                            'nhentai',
                            style: TextStyle(
                                fontFamily: Constant.BOLD,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                          Container(
                            child: Text(
                              'Version ${packageInfo.version}',
                              style: TextStyle(
                                  fontFamily: Constant.REGULAR,
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 10),
                          )
                        ],
                      );
                    }),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Support me on',
                        style: TextStyle(
                            fontFamily: Constant.BOLD,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkResponse(
                          highlightColor: Constant.mainDarkColor,
                          onTap: () =>
                              launch('https://www.patreon.com/nonoka9002'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              'Patreon',
                              style: TextStyle(
                                  fontFamily: Constant.BOLD,
                                  fontSize: 15,
                                  color: Constant.mainColor),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Contact me on',
                        style: TextStyle(
                            fontFamily: Constant.BOLD,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkResponse(
                          highlightColor: Constant.mainDarkColor,
                          onTap: () => launch('https://twitter.com/nonoka9002'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              'Twitter',
                              style: TextStyle(
                                  fontFamily: Constant.BOLD,
                                  fontSize: 15,
                                  color: Constant.mainColor),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'or',
                        style: TextStyle(
                            fontFamily: Constant.BOLD,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                      BlocBuilder(
                          bloc: _viewModel.packageCubit,
                          builder: (context, PackageInfo packageInfo) {
                            String platformName = Platform.isAndroid
                                ? 'android'
                                : Platform.isIOS
                                    ? 'iOS'
                                    : '';
                            String emailTemplate = 'mailto:nonoka9002@gmail.com'
                                '?subject=[nhentai $platformName]Feedback about version ${packageInfo.version}'
                                '&body=Tell me your feedbacks.';
                            return Material(
                              color: Colors.transparent,
                              child: InkResponse(
                                highlightColor: Constant.mainDarkColor,
                                onTap: () => launch(emailTemplate),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                        fontFamily: Constant.BOLD,
                                        fontSize: 15,
                                        color: Constant.mainColor),
                                  ),
                                ),
                              ),
                            );
                          })
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: BlocBuilder(
                      bloc: _viewModel.isCensoredCubit,
                      builder: (BuildContext c, bool isCensored) {
                        return Row(
                          children: [
                            Expanded(
                                child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                'Enable censorship',
                                style: TextStyle(
                                    fontFamily: Constant.BOLD,
                                    fontSize: 15,
                                    color: Constant.grey1f1f1f),
                              ),
                            )),
                            Switch(
                                thumbColor: MaterialStateProperty.resolveWith(
                                    (states) => _getSwitchThumbColor(states)),
                                trackColor: MaterialStateProperty.resolveWith(
                                    (states) => _getSwitchTrackColor(states)),
                                value: isCensored,
                                onChanged: _viewModel.setCensoredStatus)
                          ],
                        );
                      }),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(3))),
                )
              ],
            ),
            Container(
              constraints: BoxConstraints.expand(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BlocBuilder(
                    bloc: _viewModel.loadingCubit,
                    builder: (context, String? loadingMessage) {
                      String message = loadingMessage != null
                          ? loadingMessage
                          : 'Loading, please wait';
                      return Visibility(
                        child: LoadingMessage(loadingMessage: message),
                        visible: loadingMessage != null,
                      );
                    },
                  ),
                  BlocBuilder(
                      bloc: _viewModel.newVersionCubit,
                      builder: (BuildContext context, Version? newVersion) {
                        String buttonLabel = newVersion != null
                            ? 'Checkout version ${newVersion.appVersionCode}'
                            : '';
                        String url =
                            newVersion != null ? newVersion.detailsUrl : '';
                        return Visibility(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            constraints: BoxConstraints.expand(height: 40),
                            child: MaterialButton(
                              child: Text(
                                buttonLabel,
                                style: TextStyle(
                                    fontFamily: Constant.BOLD,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                              color: Constant.mainColor,
                              onPressed: () {
                                if (Platform.isAndroid && newVersion != null)
                                  _viewModel.installAndroidVersion(newVersion);
                                else
                                  launch(url);
                              },
                            ),
                          ),
                          visible: newVersion != null && newVersion.isActivated,
                        );
                      })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _localApkSubscription?.cancel();
    _localApkSubscription = null;
  }

  Color _getSwitchThumbColor(Set<MaterialState> states) {
    Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.selected
    };

    return states.any(interactiveStates.contains)
        ? Constant.mainColor
        : Colors.white;
  }

  Color _getSwitchTrackColor(Set<MaterialState> states) {
    Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.selected
    };

    return states.any(interactiveStates.contains)
        ? Constant.mainColorTransparent
        : Colors.grey;
  }
}
