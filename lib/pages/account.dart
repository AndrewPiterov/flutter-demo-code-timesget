import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/models/user.model.dart';
import 'package:timesget/services/auth.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = "account_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context),
      drawer: AppDrawer.of(context),
      backgroundColor: AppColors.white,
      body: Column(
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
                      StreamBuilder(
                        stream: AuthService().profile,
                        builder: (context, AsyncSnapshot<AppUser> snap) {
                          final user = snap.hasData ? snap.data : null;

                          if (user != null) {
                            print('User is ${user.email}');
                          } else {
                            print('User is null');
                          }

                          return user != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      _translate('title'),
                                      style: AppTextStyles.h1,
                                    ),
                                    AppConstants.spaceH3(60),
                                    Container(
                                      height: 100.0,
                                      child: AppIcons.account,
                                    ),
                                    AppConstants.spaceH3(15),
                                    text(user.email),
                                    AppConstants.spaceH3(60),
                                    AppColoredButton(
                                      allTranslations.text('logout'),
                                      color: AppColors.signupButton,
                                      borderColor: AppColors.signupButton,
                                      onTap: () {
                                        FirebaseAuth.instance
                                            .signOut()
                                            .then((value) {
                                          Navigator.of(context)
                                              .pushReplacementNamed('/home');
                                        }).catchError((e) {
                                          print(e);
                                        });
                                      },
                                    ),
                                    AppConstants.spaceH3(20),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'You are not authrorized',
                                        style: AppTextStyles.h1,
                                      ),
                                      AppConstants.spaceH3(20),
                                      InkWell(
                                        child: Text(_translate('title')),
                                        onTap: () {
                                          Navigator.of(context)
                                              .pushReplacementNamed('/login');
                                        },
                                      ),
                                    ],
                                  ),
                                );
                        },
                      )
                    ]),
                  ),
                )
              ],
            ),
          ),
          AppBottomTabBars()
        ],
      ),
    );
  }
}
