import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timesget/models/message.dart';

class DetailPage extends StatefulWidget {
  DetailPage(this.itemId);
  final String itemId;
  @override
  _DetailPageState createState() => new _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Item _item;
  StreamSubscription<Item> _subscription;

  @override
  void initState() {
    super.initState();
    // TODO: _item = ModelProvider.messanger.items[widget.itemId];
    _subscription = _item.onChanged.listen((Item item) {
      if (!mounted) {
        _subscription.cancel();
      } else {
        setState(() {
          _item = item;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Item ${_item.itemId}"),
      ),
      body: new Material(
        child: new Center(child: new Text("Item status: ${_item.status}")),
      ),
    );
  }
}