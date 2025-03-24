import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:eqlite/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'flutter_flow/flutter_flow_icon_button.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';

Widget backIcon(BuildContext context) {
  return FlutterFlowIconButton(
    borderColor: Colors.transparent,
    borderRadius: 30,
    borderWidth: 1,
    buttonSize: 60,
    icon: const Icon(
      Icons.keyboard_backspace_rounded,
      color: Colors.white,
      size: 30,
    ),
    onPressed: () async {
      Navigator.pop(context);
    },
  );
}

/// Generates a list of the next 7 days including today.
/// Each entry is a map with keys: "year", "month", "date", "day".
List<dynamic> getNext7DaysAsMap() {
  final DateFormat yearFormatter =
      DateFormat('yyyy');
  final DateFormat monthFormatter =
      DateFormat('MMM'); // Abbreviated month name (e.g., Jan)
  final DateFormat dayFormatter =
      DateFormat('EEE'); // Abbreviated day name (e.g., Thu)
  final DateFormat dateFormatter =
      DateFormat('dd'); // Date in two digits (e.g., 09)

  final List<dynamic> daysList = [];

  for (int i = 0; i < 7; i++) {
    DateTime date = DateTime.now().add(Duration(days: i));
    daysList.add('''{
      "year": "${yearFormatter.format(date)}",
      "month": "${monthFormatter.format(date)}",
      "date": "${dateFormatter.format(date)}",
      "day": "${dayFormatter.format(date)}"
    }''');
  }
  return daysList;
}

// Whatsapp Message function

void sendWhatsAppMessage(String phone) async {
  String url = "https://wa.me/$phone";
  Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    print("Could not launch WhatsApp");
  }
}

// Message function

void sendSMS(String phoneNumber) async {
  final Uri url = Uri.parse("sms:$phoneNumber?body=");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    print("Could not launch $url");
  }
}

// Dial call function

void dialNumber(String phoneNumber) async {
  final Uri url = Uri.parse("tel:$phoneNumber");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    print("Could not launch $url");
  }
}

// Loading
Widget loading(BuildContext context){
  return Center(child: Container(
    height: 60,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: FlutterFlowTheme.of(context).primaryBackground,
        boxShadow: const [ BoxShadow(
          color: Colors.black38,
          blurRadius: 5.0,
        ),]
    ),
    child: const Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(
          color: Colors.black54, strokeWidth: 3,)),
  ),);
}

// joint address

String formatAddress(dynamic address) {
  return address.entries
      .where((entry) => entry.value != null && entry.value!.trim().isNotEmpty)
      .map((entry) => entry.value)
      .join(', ');
}

// Empty List

Widget emptyList(){
  return Center(child: Image.asset('assets/images/empty-folder.png', height: 70 ,),);
}

// Button Style

FFButtonOptions buttonStyle(BuildContext context){
  return FFButtonOptions(
    width: double.infinity,
    height: 55,
    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
    color: FlutterFlowTheme.of(context).primary,
    textStyle: FlutterFlowTheme.of(context).titleMedium.override(
      fontFamily: 'Inter Tight',
      color: Colors.white,
      fontSize: 16,
      letterSpacing: 0.0,
      fontWeight: FontWeight.w500,
    ),
    elevation: 2,
    borderSide: const BorderSide(
      color: Colors.transparent,
      width: 1,
    ),
    borderRadius: BorderRadius.circular(30),
  );
}

// Get Profile Name

String getInitials(String name) {
  if (name.isEmpty) return '';

  List<String> words = name.trim().split(RegExp(r'\s+'));
  String initials = words.map((word) => word[0].toUpperCase()).join('');

  return initials.substring(0, 1);
}

// TextFormField Decoration
InputDecoration textInputDecoration(BuildContext context, String label) {
  return InputDecoration(
    isDense: true,
    labelText: label,
    labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
          fontFamily: 'Inter',
          letterSpacing: 0.0,
        ),
    hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
          fontFamily: 'Inter',
          letterSpacing: 0.0,
        ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: FlutterFlowTheme.of(context).secondaryText,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: FlutterFlowTheme.of(context).primaryText,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: FlutterFlowTheme.of(context).error,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: FlutterFlowTheme.of(context).error,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: EdgeInsetsDirectional.fromSTEB(20, 14, 0, 14),
  );
}

 // Check Null
 bool checkNull(dynamic data){
  if(data != null && data != '' && data != 'null'){
    return true;
  }else{
    return false;
  }
 }

//getMonthNumber

String getMonthNumber(String monthAbbreviation) {
  DateTime date = DateFormat('MMM').parse(monthAbbreviation);
  return date.month.toString().padLeft(2, '0');
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  // Check permission status
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // Get current position
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

// Location
Future<List<dynamic>?> getLocation() async {
  try {
    Position position = await determinePosition();
    List<String?>? address = await getAddressFromCoordinates(position);
    return [address, position.latitude, position.longitude];
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
  } catch (e) {
    print('Error: $e');
  }
}

// getAddressFromCoordinates

Future<List<String?>?> getAddressFromCoordinates(Position position) async {
try {
List<Placemark> placemarks = await placemarkFromCoordinates(
position.latitude, position.longitude);

Placemark place = placemarks.first;
return [place.name, '${place.subLocality}, ${place.locality}, ${place.country}', place.postalCode.toString()];
} catch (e) {
print('Error: $e');
}
return null;
}

// CaptureScreenshot Image

ScreenshotController screenshotController = ScreenshotController();

Future<void> captureScreenshot() async {
  log('call function');
  final Uint8List? image = await screenshotController.capture();
  log('image: $image');
  if (image != null) {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/screenshot.png';
    final file = File(filePath);
    await file.writeAsBytes(image);
    log('Screenshot saved at: $filePath');
  }
}

// Pick Image

final ImagePicker _picker = ImagePicker();

Future<XFile?> pickImageFile() async {
  final ImagePicker picker = ImagePicker();

  try {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Compress the image
      File? compressedFile = await compressImage(File(pickedFile.path));

      if (compressedFile != null) {
        print("Original Size: ${await File(pickedFile.path).length()} bytes");
        print("Compressed Size: ${await compressedFile.length()} bytes");
        return XFile(compressedFile.path);
      }
    } else {
      print("No image selected.");
    }
  } catch (e) {
    print("Error picking image: $e");
  }
  return null;
}

Future<File?> compressImage(File file) async {
  final directory = await getTemporaryDirectory();
  final targetPath = '${directory.path}/compressed.jpg';

  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path, targetPath,
    quality: 70, // Reduce quality (1-100)
    minWidth: 1024, // Set min width
    minHeight: 1024, // Set min height
  );

  return result;
}

// AppBar

AppBar appBarWidget(BuildContext context, String name){
  return AppBar(
    backgroundColor: FlutterFlowTheme.of(context).primary,
    automaticallyImplyLeading: false,
    leading: FlutterFlowIconButton(
      borderColor: Colors.transparent,
      borderRadius: 30,
      borderWidth: 1,
      buttonSize: 60,
      icon: Icon(
        Icons.keyboard_backspace_rounded,
        color: Colors.white,
        size: 30,
      ),
      onPressed: () async {
        context.pop();
      },
    ),
    title: Text(
      name,
      style: FlutterFlowTheme.of(context).headlineSmall.override(
        fontFamily: 'Inter Tight',
        color: FlutterFlowTheme.of(context).primaryBackground,
        fontSize: 22,
        letterSpacing: 0.0,
      ),
    ),
    actions: [],
    centerTitle: false,
    elevation: 2,
  );
}

String todayDate() {
  DateTime now = DateTime.now();
  String formattedDate =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  print("Today's date is: $formattedDate");
  return formattedDate;
}

// format time stamp

String formatTimestamp(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp).toLocal(); // Convert to local timezone
  return DateFormat("dd MMM yy, hh:mm a").format(dateTime);
}


InputDecoration searchInputDecoration(BuildContext context, String hintText){
  return InputDecoration(
    isDense: true,
    labelStyle:
    FlutterFlowTheme.of(context).labelMedium.override(
      fontFamily: 'Inter',
      letterSpacing: 0.0,
    ),
    hintText: hintText,
    hintStyle:
    FlutterFlowTheme.of(context).labelMedium.override(
      fontFamily: 'Inter',
      letterSpacing: 0.0,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x00000000),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x00000000),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: FlutterFlowTheme.of(context).error,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: FlutterFlowTheme.of(context).error,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    suffixIcon: IconButton(icon: Icon(Icons.close), iconSize: 24, onPressed: (){

    },),
    fillColor: Color(0xFFF4F4F4),
    prefixIcon: Icon(
      Icons.search_rounded,
    ),
  );
}

// Get FCM Token
Future<String?> getFCMToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Get the token
  String? token = await messaging.getToken();

  if (token != null) {
    print("FCM Token: $token");
    return token;
  } else {
    print("Failed to get token");
      return null;
  }
}


String serviceName(List<dynamic> services) {
  // Use a list to collect the service names
  List<String> names = [];

  // Iterate over each service in the list
  for (final serv in services) {
    // Access the 'name' field inside 'service_id' and add it to the names list
    names.add(serv['service_id']['name']);
  }

  // Join the list of names with a comma and return the result
  return names.join(', ');
}

