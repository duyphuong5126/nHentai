import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/domain/entity/masterdata/Version.dart';
import 'package:nhentai/domain/usecase/DownloadActiveApkUseCase.dart';
import 'package:nhentai/domain/usecase/GetActiveVersionUseCase.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';
import 'package:package_info/package_info.dart';

abstract class MorePageViewModel {
  late DataCubit<bool> isCensoredCubit;
  late DataCubit<PackageInfo> packageCubit;
  late DataCubit<Version?> newVersionCubit;
  late DataCubit<String?> loadingCubit;
  late DataCubit<String?> apkPathCubit;

  void setUp();

  void initStates();

  void setCensoredStatus(bool isCensored);

  void installAndroidVersion(Version version);
}

class MorePageViewModelImpl extends MorePageViewModel {
  final GetActiveVersionUseCase _getActiveVersionUseCase =
      GetActiveVersionUseCaseImpl();
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  final DownloadActiveApkUseCase _downloadActiveApkUseCase =
      DownloadActiveApkUseCaseImpl();

  @override
  void setUp() {
    isCensoredCubit = DataCubit(false);
    packageCubit = DataCubit(PackageInfo(
        appName: '', packageName: '', version: '', buildNumber: ''));
    newVersionCubit = DataCubit(null);
    loadingCubit = DataCubit(null);
    apkPathCubit = DataCubit(null);
  }

  @override
  void initStates() async {
    isCensoredCubit.push(await _preferenceManager.isCensored());

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print(
        'appName=${packageInfo.appName},packageName=${packageInfo.packageName},version=${packageInfo.version},buildNumber=${packageInfo.buildNumber}');
    packageCubit.push(packageInfo);

    _getActiveVersionUseCase.execute().listen((activeVersion) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      print(
          'active version=${activeVersion.appVersionCode}, installed version=${packageInfo.version}');
      if (packageInfo.version != activeVersion.appVersionCode &&
          activeVersion.isActivated) {
        newVersionCubit.push(activeVersion);
      }
    });
  }

  @override
  void setCensoredStatus(bool isCensored) {
    _preferenceManager.saveCensored(isCensored);
    isCensoredCubit.push(isCensored);
  }

  @override
  void installAndroidVersion(Version version) {
    loadingCubit.push('Downloading apk file');
    _downloadActiveApkUseCase
        .execute(version.appVersionCode, version.downloadUrl)
        .listen((localApkPath) {
      loadingCubit.push(null);
      apkPathCubit.push(localApkPath);
    }, onDone: () {
      loadingCubit.push(null);
    }, onError: (error, stackTrace) {
      loadingCubit.push(null);
    });
  }
}
