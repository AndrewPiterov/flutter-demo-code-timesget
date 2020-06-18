import 'package:timesget/models/work_week.dart';

class ModelMapper{
  static WorkWeek workWeek(Map<String, dynamic> json) =>
      (!json.containsKey('workWeek') || json['workWeek'] == null)
          ? WorkWeek.empty
          : WorkWeek.fromJsonMap(json['workWeek']);
}