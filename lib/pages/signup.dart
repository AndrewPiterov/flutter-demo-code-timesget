import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/tags/a.dart';
import 'package:timesget/components/tags/input.dart';
import 'package:timesget/components/tags/space.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/pages/login.dart';
import 'package:timesget/services/auth.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';
import 'package:page_transition/page_transition.dart';

const _pageName = 'login_page';
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class SignupPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SignupPage> {
  String _email;
  String _password;

  TextEditingController _emailInputController = new TextEditingController();
  TextEditingController _passwordInputController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailInputController.addListener(_onEmailChanged);
    _passwordInputController.addListener(_onPasswordChanged);
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
    });
  }

  void _onPasswordChanged() {
    setState(() {
      _password = _passwordInputController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              space(p: 3),
              Text(
                _translate('signup_title'),
                style: AppTextStyles.h1,
              ),
              space(),
              Input(
                _emailInputController,
                hintText: _translate('email'),
              ),
              AppConstants.spaceBetweenInputs,
              Input(
                _passwordInputController,
                hintText: _translate('password'),
                obscure: true,
              ),
              AppConstants.spaceBetweenThinButtons,
              RaisedButton(
                child: text(_translate('signup_button')),
                color: AppColors.loginButton,
                elevation: 7.0,
                textColor: AppColors.white,
                onPressed: () async {
                  AuthService()
                      .createUserWithEmailAndPassword(_email, _password)
                      .then((user) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/account');
                  }).catchError((e) {
                    print(e);
                  });
                },
              ),
              AppConstants.spaceH3(15),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: _translate('already_have_an_account'),
                      style: AppTextStyles.text),
                  TextSpan(text: " "),
                  a2(_translate('login_button'), onClick: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            curve: Curves.linear,
                            type: PageTransitionType.downToUp,
                            child: LoginPage()));
                  })
                ]),
              ),
              space(p: 4),
            ],
          ),
        ),
      ),
    );
  }
}
