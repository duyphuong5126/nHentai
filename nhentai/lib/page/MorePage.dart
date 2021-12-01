import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/DefaultScreenTitle.dart';
import 'package:nhentai/domain/entity/masterdata/Version.dart';
import 'package:nhentai/domain/usecase/GetActiveVersionUseCase.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final GetActiveVersionUseCase _getActiveVersionUseCase =
      GetActiveVersionUseCaseImpl();
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  final DataCubit<bool> _isCensoredCubit = DataCubit(false);
  final DataCubit<PackageInfo> _packageCubit = DataCubit(
      PackageInfo(appName: '', packageName: '', version: '', buildNumber: ''));

  final DataCubit<Version?> _newVersionCubit = DataCubit(null);

  void _initCensoredStatus() async {
    _isCensoredCubit.emit(await _preferenceManager.isCensored());
  }

  void _initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print(
        'appName=${packageInfo.appName},packageName=${packageInfo.packageName},version=${packageInfo.version},buildNumber=${packageInfo.buildNumber}');
    _packageCubit.emit(packageInfo);
  }

  void _initActiveVersion() async {
    _getActiveVersionUseCase.execute().listen((activeVersion) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      print(
          'active version=${activeVersion.appVersionCode}, installed version=${packageInfo.version}');
      if (packageInfo.version != activeVersion.appVersionCode &&
          activeVersion.isActivated) {
        _newVersionCubit.emit(activeVersion);
      }
    });
  }

  void _setCensoredStatus(bool isCensored) async {
    _preferenceManager.saveCensored(isCensored);
    _isCensoredCubit.emit(isCensored);
  }

  @override
  Widget build(BuildContext context) {
    _initCensoredStatus();
    _initPackageInfo();
    _initActiveVersion();
    return Scaffold(
      appBar: AppBar(
        title: DefaultScreenTitle('Settings'),
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
                    bloc: _packageCubit,
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
                  child: BlocBuilder(
                      bloc: _isCensoredCubit,
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
                                value: isCensored,
                                onChanged: _setCensoredStatus)
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
                      bloc: _newVersionCubit,
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
                              onPressed: () => launch(url),
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
}
