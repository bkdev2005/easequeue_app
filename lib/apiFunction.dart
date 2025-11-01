import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:eqlite/Auth/Login/Login_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'flutter_flow/flutter_flow_icon_button.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';

//------------------------- API -------------------------\\

// API url

const String apiUrl = 'https://staging-api.easequeue.com/api/v1';

// Get API

Future<dynamic>? fetchData(String endpoint, BuildContext context) async {
  log('endpoint: $endpoint');
  final url = Uri.parse('$apiUrl/$endpoint'); // API URL
  try {
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "accept": "application/json",
        "Authorization": "Bearer ${FFAppState().token}"
      },
    );
    log('Failed to load data: ${response.body}');
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      // final listData = getJsonField(responseBody, r'''$.data.data[:]''', true)?.toList()??[];
      print(responseBody);
      return responseBody;
    } else {
      log('Failed to load data: ${response.statusCode}');
      if (getJsonField(jsonDecode(response.body), r'''$.message''') ==
          'Invalid or expired token.') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginWidget()));
      }
      Fluttertoast.showToast(
          msg: getJsonField(jsonDecode(response.body), r'''$.message'''));
      return null;
    }
  } catch (e) {
    log('Error: $e');
    return null;
  }
}

// Navigate Page Function

Future<dynamic> navigateTo(BuildContext context, Widget destination) async {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => destination),
  ).then((value) {
    log('main value: $value');
    if (value != null) {
      return value;
    }
  });
}

// PreAuth API
Future<dynamic> preAuthApi(Object body, String endpoint) async {
  log('body: $body');
  final url = Uri.parse('$apiUrl/$endpoint');
  try {
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: json.encode(body));
    if (response.statusCode == 201 || response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      log('Data sent successfully: ${response.body}');
      return data;
    } else {
      log('Failed to send data: ${response.body}');
      log('Failed to send data: ${response.statusCode}');
      Fluttertoast.showToast(
          msg: getJsonField(jsonDecode(response.body), r'''$.message'''));
      return null;
    }
  } catch (e) {
    log('Error: $e');
    return null;
  }
}

// Put API

Future<dynamic> putData(Object body, String endpoint) async {
  final url = Uri.parse('$apiUrl/$endpoint');
  log('body: $body');
  try {
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "accept": "application/json",
        "Authorization": "Bearer ${FFAppState().token}"
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      log('Data sent successfully: ${response.body}');
      final dynamic data =
          getJsonField(jsonDecode(response.body), r'''$.data''');
      return data;
    } else {
      log('Failed to send data: ${response.statusCode}');
      log('Failed to send data: ${response.body}');
      Fluttertoast.showToast(
          msg: getJsonField(jsonDecode(response.body), r'''$.message'''));
      return null;
    }
  } catch (e) {
    log('Error: $e');
    return null;
  }
}

// Delete API

Future<bool> deleteData(Object body, String endpoint) async {
  final url = Uri.parse('$apiUrl/$endpoint');
  try {
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "accept": "application/json",
        "Authorization": "Bearer ${FFAppState().token}"
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      log('Data delete successfully: ${response.body}');
      return true;
    } else {
      log('Failed to send data: ${response.statusCode}');
      log('Failed to send data: ${response.body}');
      Fluttertoast.showToast(
          msg: getJsonField(jsonDecode(response.body), r'''$.message'''));
      return false;
    }
  } catch (e) {
    log('Error: $e');
    return false;
  }
}

// Post API

Future<dynamic> sendData(Object body, String endpoint) async {
  final url = Uri.parse('$apiUrl/$endpoint');
  log('body: $body');
  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "accept": "application/json",
        "Authorization": "Bearer ${FFAppState().token}"
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      log('Data sent successfully: ${response.body}');
      final dynamic data =
          getJsonField(jsonDecode(response.body), r'''$.data''');
      return data;
    } else {
      log('Failed to send data: ${response.statusCode}');
      log('Failed to send data: ${response.body}');
      Fluttertoast.showToast(
          msg: getJsonField(jsonDecode(response.body), r'''$.message'''));
      return null;
    }
  } catch (e) {
    log('Error: $e');
    return null;
  }
}

Future<dynamic> pickAndUploadFileWeb(String endpoint) async {
  try {
    // Step 1️⃣ Pick file (image, pdf, etc.)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // change to FileType.image or FileType.custom if needed
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      Fluttertoast.showToast(msg: '❌ No file selected');
      return null;
    }

    final file = result.files.first;
    final Uint8List? fileBytes = file.bytes;
    final String fileName = file.name;

    if (fileBytes == null) {
      Fluttertoast.showToast(msg: '❌ Could not read file bytes');
      return null;
    }

    // Step 2️⃣ Prepare multipart form data
    final multipartFile = MultipartFile.fromBytes(
      fileBytes,
      filename: fileName,
      contentType: DioMediaType('application', 'octet-stream'),
    );

    final formData = FormData.fromMap({
      'file': multipartFile,
    });

    // Step 3️⃣ Create Dio instance and upload
    final dio = Dio();

    final response = await dio.post(
      'https://staging-api.easequeue.com/api/v1/$endpoint',
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer ${FFAppState().token}', // if using auth
        },
      ),
      onSendProgress: (sent, total) {
        if (total != 0) {
          final progress = (sent / total * 100).toStringAsFixed(1);
          log('Uploading... $progress%');
        }
      },
    );

    // Step 4️⃣ Handle response
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic data = response.data['data'];
      log('✅ Upload success: $data');
      Fluttertoast.showToast(msg: '✅ Upload successful');
      return data;
    } else {
      log('❌ Upload failed: ${response.statusCode}');
      Fluttertoast.showToast(
        msg: response.data['message'] ?? 'Upload failed',
      );
      return null;
    }
  } catch (e, s) {
    log('🚨 Error uploading file: $e');
    log('Stack: $s');
    Fluttertoast.showToast(msg: 'Something went wrong while uploading');
    return null;
  }
}


// image upload api
Future<dynamic> profileApi(XFile image, String endpoint) async {
  String fileName = image.name;
  FormData formData = FormData.fromMap({
    "file": await MultipartFile.fromFile(image.path, filename: fileName),
  });

  try {
    Dio dio = Dio();
    final response = await dio.post(
      'https://staging-api.easequeue.com/api/v1/$endpoint',
      options: Options(headers: {
        "Content-Type": "multipart/form-data", // Important for file upload
        "accept": "application/json",
        "Authorization": "Bearer ${FFAppState().token}"
      }),
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic data = getJsonField(response.data, r'''$.data'''); // FIXED
      return data;
    } else {
      log('Failed to send data: ${response.statusCode}');
      log('Failed to send data: ${response.data}');
      Fluttertoast.showToast(
          msg: getJsonField(response.data, r'''$.message''')); // FIXED
      return null;
    }
  } catch (e) {
    log('Error: $e');
    return null;
  }
}

// Api response from pagination
Future<dynamic>? fetch(int limit, int page, String endpoint, String category_id,
    String filter_date) async {
  final url = Uri.parse("$apiUrl/$endpoint?page=$page&page_size=$limit");
  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer ${FFAppState().token}'},
  );
  log('response: ${response.body}');
  if (response.statusCode == 200) {
    final responseJson = jsonDecode(response.body);
    // final responseList = getJsonField(responseJson, r'''$.data[:]''', true)?.toList()??[];
    // print('item: ${responseList}');
    return responseJson;
  } else {
    return null;
  }
}
