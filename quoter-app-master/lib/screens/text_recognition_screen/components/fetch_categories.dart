import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> addToCategoryChip(String uid) async {
  List<String> cats = <String>['Select Category'];
  await FirebaseFirestore.instance
      .collection("category")
      .doc(uid)
      .get()
      .then((value) {
    int length = value["totalCategory"];
    // print(length);
    for (int i = 0; i < length; i++) {
      // print(value["category"][i]);
      cats.add(value["category"][i]);
    }
  });
  return cats;
}
