import 'package:flutter/material.dart';
import 'package:timesget/models/city_bloc.dart';
import 'package:timesget/models/model_command.dart';
import 'package:timesget/services/app_message.service.dart';

typedef void AppNavigatorCallback(Widget page, int index);

class AppNavigator {
  AppNavigatorCallback _navigator;
  // GlobalKey<ScaffoldState> _scaffoldKey;

  setNavigator(
      AppNavigatorCallback callback, GlobalKey<ScaffoldState> scaffoldKey) {
    _navigator = callback;
    // _scaffoldKey = scaffoldKey;
  }

  push(page) {
    if (_navigator == null) {
      return;
    }
    _navigator(page, 999);
  }

  // void tooltip(BuildContext context,
  //     {String title, String body, String type = 'info', Duration showTime}) {

  //   AppTooltip().show(context, _scaffoldKey,
  //       title: title, body: body, showTime: showTime);
  // }
}

class ModelProvider extends InheritedWidget {
  final ModelBloc cityBloc;
  final ModelCommand modelCommand;
  AppMessageService messanger;

  AppNavigator navigator;

  static ModelBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(ModelProvider) as ModelProvider)
          .cityBloc;

  static ModelCommand commandOf(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(ModelProvider) as ModelProvider)
          .modelCommand;

  static AppNavigator navogatorOf(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(ModelProvider) as ModelProvider)
          .navigator;

  ModelProvider(
      {Key key,
      @required this.cityBloc,
      @required this.modelCommand,
      @required Widget child})
      : assert(modelCommand != null),
        assert(cityBloc != null),
        super(key: key, child: child) {
    this.navigator = AppNavigator();
    this.messanger = AppMessageService();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
