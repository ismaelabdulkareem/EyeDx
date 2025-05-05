class fundus_Model {
  final String img;
  final String name;
  final String date;
  final String orginal;
  final String result;

  fundus_Model({
    required this.img,
    required this.name,
    required this.date,
    required this.orginal,
    required this.result,
  });

  factory fundus_Model.fromJson(Map<String, dynamic> json) {
    return fundus_Model(
      img: json['fImg'],
      name: json['fName'],
      date: json['fDate'],
      orginal: json['fOrginal'],
      result: json['fResult'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fImg': img,
      'fName': name,
      'fDate': date,
      'fOrginal': orginal,
      'fResult': result,
    };
  }
}
