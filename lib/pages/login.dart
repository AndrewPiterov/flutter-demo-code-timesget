import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/buttons/accept_process_private_data.button.dart';
import 'package:timesget/components/buttons/radio.buttons.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/tags/input.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/services/app_dialogs.dart';
import 'package:timesget/services/app_tooltip.dart';
import 'package:timesget/services/auth.service.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = 'login_page';
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class LoginPage extends StatefulWidget {
  final String initialMode;

  final onSuccess;
  LoginPage({this.initialMode = 'login', this.onSuccess});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _emailIsValid = false;
  String _email;

  bool _passwordIsValid = false;
  String _password;

  bool _isAcceptRules = false;

  // bool _loading = false;
  String _formType;

  String emailError;
  String passwordError;

  TextEditingController _emailInputController = new TextEditingController();
  TextEditingController _passwordInputController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailInputController.addListener(_onEmailChanged);
    _passwordInputController.addListener(_onPasswordChanged);
    _formType = widget.initialMode;
    _isAcceptRules = widget.initialMode == 'login';
  }

  @override
  void dispose() {
    _emailInputController.removeListener(_onEmailChanged);
    _emailInputController.dispose();
    _passwordInputController.removeListener(_onPasswordChanged);
    _passwordInputController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    setState(() {
      _email = _emailInputController.text;
      emailError = null;
      _emailIsValid =
          RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_email);

      if (!_emailIsValid && _email != null && _email.length > 0) {
        emailError = _translate('invalid_email');
      }
    });
  }

  void _onPasswordChanged() {
    setState(() {
      _password = _passwordInputController.text;
      passwordError = null;

      if (_password.length == 0) {
      } else if (_password.length < 6) {
        passwordError = _translate('too_short_pass');
      } else if (_password.length > 20) {
        passwordError = _translate('too_long_pass');
      }

      _passwordIsValid =
          passwordError == null && _password != null && _password.length > 0;
    });
  }

  void _showError(String error, {String type = 'email'}) {
    setState(() {
      switch (type) {
        case 'email':
          emailError = error;
          break;
        case 'password':
          passwordError = error;
          break;
        default:
          emailError = error;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(
          context,
        ),
        drawer: AppDrawer.of(context),
        backgroundColor: AppColors.white,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: <Widget>[
              Expanded(
                child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  slivers: <Widget>[
                    HeaderBoard(
                      '',
                      children: <Widget>[
                        AppImages.mobileCards,
                      ],
                      withShadow: false,
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(20.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _translate('login_signup_title'),
                                style: DeviceInfo.isSmallWidth
                                    ? AppTextStyles.h1Small
                                    : AppTextStyles.h1,
                              ),
                              Container()
                            ],
                          ),
                          AppConstants.spaceH3(15),
                          text(_translate('login_reason')),
                          AppConstants.spaceH3(20),
                          RadioButtons<String>(
                            [
                              RadioButton<String>(
                                  _translate('signup_toggle'), 'signup'),
                              RadioButton<String>(
                                  _translate('login_toggle'), 'login'),
                            ],
                            callback: (value) {
                              setState(() {
                                _formType = value;
                                _isAcceptRules = value == 'login';
                                _emailInputController.text = '';
                                _passwordInputController.text = '';
                              });
                              return 0;
                            },
                            seedSelectedIndex: _formType == 'signup' ? 0 : 1,
                          ),
                          AppConstants.spaceH3(20),
                          Input(_emailInputController,
                              hintText: _translate('email'), error: emailError),
                          AppConstants.spaceBetweenInputs,
                          Input(
                            _passwordInputController,
                            hintText: _formType == 'signup'
                                ? _translate('choose_password')
                                : _translate('password'),
                            obscure: true,
                            error: passwordError,
                          ),
                          AppConstants.spaceBetweenInputs,
                          _formType == 'signup'
                              ? AcceptRulesButton(
                                  _isAcceptRules,
                                  onTap: () {
                                    setState(() {
                                      _isAcceptRules = !_isAcceptRules;
                                    });
                                  },
                                  onlyProcessPrivateData: true,
                                )
                              : Container(),
                          AppConstants.spaceH3(20),
                          AppColoredButton(
                            _formType == 'login'
                                ? _translate('login_button')
                                : _translate('signup_button'),
                            isBusy: AuthService().loading,
                            isActive: _emailIsValid &&
                                _passwordIsValid &&
                                _isAcceptRules,
                            onTap: () {
                              if (_formType == 'login') {
                                AuthService()
                                    .signInWithEmailAndPassword(
                                        _email, _password)
                                    .then((FirebaseUser user) {
                                  if (widget.onSuccess != null) {
                                    widget.onSuccess('login');
                                  } else {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/account');
                                  }
                                }).catchError((e) {
                                  switch (e.code) {
                                    case 'ERROR_USER_NOT_FOUND':
                                      _showError(
                                          _translate('unregistered_email'));
                                      break;
                                    case 'ERROR_WRONG_PASSWORD':
                                      _showError(_translate('invalid_password'),
                                          type: 'password');
                                      break;
                                    default:
                                      _showError(e.code);
                                      break;
                                  }

                                  print(e);
                                });
                              } else {
                                AuthService()
                                    .createUserWithEmailAndPassword(
                                        _email, _password)
                                    .then((user) {
                                  if (widget.onSuccess != null) {
                                    widget.onSuccess('signup');
                                  } else {
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .pushReplacementNamed('/account');
                                  }
                                }).catchError((e) {
                                  if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
                                    _showError(
                                        _translate('email_already_taken'));
                                  }
                                  print(e);
                                });
                              }
                            },
                          ),
                          AppConstants.spaceH3(15),
                          AppConstants.spaceH3(15),
                          _formType == 'login'
                              ? InkWell(
                                  onTap: _emailIsValid
                                      ? () async {
                                          AppDialogs
                                                  .requestResetPasswordOnEmail(
                                                      _email, context)
                                              .then((res) {
                                            if (res == null) {
                                              return;
                                            }

                                            AppNotification().show(
                                                context,
                                                buildOverlay(_translate(
                                                        'instruction_has_been_sent') +
                                                    ' $_email'),
                                                duration: Duration(seconds: 5));
                                          }, onError: (err) {});
                                        }
                                      : () {
                                          AppNotification().show(
                                              context,
                                              buildOverlay(_translate(
                                                  'input_your_email_for_recover')),
                                              duration: Duration(seconds: 7));
                                        },
                                  child: Text(
                                    _translate('forget_password'),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.link.copyWith(
                                        decoration: _emailIsValid
                                            ? TextDecoration.underline
                                            : TextDecoration.none),
                                  ),
                                )
                              : AppConstants.nothing,
                        ]),
                      ),
                    )
                  ],
                ),
              ),
              AppBottomTabBars()
            ],
          ),
        ));
  }
}
