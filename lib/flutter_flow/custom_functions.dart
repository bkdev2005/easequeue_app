import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'flutter_flow_util.dart';
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';

bool checkPhoneLength(String phoneNumber) {
  if (phoneNumber.length < 11 && phoneNumber.length > 9) {
    return true;
  } else {
    return false;
  }
}

String valueToGender(int valueGender) {
  if (valueGender == 1) {
    return "Male";
  } else if (valueGender == 2) {
    return "Female";
  } else {
    return "Other";
  }
}

int genderToValue(String valueGender) {
  if (valueGender == "Male") {
    return 1;
  } else if (valueGender == "Female") {
    return 2;
  } else {
    return 3;
  }
}

int timeStemp(String dateWithTime) {
  log('$dateWithTime');
  int day = int.parse(dateWithTime.substring(0, 2));
  int month = int.parse(dateWithTime.substring(3, 5));
  int year = int.parse(dateWithTime.substring(6, 10));
  int hour = int.parse(dateWithTime.substring(11, 13));
   int minute = int.parse(dateWithTime.substring(14, 16));

   final DateTime date1 = DateTime(year, month, day, hour, minute);
  log('${hour } ');
   final timestamp1 = date1.millisecondsSinceEpoch;
  log('$timestamp1 (milliseconds)');

   return timestamp1;
}

String getIdOfSelectedItem(List<dynamic> data, String? value){
  String Id = '';
  for(final i in data){
    if(getJsonField(i, r'''$.name''') == value){
      Id = getJsonField(i, r'''$._id''');
    }
  }
  return Id;
}

String getCapitalName(String input) {
  // Split the input string by spaces
  List<String> words = input.split(' ');

  // Extract the first letter of each word and convert it to uppercase
  String result = words
      .where((word) => word.isNotEmpty && word[0].toUpperCase() == word[0])  // Ensure the first letter is a capital
      .map((word) => word[0].toUpperCase())  // Get the uppercase of the first letter
      .join();  // Join the letters together

  return result;
}
