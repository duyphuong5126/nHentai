import 'package:nhentai/Constant.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';

class UrlBuilder {
  static String buildGalleryUrl(
      int page, String searchTerm, SortOption sortOption) {
    String sortString = '';
    if (sortOption == SortOption.PopularToday) {
      sortString = '&sort=popular-today';
    } else if (sortOption == SortOption.PopularThisWeek) {
      sortString = '&sort=popular-week';
    } else if (sortOption == SortOption.PopularAllTime) {
      sortString = '&sort=popular';
    }
    return searchTerm.isEmpty
        ? '${Constant.NHENTAI_HOME}/api/galleries/all?page=$page' + sortString
        : '${Constant.NHENTAI_HOME}/api/galleries/search?query=${searchTerm.replaceAll(' ', '+').toLowerCase()}&page=$page' +
            sortString;
  }

  static String buildDetailRecommendationUrl(int doujinshiId) =>
      '${Constant.NHENTAI_HOME}/api/gallery/$doujinshiId/related';

  static String buildDetailUrl(int doujinshiId) =>
      '${Constant.NHENTAI_HOME}/api/gallery/$doujinshiId';

  static String buildCommentListUrl(int doujinshiId) =>
      '${Constant.NHENTAI_HOME}/api/gallery/$doujinshiId/comments';
}
