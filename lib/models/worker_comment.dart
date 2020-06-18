import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerComment {
  final double stars;
  final String customerFullName;
  final String text;

  WorkerComment(this.stars, this.customerFullName, this.text);

  static WorkerComment fromSnapshot(DocumentSnapshot snaphot) {
    return WorkerComment(
        _getRating(snaphot), snaphot['customer']['fullName'], snaphot['text']);
  }

  static _getRating(DocumentSnapshot sn) {
    final r = sn['rating'];
    if (r == null) {
      return 0;
    }

    return r / 1;
  }
}
