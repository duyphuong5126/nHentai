import 'package:nhentai/domain/entity/SearchHistoryItem.dart';

class SearchHistory {
  late List<SearchHistoryItem> history;

  SearchHistory({required this.history});

  SearchHistory.fromJson(Map<String, dynamic> json) {
    history = [];
    json['history'].forEach((dynamic historyItem) {
      history.add(SearchHistoryItem.fromJson(historyItem));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['history'] =
        history.map((historyItem) => historyItem.toJson()).toList();
    return data;
  }

  void prependSearchTerm(String searchTerm) {
    history.insert(
        0, SearchHistoryItem(searchTerm: searchTerm, searchTimes: 1));
  }
}
