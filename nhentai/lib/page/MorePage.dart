import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/DefaultScreenTitle.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  final DataCubit<bool> _isCensoredCubit = DataCubit(false);

  void _initCensoredStatus() async {
    _isCensoredCubit.emit(await _preferenceManager.isCensored());
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
                                fontFamily: Constant.NUNITO_SEMI_BOLD,
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
