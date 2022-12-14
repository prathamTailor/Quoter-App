import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quoter/constant.dart';
import 'package:quoter/screens/home_screen/Home.dart';
import 'package:quoter/screens/quotes_screen/components/quote_list_tile.dart';
import 'package:quoter/screens/quotes_screen/display.dart';
import 'package:quoter/screens/text_recognition_screen/text_recognition_screen.dart';
import 'package:quoter/services/auth.dart';
import 'package:quoter/services/category_service.dart';
import 'package:quoter/services/database_services.dart';
import 'package:quoter/widget/custom_dialog.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({
    Key? key,
    required this.auth,
  }) : super(key: key);
  final AuthBase auth;

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  late UserQuoteDatabaseService userQuoteDatabaseService;
  bool status = true;
  int itemLengthLocal = 0;
  List<Map<String, dynamic>> itemDetailsListReversedLocal = [];
  dynamic fullCategoryLocal;
  List<String> allTextCategory = [];
  List fetchdata = [];
  void getOwnProjectDetails() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.auth.currentUser!.uid)
        .get()
        .then((snapshot) {
      fetchdata = snapshot.data()!['quote'];
      // fetchdata.map((e) => print('e printed: ${e['text']}'));
      // print("qutoes: $fetchdata");
    });
  }

  @override
  void initState() {
    userQuoteDatabaseService =
        UserQuoteDatabaseService(uid: widget.auth.currentUser!.uid);
    // CategoryService().insertCategory("Zala");
    getOwnProjectDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(status);
    // if (!status) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => DisplayQuoteList(
    //         itemLength: itemLengthLocal,
    //         item: itemDetailsListReversedLocal,
    //         fullCategory: fullCategoryLocal,
    //         auth: widget.auth,
    //       ),
    //     ),
    //   );
    // }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quotes"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TextRecognition(auth: widget.auth)));
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await widget.auth.signOut();
              } catch (e) {
                print(e);
              }
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                status = true;
              });
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(
                          auth: widget.auth, quoteText: "Give Your Thoughts")));
            },
            icon: const Icon(Icons.wallpaper_rounded),
          ),
        ],
      ),
      body: status
          ? Column(
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(widget.auth.currentUser!.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.data == null) {
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            CircularProgressIndicator(),
                            Text(
                              "Fetching Data...",
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      );
                    }

                    final DocumentSnapshot document =
                        snapshot.data as DocumentSnapshot;

                    final Map<String, dynamic> documentData =
                        document.data() as Map<String, dynamic>;

                    List checkingForEmptyList = documentData['quote'];
                    if (documentData['quote'] == null ||
                        checkingForEmptyList.isEmpty) {
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Text(
                              "No Quotes Available...",
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      );
                    }

                    final List<Map<String, dynamic>> itemDetailList =
                        (documentData['quote'] as List)
                            .map((itemDetail) =>
                                itemDetail as Map<String, dynamic>)
                            .toList();
                    var itemDetailsListReversed =
                        itemDetailList.reversed.toList();

                    fetchDataAndNavigate(int length) {
                      FirebaseFirestore.instance
                          .collection("category")
                          .doc(widget.auth.currentUser!.uid)
                          .get()
                          .then((value) {
                        final length = value["totalCategory"];
                        final fullCategory = value["category"];
                        //TODO: Navigate From here
                        setState(() {
                          itemLengthLocal = itemDetailsListReversed.length;
                          itemDetailsListReversedLocal =
                              itemDetailsListReversed;
                          fullCategoryLocal = fullCategory;
                          status = false;
                        });
                      });
                    }

                    fetchDataAndNavigate(itemDetailsListReversed.length);
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.85,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const <Widget>[
                          Center(
                            child: CircularProgressIndicator(
                              color: Colors.lightGreenAccent,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              ],
            )
          : DisplayQuoteList(
              itemLength: itemLengthLocal,
              item: itemDetailsListReversedLocal,
              fullCategory: fullCategoryLocal,
              auth: widget.auth,
            ),
    );
  }
}
