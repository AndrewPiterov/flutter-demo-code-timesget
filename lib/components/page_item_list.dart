import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';

typedef Widget IndexedAppItemWidgetBuilder<T>(
    BuildContext context, dynamic item, int index, int count);

typedef T IndexedAppItemWidgetMap<T>(DocumentSnapshot snapshot);

class PageItemListComponent<T> extends StatefulWidget {
  final Stream<QuerySnapshot> stream;
  final IndexedAppItemWidgetMap<T> mapper;
  final IndexedAppItemWidgetBuilder<T> itemBuilder;

  PageItemListComponent(
      {@required this.stream,
      @required this.mapper,
      @required this.itemBuilder})
      : assert(stream != null && mapper != null && itemBuilder != null);

  @override
  _PageItemListComponentState createState() => _PageItemListComponentState();
}

class _PageItemListComponentState extends State<PageItemListComponent> {
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

                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    padding: AppPaddings.pageContent,
                    itemBuilder: (context, index) {
                      final sn = snapshot.data.documents[index];
                      final item = widget.mapper(sn);
                      var x = widget.itemBuilder(
                          context, item, index, snapshot.data.documents.length);
                      return x;
                    });
              }),
        ));
  }
}

class PageModelListComponent<T> extends StatefulWidget {
  final Stream<T> stream;
  final IndexedAppItemWidgetBuilder<T> itemBuilder;
  final Widget whenEmpty;
  final String emptyLabel;

  PageModelListComponent(
      {@required this.stream,
      @required this.itemBuilder,
      this.whenEmpty,
      this.emptyLabel = ''})
      : assert(stream != null && itemBuilder != null);

  @override
  _PageModelListComponentState createState() => _PageModelListComponentState();
}

class _PageModelListComponentState extends State<PageModelListComponent> {
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

                final itemCount = snapshot.data.length;

                if (itemCount == 0) {
                  return widget.whenEmpty == null
                      ? Center(child: Text(widget.emptyLabel))
                      : widget.whenEmpty;
                }

                return ListView.builder(
                    itemCount: snapshot.data.length,
                    padding: AppPaddings.pageContent,
                    itemBuilder: (context, index) {
                      final model = snapshot.data[index];
                      var x = widget.itemBuilder(
                          context, model, index, snapshot.data.length);
                      return x;
                    });
              }),
        ));
  }
}

class PageModelList<T> extends StatelessWidget {
  final List<T> items;
  final IndexedAppItemWidgetBuilder<T> builder;
  final Widget whenNoItem;

  PageModelList(
      {@required this.items, @required this.builder, this.whenNoItem});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: AppColors.pageBackground
            // gradient: AppGradients.pageContent,
            ),
        child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: items.isEmpty
                ? whenNoItem == null ? Container() : whenNoItem
                : ListView.builder(
                    itemCount: items.length,
                    padding: AppPaddings.pageContent,
                    itemBuilder: (context, index) {
                      final model = items[index];
                      var x = builder(context, model, index, items.length);
                      return x;
                    })));
  }
}
