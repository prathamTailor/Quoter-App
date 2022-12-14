import 'package:cloud_firestore/cloud_firestore.dart';

class UserQuoteDatabaseService {
  final String uid;
  UserQuoteDatabaseService({required this.uid});

  //collection Reference
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future insertDummyUserData(String name) async {
    try {
      int len = 0;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .then((snapshot) {
        len = snapshot.data()!['totalQuotes'];
      });
      if (len == 0) {
        return await usersCollection.doc(uid).set({
          'name': name,
          'totalQuotes': 1,
          'quote': FieldValue.arrayUnion([
            {
              "text":
                  "Simplisity is also a fashion but everyone can't afford it.",
              "author": "APJ Abdul Kalam",
              "category": [0],
              'date': DateTime.now(),
            }
          ]),
        });
      }
    } catch (e) {
      return await usersCollection.doc(uid).set({
        'name': name,
        'totalQuotes': 1,
        'quote': FieldValue.arrayUnion([
          {
            "text":
                "Simplisity is also a fashion but everyone can't afford it.",
            "author": "APJ Abdul Kalam",
            "category": [0],
            'date': DateTime.now(),
          }
        ]),
      });
    }
  }

  Future updateTotalQuotes(int totalQuotes) async {
    return await usersCollection.doc(uid).update({
      'totalQuotes': totalQuotes,
    });
  }

  Future insertQuote(
      String quote, String author, List<int> category, DateTime date) async {
    List newListToBeStored = [];
    newListToBeStored.add({
      "text": quote,
      "author": author,
      "category": category,
      'date': DateTime.now(),
    });
    usersCollection.doc(uid).get().then((snapshot) {
      updateTotalQuotes(snapshot['totalQuotes'] + 1);
    });
    return await usersCollection.doc(uid).update({
      'quote': FieldValue.arrayUnion(newListToBeStored),
    });
  }
}
