import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef ItemMap<T> = Widget Function(T item);
typedef MapLabel<T> = Text Function(T item, bool selected);
typedef ValuePickerOnChanged<T> = void Function(T item);

class ValuePicker<T> extends StatefulWidget {
  final ValuePickerOnChanged onChanged;
  final List<T> items;
  final ItemMap<T> map;
  final int initialSelectedIndex;
  final MapLabel mapLabel;
  final bool isLoop;

  ValuePicker(this.items,
      {Key key,
      this.map,
      this.onChanged,
      this.mapLabel,
      this.initialSelectedIndex = 0,
      this.isLoop = false})
      : super(key: key);

  @override
  ValuePickerState<T> createState() =>
      ValuePickerState<T>(initialSelectedIndex);
}

class ValuePickerState<T> extends State<ValuePicker> {
  T _selected;
  int _selectedIndex = -1;

  ValuePickerState(this._selectedIndex);

  @override
  Widget build(BuildContext context) {
    final FixedExtentScrollController scrollController =
        new FixedExtentScrollController(
            initialItem: _selectedIndex < 0 ? 0 : _selectedIndex);

    var i = 0;
    final arr = widget.items.map((item) {
      final isSelected =
          (_selected != null && _selected == item) || i == _selectedIndex;
      i++;
      return Center(child: widget.mapLabel(item, isSelected));
    }).toList();

    return CupertinoPicker(
        scrollController: scrollController,
        backgroundColor: Colors.white,
        diameterRatio: 180.0,
        looping: widget.isLoop,
        children: arr,
        itemExtent: 65.0,
        onSelectedItemChanged: (index) {
          setState(() {
            _selectedIndex = index;
            _selected = widget.items[index];
            if (widget.onChanged != null) {
              widget.onChanged(_selected);
            }
          });
        });
  }
}
