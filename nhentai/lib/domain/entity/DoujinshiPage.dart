class DoujinshiPage {
  late String t;
  late int w;
  late int h;

  DoujinshiPage({required this.t, required this.w, required this.h});

  DoujinshiPage.fromJson(Map<String, dynamic> json) {
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
