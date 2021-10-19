import 'package:nhentai/page/uimodel/ReaderType.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceManager {
  static const String _READER_TYPE = 'reader_type';

  Future<ReaderType> getReaderType() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int typePosition = sharedPreferences.getInt(_READER_TYPE) ?? 0;
    return ReaderType.values[typePosition];
  }

  Future saveReaderType(ReaderType type) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(_READER_TYPE, type.index);
  }
}
