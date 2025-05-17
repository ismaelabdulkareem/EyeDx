import 'package:cloud_firestore/cloud_firestore.dart';

class fundus_Model {
  final String documentId;
  final String img;
  final String name;
  final String date;
  final String orginal;
  final String result;

  fundus_Model(
    this.documentId, {
    required this.img,
    required this.name,
    required this.date,
    required this.orginal,
    required this.result,
  });

  factory fundus_Model.fromDocumentSnapshot(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;

    return fundus_Model(
      doc.id, // 👈 this is the real document ID
      img: json['fImg'] ?? '',
      name: json['fName'] ?? '',
      date: json['fDate'] ?? '',
      orginal: json['fOrginal'] ?? '',
      result: json['fResult'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId, // ⚠️ this line causes the error
      'fImg': img,
      'fName': name,
      'fDate': date,
      'fOrginal': orginal,
      'fResult': result,
    };
  }
}
