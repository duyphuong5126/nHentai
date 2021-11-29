import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/DefaultScreenTitle.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';
import 'package:package_info/package_info.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  final DataCubit<bool> _isCensoredCubit = DataCubit(false);
  final DataCubit<PackageInfo> _packageCubit = DataCubit(
      PackageInfo(appName: '', packageName: '', version: '', buildNumber: ''));

  void _initCensoredStatus() async {
    _isCensoredCubit.emit(await _preferenceManager.isCensored());
  }

  void _initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print(
        'appName=${packageInfo.appName},packageName=${packageInfo.packageName},version=${packageInfo.version},buildNumber=${packageInfo.buildNumber}');
    _packageCubit.emit(packageInfo);
  }

  void _setCensoredStatus(bool isCensored) async {
    _preferenceManager.saveCensored(isCensored);
    _isCensoredCubit.emit(isCensored);
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 1)).then((value) =>
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Constant.mainDarkColor,
            systemStatusBarContrastEnforced: true)));
    _initCensoredStatus();
    _initPackageInfo();
    return Scaffold(
      appBar: AppBar(
        title: DefaultScreenTitle('Settings'),
        centerTitle: true,
        backgroundColor: Constant.mainColor,
      ),
      body: Container(
        color: Colors.black,
        child: ListView(
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
                        Switch(value: isCensored, onChanged: _setCensoredStatus)
                      ],
                    );
                  }),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(3))),
            )
          ],
        ),
      ),
    );
  }
}
