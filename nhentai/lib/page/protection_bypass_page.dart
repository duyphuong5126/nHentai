import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nhentai/support/Extensions.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../MainNavigator.dart';
import '../domain/entity/DoujinshiList.dart';

class ProtectionByPassPage extends StatefulWidget {
  const ProtectionByPassPage({Key? key}) : super(key: key);

  @override
  State<ProtectionByPassPage> createState() => _ProtectionByPassPageState();
}

class _ProtectionByPassPageState extends State<ProtectionByPassPage> {
  WebViewController? _galleryController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ByPassing'),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: WebView(
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              _galleryController = controller;
            },
            initialUrl: 'https://nhentai.net/api/galleries/all?page=1',
            onPageFinished: (url) async {
              try {
                String? body = await _galleryController?.bodyJson;
                log('Test>>> Gallery url=$url, body=$body');
                if (body != null) {
                  DoujinshiList.fromJson(jsonDecode(body));
                  Navigator.of(context).pushNamed(
                    MainNavigator.HOME_PAGE,
                  );
                }
              } catch (error) {
                print('Gallery WebView error=$error');
                context.showErrorSnackBar('Gallery WebView error:\n$error');
              }
            },
            onWebResourceError: (error) {
              print('Gallery WebView resource error=$error');
              context
                  .showErrorSnackBar('Gallery WebView resource error:\n$error');
            }),
      ),
    );
  }
}
