import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quoter/services/auth.dart';
import 'components/input_field.dart';
import 'package:quoter/services/category_service.dart';
import 'components/fetch_categories.dart';

class AddCategory extends StatefulWidget {
  final AuthBase auth;
  const AddCategory({Key? key, required this.auth}) : super(key: key);

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  List<String> dropdown_categories = [];

  String dropdownValue = "";
  int dropdownIndex = 0;
  // Map<int, String> categories = {};

  XFile? imageFile;

  TextEditingController categoryController = TextEditingController();
  // void deleteCategory(int id) {
  //   categories.remove(id);
  // }

  void fetchCategories() async {
    dropdown_categories = await addToCategoryChip(widget.auth.currentUser!.uid);
    dropdownValue = dropdown_categories.first;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add Category"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: "Category Name",
                    border: myinputborder(), //normal border
                    enabledBorder: myinputborder(), //enabled border
                    focusedBorder: myfocusborder(), //focused border
                    // set more border style like disabledBorder
                  ),
                ),
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
                      int dd_index = dropdown_categories.indexOf(value);
                      if (dd_index > 0) {
                        categoryController.text = value;
                        dd_index--;
                        dropdownIndex = dd_index;
                        // print("dd_index:: $dd_index");
                        // categories.addAll({dd_index: dropdownValue.toString()});
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
                      CategoryService(uid: widget.auth.currentUser!.uid)
                          .insertCategory(categoryController.text.trim());
                      Timer(Duration(seconds: 1), () => fetchCategories());
                      categoryController.clear();
                    },
                    icon: Icon(Icons.add_rounded),
                    label: const Text(
                      "Add Category",
                    ),
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextButton.icon(
                    onPressed: () async {
                      if (categoryController.text.isNotEmpty) {
                        List<String> updatedCategories = [];
                        updatedCategories.addAll(dropdown_categories);
                        updatedCategories.removeAt(0);
                        updatedCategories[dropdownIndex] =
                            categoryController.text;

                        await CategoryService(uid: widget.auth.currentUser!.uid)
                            .updateCategory(updatedCategories);
                      }
                      categoryController.clear();
                      Timer(Duration(seconds: 1), () => fetchCategories());
                    },
                    icon: Icon(Icons.update_rounded),
                    label: const Text(
                      "Update",
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
}
