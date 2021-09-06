class Title {
  late String english;
  late String japanese;
  late String pretty;

  Title({required this.english, required this.japanese, required this.pretty});

  Title.fromJson(Map<String, dynamic> json) {
    english = json['english'];
    japanese = json['japanese'] != null ? json['japanese'] : '';
    pretty = json['pretty'] != null ? json['pretty'] : '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['english'] = this.english;
    data['japanese'] = this.japanese;
    data['pretty'] = this.pretty;
    return data;
  }
}
