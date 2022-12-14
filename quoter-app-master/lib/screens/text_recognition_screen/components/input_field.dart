import 'package:flutter/material.dart';

OutlineInputBorder myinputborder(){ //return type is OutlineInputBorder
  return const OutlineInputBorder( //Outline border type for TextFeild
    borderRadius: BorderRadius.all(Radius.circular(20)),
    borderSide: BorderSide(
        color:Colors.redAccent,
        width: 3,
      )
  );
}

OutlineInputBorder myfocusborder(){
  return const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    borderSide: BorderSide(
        color:Colors.greenAccent,
        width: 3,
      )
  );
}
