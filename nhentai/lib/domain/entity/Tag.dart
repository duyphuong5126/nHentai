class Tag {
  late int id;
  late String type;
  late String name;
  late String url;
  late int count;

  Tag(
      {required this.id,
      required this.type,
      required this.name,
      required this.url,
      required this.count});

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    url = json['url'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['name'] = this.name;
    data['url'] = this.url;
    data['count'] = this.count;
    return data;
  }

  @override
  String toString() {
    return '(id=$id, type=$type, name=$name, url=$url, count=$count)';
  }
}
