import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/models/work_week.dart';

class HotOffer {
  final String id;
  final Worker worker;
  final Timestamp dateTime;
  final Time time;
  final num discount;

  HotOffer({this.id, this.worker, this.dateTime, this.time, this.discount});

  static HotOffer fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data;
    final dateTime = data['dateTime'];
    final time = Time.fromStr(data['startTime']);
    final discount = data['discount'];
    final doc = Map<String, dynamic>();

    data.forEach((k, v) {
      if (k == 'worker') {
        (v as Map).forEach((x, y) {
          doc[x.toString()] = y;
        });
      }
    });

    final worker = Worker.fromJsonMap(doc);

    return HotOffer(
        id: snap.documentID,
        worker: worker,
        dateTime: dateTime,
        time: time,
        discount: discount);
  }
}
