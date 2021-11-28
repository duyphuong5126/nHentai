class SearchHistoryItem {
  late String searchTerm;
  late int searchTimes;

  SearchHistoryItem({required this.searchTerm, required this.searchTimes});

  SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    searchTerm = json['searchTerm'];
    searchTimes = int.parse(json['searchTimes'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['searchTerm'] = searchTerm;
    data['searchTimes'] = searchTimes;
    return data;
  }

  @override
  String toString() {
    return searchTerm;
  }

  bool match(String searchTerm) {
    return this.searchTerm.trim().toLowerCase().contains(searchTerm.trim().toLowerCase());
  }

  void increaseSearchTimes() => searchTimes++;
}
