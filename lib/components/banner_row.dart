import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timesget/components/row_card.dart';
import 'package:timesget/models/banner_model.dart';
import 'package:timesget/pages/company_detail.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerRow extends StatelessWidget {
  final BannerModel banner;
  BannerRow(this.banner);

  @override
  Widget build(BuildContext context) {
    final decor = BoxDecoration(
        borderRadius: AppBorderRadius.rowCard,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(banner.image.url),
        ));

    final content = Container(
      width: 235.0,
      decoration: decor,
    );

    return InkWell(
      onTap: banner.externalLink == null
          ? () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CompanyDetailPage(),
                      settings: RouteSettings(name: 'CompanyDetailPage')));
            }
          : () async {
              await _launchURL(banner.externalLink);
            },
      child: RowCardComponent(
        child: content,
        withoutShadow: true,
        paddings: EdgeInsets.all(0.0),
      ),
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
