import 'package:flutter/material.dart';
import 'package:quoter/screens/quote_update_screen/quote_update_screen.dart';
import 'package:quoter/screens/quotes_screen/components/quote_list_tile.dart';
import 'package:quoter/services/auth.dart';
import 'dart:math';
import 'package:quoter/constant.dart';

class DisplayQuoteList extends StatefulWidget {
  const DisplayQuoteList({
    Key? key,
    required this.itemLength,
    required this.item,
    required this.fullCategory,
    required this.auth,
  }) : super(key: key);
  final int itemLength;
  final AuthBase auth;

  final List<Map<String, dynamic>> item;
  final List<dynamic> fullCategory;

  @override
  State<DisplayQuoteList> createState() => _DisplayQuoteListState();
}

class _DisplayQuoteListState extends State<DisplayQuoteList> {
  // final List<int> categoryIndex;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.itemLength,
                  itemBuilder: (BuildContext context, int index) {
                    return CustomQuoteListTile(
                      quoteText: widget.item[index]["text"],
                      author: widget.item[index]["author"],
                      categories: widget.item[index]["category"],
                      fullCategory: widget.fullCategory,
                      colorIndex: Random().nextInt(kBarColorSet.length),
                      indexOfQuote: widget.itemLength - index - 1,
                      auth: widget.auth,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
