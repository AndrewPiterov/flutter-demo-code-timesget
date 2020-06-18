import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/rating_start_chooser.dart';
import 'package:timesget/components/tags/input.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

const _widgetName = "worker_comment_form";
String _translate(String key) {
  return allTranslations.concatText([_widgetName, key]);
}

class WorkerCommentFormDialog extends StatefulWidget {
  final Worker worker;
  WorkerCommentFormDialog(this.worker);

  @override
  _WorkerCommentFormDialogState createState() =>
      _WorkerCommentFormDialogState();
}

class _WorkerCommentFormDialogState extends State<WorkerCommentFormDialog> {
  var _rateValue = 0;
  var _name = '';
  var _email = '';
  var _text = '';

  var _isFormValid = false;

  TextEditingController _emailEditingController = TextEditingController();
  TextEditingController _nameEditingController = TextEditingController();
  TextEditingController _commentEditingController = TextEditingController();

  // EdgeInsetsGeometry _contentPadding = EdgeInsets.fromLTRB(
  //     16.0, AppConstants.sizeOf(49), 20.0, AppConstants.sizeOf(49));

  @override
  void initState() {
    super.initState();
    _emailEditingController.addListener(_onEmailChanged);
    _nameEditingController.addListener(_onNameChanged);
    _commentEditingController.addListener(_onCommentChanged);
  }

  void _onEmailChanged() {
    setState(() {
      _email = _emailEditingController.text;
      _isFormValid = _getValidity();
    });
  }

  void _onNameChanged() {
    setState(() {
      _name = _nameEditingController.text;
      _isFormValid = _getValidity();
    });
  }

  void _onCommentChanged() {
    setState(() {
      _text = _commentEditingController.text;
      _isFormValid = _getValidity();
    });
  }

  bool _getValidity() {
    return _name != null &&
        _name != '' &&
        _rateValue > 0 &&
        _text != null &&
        _text != '' &&
        _email != null &&
        _email != '';
  }

  @override
  void dispose() {
    _nameEditingController.removeListener(_onNameChanged);
    _nameEditingController.dispose();
    _emailEditingController.removeListener(_onEmailChanged);
    _emailEditingController.dispose();
    _commentEditingController.removeListener(_onCommentChanged);
    _commentEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _rateChooser = RatingStarChooser();

    _rateChooser.onChange.listen((rate) {
      setState(() {
        _rateValue = rate;
        _isFormValid = _getValidity();
      });
    });

    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppConstants.spaceH(50),
              Container(
                child: Text(
                  _translate('rate'),
                  style: AppTextStyles.text,
                  textAlign: TextAlign.center,
                ),
              ),
              AppConstants.spaceH(100),
              Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: DeviceInfo.isSmallWidth ? 3.0 : 10.0),
                  height: DeviceInfo.isSmallWidth ? 30.0 : 35.0,
                  child: _rateChooser),
              AppConstants.spaceH(110),
              Container(
                  child: Text(
                _translate('share'),
                style: AppTextStyles.text,
                textAlign: TextAlign.center,
              )),
              AppConstants.spaceH(80),
            ]),
          ),
        ),
        Container(
            child: Input(
          _nameEditingController,
          hintText: allTranslations.text('your.name') + ' *',
        )),
        AppConstants.spaceBetweenInputs,
        Container(
            child: Input(
          _emailEditingController,
          hintText: allTranslations.text('your.email') + ' *',
          keyboardType: TextInputType.emailAddress,
        )),
        AppConstants.spaceBetweenInputs,
        Container(
            child: Input(
          _commentEditingController,
          maxLines: 5,
          hintText: allTranslations.text('leave_comment') + ' *',
        )),
        AppConstants.spaceH(76),
        AppColoredButton(
          allTranslations.text('send'),
          isActive: _isFormValid,
          isBusy: ModelProvider.of(context).isBusyCommenting,
          onTap: () async {
            final commentId = await ModelProvider.of(context)
                .sendReview(widget.worker, _email, _name, _text, _rateValue);
            Navigator.pop(context, {'commentId': commentId});
          },
        ),
      ],
    ));
  }
}
