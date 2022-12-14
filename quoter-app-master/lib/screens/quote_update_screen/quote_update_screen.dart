import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quoter/screens/quotes_screen/quotes_screen.dart';
import 'package:quoter/services/auth.dart';
import 'components/input_field.dart';
import 'package:quoter/services/database_services.dart';
import 'components/category_chip.dart';

class UpdateQuote extends StatefulWidget {
  final AuthBase auth;
  final String quoteText;
  final String quoteAuthor;
  final Map<int, String> quoteCategory;
  final int indexOfQuote;

  const UpdateQuote(
      {Key? key,
      required this.auth,
      required this.quoteAuthor,
      required this.quoteText,
      required this.indexOfQuote,
      required this.quoteCategory})
      : super(key: key);

  @override
  State<UpdateQuote> createState() => _UpdateQuoteState();
}

List<String> dropdown_categories = <String>['Select Category'];

class _UpdateQuoteState extends State<UpdateQuote> {
  TextEditingController quoteController = TextEditingController();
  TextEditingController authorController = TextEditingController();

  String dropdownValue = dropdown_categories.first;
  Map<int, String> categories = {};

  void deleteCategory(int id) {
    categories.remove(id);
  }

  void addToCategoryChip() {
    dropdown_categories.clear();
    dropdown_categories.add("Select Category");
    FirebaseFirestore.instance
        .collection("category")
        .doc(widget.auth.currentUser!.uid)
        .get()
        .then((value) {
      int length = value["totalCategory"];
      //print(length);
      for (int i = 0; i < length; i++) {
        //print(value["category"][i]);
        //print("Hello");
        dropdown_categories.add(value["category"][i]);
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    addToCategoryChip();
    quoteController.text = widget.quoteText;
    authorController.text = widget.quoteAuthor;
    categories = widget.quoteCategory;
    // print("e index 6e: ${widget.indexOfQuote}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Quote Update"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: quoteController,
                  decoration: InputDecoration(
                    labelText: "Quote",
                    border: myinputborder(), //normal border
                    enabledBorder: myinputborder(), //enabled border
                    focusedBorder: myfocusborder(),
                    //focused border
                    // set more border style like disabledBorder
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: authorController,
                  decoration: InputDecoration(
                    labelText: "Author Name",
                    border: myinputborder(), //normal border
                    enabledBorder: myinputborder(), //enabled border
                    focusedBorder: myfocusborder(), //focused border
                    // set more border style like disabledBorder
                  ),
                ),
                Wrap(
                  children: categories.entries
                      .map(
                        (e) => category_chip(
                          label: e.value,
                          id: e.key,
                          deleteChip: () {
                            setState(() {
                              deleteCategory(e.key);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                // category_chip(),
                const SizedBox(
                  height: 20,
                ),
                DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_drop_down),
                  elevation: 16,
                  style: const TextStyle(color: Colors.grey),
                  underline: Container(
                    height: 2,
                    color: Colors.yellowAccent,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      dropdownValue = value!;
                      int dd_index = dropdown_categories.indexOf(dropdownValue);
                      if (dd_index > 0) {
                        dd_index--;
                        print("dd_index:: $dd_index");
                        categories.addAll({dd_index: dropdownValue.toString()});
                      }
                    });
                  },
                  items: dropdown_categories
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextButton.icon(
                    onPressed: () {
                      updatePerticularQuote(
                          widget.auth.currentUser!.uid,
                          quoteController.text,
                          authorController.text,
                          categories,
                          widget.indexOfQuote);
                      Navigator.pop(context);
                      // Navigator.pop(context);
                    },
                    icon: Icon(Icons.save_rounded),
                    label: const Text(
                      "Update",
                    ),
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextButton.icon(
                    onPressed: () {
                      deletePerticularQuote(
                          widget.auth.currentUser!.uid,
                          quoteController.text,
                          authorController.text,
                          categories,
                          widget.indexOfQuote);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.delete_forever_rounded),
                    label: const Text(
                      "Delete",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future updatePerticularQuote(String uid, String quoteText, String quoteAuthor,
      Map<int, String> quoteCategory, int indexToPass) async {
    // print("HERE WE GO $indexToPass");
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((snapshot) {
      final retrievedAuthor = snapshot.data()!['quote'][indexToPass]['author'];
      final retrievedCategory =
          snapshot.data()!['quote'][indexToPass]['category'];
      final retrievedDate = snapshot.data()!['quote'][indexToPass]['date'];
      final retrievedText = snapshot.data()!['quote'][indexToPass]['text'];

      // print("ERROR!!! " + retrievedAuthor + retrievedText);
      // print(retrievedDate.toString());
      // print(retrievedCategory.toString());
      List updatedListToBeStored = [], listToBeDeleted = [];
      updatedListToBeStored.add({
        "author": quoteAuthor,
        "category": quoteCategory.keys.toList(),
        "date": DateTime.now(),
        "text": quoteText,
      });
      listToBeDeleted.add({
        "author": retrievedAuthor,
        "category": retrievedCategory,
        "date": retrievedDate,
        "text": retrievedText,
      });
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'quote': FieldValue.arrayUnion(updatedListToBeStored),
      });

      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'quote': FieldValue.arrayRemove(listToBeDeleted),
      });

      // print("Updated...");
    });
  }

  Future deletePerticularQuote(String uid, String quoteText, String quoteAuthor,
      Map<int, String> quoteCategory, int indexToPass) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((snapshot) {
      final retrievedAuthor = snapshot.data()!['quote'][indexToPass]['author'];
      final retrievedCategory =
          snapshot.data()!['quote'][indexToPass]['category'];
      final retrievedDate = snapshot.data()!['quote'][indexToPass]['date'];
      final retrievedText = snapshot.data()!['quote'][indexToPass]['text'];

      UserQuoteDatabaseService(uid: uid)
          .updateTotalQuotes(snapshot.data()!['totalQuotes'] - 1);
      // print("ERROR!!! " + retrievedAuthor + retrievedText);
      // print(retrievedDate.toString());
      // print(retrievedCategory.toString());
      List updatedListToBeStored = [], listToBeDeleted = [];
      updatedListToBeStored.add({
        "author": quoteAuthor,
        "category": quoteCategory.keys.toList(),
        "date": DateTime.now(),
        "text": quoteText,
      });
      listToBeDeleted.add({
        "author": retrievedAuthor,
        "category": retrievedCategory,
        "date": retrievedDate,
        "text": retrievedText,
      });
      // FirebaseFirestore.instance.collection('users').doc(uid).update({
      //   'quote': FieldValue.arrayUnion(updatedListToBeStored),
      // });

      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'quote': FieldValue.arrayRemove(listToBeDeleted),
      });
    });
  }
}
