import 'package:flutter/material.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/models/company.dart';
import 'package:timesget/services/company_service.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SoclialMediaIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SocialMediaLinks>(
      stream: CompanyDataService().socialMediaLinks$,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return AppConstants.circleSpinner;
        }

        final links = snapshot.data;
        if (links == null || links.isEmpty) {
          return Container();
        }

        final isSmall = DeviceInfo.isSmallWidth;
        final spaceBetweenIcons = isSmall ? 32 : 50;
        final icons = [
          _socialMediaIcon('instagram', links.instagram),
          _socialMediaIcon('vk', links.vk),
          _socialMediaIcon('facebook', links.facebook),
          _socialMediaIcon('ok', links.ok),
          _socialMediaIcon('youTube', links.youTube),
        ].where((x) => x != null).toList();

        final spacedIcons = List<Widget>();
        for (var i = 0; i < icons.length; i++) {
          spacedIcons.add(icons[i]);
          if (i < icons.length - 1) {
            spacedIcons.add(AppConstants.spaceW(spaceBetweenIcons));
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: spacedIcons,
        );
      },
    );
  }

  Widget _socialMediaIcon(String sm, String url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    final h = 30.0;
    Widget icon;
    switch (sm) {
      case 'facebook':
        icon = Image.asset(
          AppIcons.facebookIcon,
          height: h,
        );
        break;
      case 'instagram':
        icon = Image.asset(
          AppIcons.instagramIcon,
          height: h,
        );
        break;
      case 'youTube':
        icon = Image.asset(
          AppIcons.youTubeIcon,
          height: h,
        );
        break;
      case 'vk':
        icon = Image.asset(
          AppIcons.vkIcon,
          height: h,
        );
        break;
      case 'ok':
        icon = Image.asset(
          AppIcons.odnoklassnikiIcon,
          height: h,
        );
        break;
      default:
        throw ("Undefined '$sm' icon.");
    }
    return InkWell(
      onTap: () async {
        await _launchURL(url);
      },
      child: icon,
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
