import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryService {
  final String uid;
  CategoryService({required this.uid});
  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('category');

  Future insertDummyCategory() async {
    try {
      int len = 0;
      await FirebaseFirestore.instance
          .collection("category")
          .doc(uid)
          .get()
          .then((value) {
        len = value["totalCategory"];
      });
      if (len == 0) {
        return await categoryCollection.doc(uid).set({
          'totalCategory': 1,
          'category': FieldValue.arrayUnion([
            "Favourite",
          ]),
        });
      }
    } catch (e) {
      return await categoryCollection.doc(uid).set({
        'totalCategory': 1,
        'category': FieldValue.arrayUnion([
          "Favourite",
        ]),
      });
    }
  }

  Future updateTotalCategory(int totalCategory) async {
    return await categoryCollection.doc(uid).update({
      'totalCategory': totalCategory,
    });
  }

  Future insertCategory(String newCategory) async {
    dynamic responseToBeSend;
    categoryCollection.doc(uid).get().then((snapshot) {
      updateTotalCategory(snapshot['totalCategory'] + 1);
      responseToBeSend = categoryCollection.doc(uid).update({
        'category': FieldValue.arrayUnion([
          newCategory,
        ]),
      });
    });
    return responseToBeSend;
  }

  Future updateCategory(List<String> categories) async {
    // print("HERE WE GO $indexToPass");
    return await FirebaseFirestore.instance
        .collection('category')
        .doc(uid)
        .get()
        .then((snapshot) {
      FirebaseFirestore.instance.collection('category').doc(uid).set({
        'totalCategory': categories.length,
        'category': FieldValue.arrayUnion(categories),
      });
    });
  }
  // Future<List> getCategory() async {
  //   List catrgoryArray = [];
  //   await categoryCollection
  //       .doc("allCategory")
  //       .get()
  //       .then((value) => {catrgoryArray = value["category"]});
  // }
}
