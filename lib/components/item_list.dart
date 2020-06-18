import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';

typedef Widget IndexedAppItemWidgetBuilder<T>(
    BuildContext context, dynamic item, int index, int count);

typedef T IndexedAppItemWidgetMap<T>(DocumentSnapshot snapshot);

class ItemListComponent<T> extends StatefulWidget {
  final Stream<T> stream;
  final IndexedAppItemWidgetBuilder<T> itemBuilder;
  final noTitle;

  ItemListComponent(
      {@required this.stream, this.noTitle = '', @required this.itemBuilder})
      : assert(stream != null && itemBuilder != null);

  @override
  _ItemListComponentState createState() => _ItemListComponentState();
}

class _ItemListComponentState extends State<ItemListComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: AppColors.pageBackground
            // gradient: AppGradients.pageContent,
            ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: StreamBuilder(
              stream: widget.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: AppConstants.spinner,
                  );
                }

                if (snapshot.data.length == 0) {
                  return Center(child: Text(widget.noTitle));
                }

                return ListView.builder(
                    itemCount: snapshot.data.length,
                    padding: AppPaddings.pageContent,
                    itemBuilder: (context, index) {
                      final sn = snapshot.data[index];
                      var x = widget.itemBuilder(
                          context, sn, index, snapshot.data.length);
                      return x;
                    });
              }),
        ));
  }
}
