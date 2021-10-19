import 'package:nhentai/page/uimodel/ReaderType.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceManager {
  static const String _READER_TYPE = 'reader_type';
  static const String _READER_TRANSPARENCY = 'reader_transparency';

  Future<ReaderType> getReaderType() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int typePosition = sharedPreferences.getInt(_READER_TYPE) ?? 0;
    return ReaderType.values[typePosition];
  }

  Future saveReaderType(ReaderType type) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(_READER_TYPE, type.index);
  }

  Future<double> getReaderTransparency() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getDouble(_READER_TRANSPARENCY) ?? 0;
  }

  Future saveReaderTransparency(double readerTransparency) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setDouble(_READER_TRANSPARENCY, readerTransparency);
  }
}
