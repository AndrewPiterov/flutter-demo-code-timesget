import 'package:timesget/services/preferenses.service.dart';
import 'package:rx_command/rx_command.dart';
import 'package:timesget/models/city.dart';

class ModelCommand {
  final RxCommand<City, City> updateCityCommand;

  // after city change, we have to update stream of ...
  //final RxCommand<City, Stream<QuerySnapshot>> getCompanyTypesCommand; // or get

  // final RxCommand<Null, City> getCityCommand;

  ModelCommand._(this.updateCityCommand); //this.getCityCommand

  factory ModelCommand() {
    // final _getCityCommand =
    //     RxCommand.createAsync2<City>(PrefsService.getCityPreferences);

    // final _getCompanyTypesCommand = RxCommand.createFromStream<City, Stream<QuerySnapshot>>(((city) =>
    //    Firestore.instance
    //       .collection('companyTypes')
    //       .document(city.countryId)
    //       .collection('types')
    //       .snapshots();
    //   ;
    // ));

    final _updateCityCommand =
        RxCommand.createAsync<City, City>(PrefsService.saveCityPreference);

    //_updateCityCommand.results;

    //_updateCityCommand(null);

    return ModelCommand._(
      _updateCityCommand,
    ); //_getCityCommand
  }
}
