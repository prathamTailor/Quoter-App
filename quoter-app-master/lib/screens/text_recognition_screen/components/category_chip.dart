import 'package:flutter/material.dart';

class category_chip extends StatelessWidget {
  String label;
  int id;
  void Function() deleteChip;
  category_chip(
      {Key? key,
      required this.label,
      required this.id,
      required this.deleteChip})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(2.0),
      child: InputChip(
        label: Text(label),
        onSelected: (bool value) {},
        onDeleted: deleteChip,
      ),
    );
  }
}
