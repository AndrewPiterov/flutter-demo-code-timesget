import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/dd_button_bordered.dart';
import 'package:timesget/models/worker_specialization.dart';
import 'package:timesget/services/workerSpecs.service.dart';

const _widgetName = "worker_specs_view";
String _translate(String key) {
  return allTranslations.concatText([_widgetName, key]);
}

typedef void WorkerSpecsDropDownButtonCallback(WorkerSpecialization spec);

class WorkerSpecsDropDownButton extends StatelessWidget {
  final WorkerSpecialization currentValue;
  final WorkerSpecsDropDownButtonCallback callback;
  final bool isHintCentered;
  final String hintText;
  final bool allChoose;

  WorkerSpecsDropDownButton(this.currentValue, this.callback,
      {this.isHintCentered = false, this.hintText, this.allChoose = true});

  @override
  Widget build(BuildContext context) {
    final stream = Observable(WorkerSpecs().specs$).flatMap((list) =>
        Stream.value(WorkerSpecs()
            .add(WorkerSpecialization(null, _translate('all')), onTop: true)));

    return AppDropDownButton<WorkerSpecialization>(
      AppDropDownButtonType.bordered,
      title: _translate('title'),
      initialValue: currentValue,
      hint:
          hintText == null || hintText.isEmpty ? _translate('hint') : hintText,
      isHintCentered: isHintCentered,
      stream: stream,
      getTitleDelegate: (spec) => spec.title,
      onChange: (spec) {
        callback(spec.id == null || spec.id == '' ? null : spec);
      },
    );
  }
}
