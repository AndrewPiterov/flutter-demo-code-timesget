import 'package:flutter/material.dart';
import 'package:timesget/styles/constants.dart';

class AppImages {
  static AssetImage get noCompany => AssetImage('assets/img/HomeImage.jpg');

  static AssetImage get companyMain => AssetImage('assets/img/HomeImage.jpg');
  static AssetImage get companyAbout => AssetImage('assets/img/AboutImage.jpg');

  static String get workerPlaceholder => 'assets/img/Placeholder.png';

  static Image get notFound => Image.asset('assets/img/NotFound.png');

  static String get barcodeScan => 'assets/img/ScanIcon.png';

  static Image get mobileCards => Image.asset('assets/img/MobileCardsImg.png');

  static String get splashScreenLogoPath => 'assets/img/Logo@3x.png';
}

class AppIcons {
  static final Widget checkmarkActive = Image.asset('assets/img/CheckON.png');
  static final Widget checkmarkInactive =
      Image.asset('assets/img/CheckOFF.png');
  static final Widget closeWindow = Image.asset('assets/img/Close.png');
  static final Widget closeWindowDark = Image.asset('assets/img/Close2.png');

  static Image get account => Image.asset('assets/img/Account.png');

  static Widget barcodeScan({double h = 20.0}) => Image.asset(
        AppImages.barcodeScan,
        height: h,
      );

  static Image get settings => Image.asset('assets/img/SettingIcon.png');

  // static final Widget arrowBack = Image.asset('assets/img/Back.png');
  static Widget arrowBack({height: 20.0}) => Image(
        image: AssetImage('assets/img/Back.png'),
        height: height,
      );

  static final Widget arrowDown = Image.asset('assets/img/ArrowDown.png');

  // tab bars
  static home({int i = 1, height: 25.0}) => Image.asset(
        'assets/img/Home$i.png',
        height: height,
      );

  static help({int i = 1, height: 25.0}) => Image.asset(
        'assets/img/Help$i.png',
        height: height,
      );

  static workers({int i = 1, height: 25.0}) => Image.asset(
        'assets/img/Specialists$i.png',
        height: height,
      );

  static myBookings({int i = 1, height: 25.0}) => Image.asset(
        'assets/img/Appointment$i.png',
        height: height,
      );

  static time({int i = 1, height: 25.0}) => Image.asset(
        'assets/img/Time$i.png',
        height: height,
      );

  static early({int i = 1, height: 25.0}) => Image.asset(
        'assets/img/Early$i.png',
        height: height,
      );

  static more({int i = 1, height: 25.0}) => Image.asset(
        'assets/img/More$i.png',
        height: height,
      );

  static iconButton(int i, {height: 20.0}) => Image.asset(
        'assets/img/IconButton$i.png',
        height: height,
      );

  static Widget comparison({height: 25.0}) => Image.asset(
        'assets/img/Comparison.png',
        height: height,
      );

  static Widget comparison2({height: 25.0}) => Image.asset(
        'assets/img/Comparison2.png',
        height: height,
      );

  static nearby({height: 25.0}) => Image.asset(
        'assets/img/Nearby.png',
        height: height,
      );

  static nearby2({height: 25.0}) => Image.asset(
        'assets/img/Nearby2.png',
        height: height,
      );

  static Image get openWindow => Image.asset('assets/img/OpenWindow.png');

  static Image get search => Image.asset('assets/img/Search.png');

  static notification({height: 200}) => Image.asset(
        'assets/img/Notification.png',
        height: AppConstants.sizeOf(height),
      );

  // praise complaints
  static get photoPraiseComplain => Image.asset('assets/img/Photo.png');
  static get videoPraiseComplain => Image.asset('assets/img/Video.png');
  static get audioPraiseComplain => Image.asset('assets/img/Audio.png');

  static praiseComplainSelected(String type) =>
      Image.asset('assets/img/${type}Completed.png');

  // emotions
  static get emotionBadly => Image.asset('assets/img/BadlyOFF.png');
  static get emotionBadlySelected => Image.asset('assets/img/Badly.png');
  static get emotionGood => Image.asset('assets/img/GoodOFF.png');
  static get emotionGoodSelected => Image.asset('assets/img/Good.png');
  static get emotionSatisfied => Image.asset('assets/img/NormOFF.png');
  static get emotionSatisfiedSelected => Image.asset('assets/img/Norm.png');

  // calendar
  static prevDate({height: 10.0}) => Image.asset(
        'assets/img/MonthPrevious.png',
        height: height,
      );
  static Image nextDate({height: 10.0}) => Image.asset(
        'assets/img/MonthNext.png',
        height: height,
      );

  // social media
  static const String facebookIcon = "assets/img/Facebook.png";
  static const String instagramIcon = "assets/img/Instagram.png";
  static const String youTubeIcon = "assets/img/Youtube.png";
  static const String vkIcon = "assets/img/VK.png";
  static const String odnoklassnikiIcon = "assets/img/Odnoklassniki.png";

  // Bookings

  static Image toCancelBooking({height: 20.0}) => Image.asset(
        'assets/img/AppointmentCancel.png',
        height: height,
      );

  static Image canceledBooking({height: 20.0}) => Image.asset(
        'assets/img/AppointmentCanceled.png',
        height: height,
      );

  static Image passedBooking({height: 20.0}) => Image.asset(
        'assets/img/AppointmentPassed.png',
        height: height,
      );
}
