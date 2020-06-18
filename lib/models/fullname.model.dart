class FullName {
  String fio;
  List<String> get _arr => fio.split(' ');

  String get last => _arr.first;
  String get first => _arr.length > 1 ? _arr[1] : '';

  FullName({this.fio = ''});

  get isEmpty => fio == null || fio == '';
}
