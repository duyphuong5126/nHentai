class Page {
  late String t;
  late int w;
  late int h;

  Page({required this.t, required this.w, required this.h});

  Page.fromJson(Map<String, dynamic> json) {
    t = json['t'];
    w = json['w'];
    h = json['h'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['t'] = this.t;
    data['w'] = this.w;
    data['h'] = this.h;
    return data;
  }
}
