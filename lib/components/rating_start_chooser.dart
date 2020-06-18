import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class RatingStarChooser extends StatefulWidget {
  ReplaySubject<int> onChange = ReplaySubject<int>();

  @override
  _RatingStarChooserState createState() => _RatingStarChooserState();
}

class _RatingStarChooserState extends State<RatingStarChooser> {
  final count = 5;
  int value = 0;

  @override
  Widget build(BuildContext context) {
    var stars = List<Widget>();

    for (var val = 1; val <= count; val++) {
      stars.add(InkWell(
        onTap: () {
          setState(() {
            value = val;
          });
          widget.onChange.add(val);
        },
        child: val <= value
            ? Image.asset('assets/img/RatingFull.png')
            : Image.asset('assets/img/RatingEmpty.png'),
      ));
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: stars);
  }
}
