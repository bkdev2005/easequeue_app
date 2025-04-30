import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    secureStorage = FlutterSecureStorage();

    _safeInit(() {
      if (prefs.containsKey('ff_user')) {
        try {
          _user = jsonDecode(prefs.getString('ff_user') ?? '');
        } catch (e) {
          print("Can't decode persisted json. Error: $e.");
        }
      }
    });
    _safeInit(() {
      _whoAreU = prefs.getString('ff_whoAreU') ?? _whoAreU;
    });
    _safeInit(() {
      _token = prefs.getString('ff_token') ?? _token;
    });
    _safeInit(() {
      _phone = prefs.getString('ff_phone') ?? _phone;
    });
    _safeInit(() {
      _address_id = prefs.getString('ff_address_id') ?? _address_id;
    });
    _safeInit(() {
      _user = prefs.getInt('ff_user') ?? _user;
    });
    _safeInit(() {
      _userId = prefs.getString('ff_userId') ?? _userId;
    });
    _safeInit(() {
      _businessDetail = prefs.getString('ff_businessDetail') ?? _businessDetail;
    });
    _safeInit(() {
      _employeeId = prefs.getString('ff_employeeId') ?? _employeeId;
    });
    _safeInit(() {
      _employeeDetail = prefs.getString('ff_employeeDetail') ?? _employeeDetail;
    });
    _safeInit(() {
      _queueID = prefs.getString('ff_queueID') ?? _queueID;
    });
    _safeInit(() {
      _fistTimeUser = prefs.getBool('ff_fistTimeUser') ?? _fistTimeUser;
    });
    _safeInit(() {
      _punch = prefs.getBool('ff_punch') ?? _punch;
    });
    _safeInit(() {
      _firstPunch = prefs.getString('ff_firstPunch') ?? _firstPunch;
    });
    _safeInit(() {
      _lastPunch = prefs.getString('ff_lastPunch') ?? _lastPunch;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;
  late FlutterSecureStorage secureStorage;

  String _token = '';
  String get token => _token;
  set token(String _value) {
    _token = _value;
    prefs.setString('ff_token', _value);
  }

  String _phone = '';
  String get phone => _phone;
  set phone(String _value) {
    _phone = _value;
    prefs.setString('ff_phone', _value);
  }

  String _address_id = '';
  String get address_id => _address_id;
  set address_id(String _value) {
    _address_id = _value;
    prefs.setString('ff_address_id', _value);
  }

  String _userId = '';
  String get userId => _userId;
  set userId(String _value) {
    _userId = _value;
    prefs.setString('ff_userId', _value);
  }

  String _employeeId = '';
  String get employeeId => _employeeId;
  set employeeId(String _value) {
    _employeeId = _value;
    prefs.setString('ff_employeeId', _value);
  }

  bool _fistTimeUser = false;
  bool get fistTimeUser => _fistTimeUser;
  set fistTimeUser(bool _value) {
    _fistTimeUser = _value;
    prefs.setBool('ff_fistTimeUser', _value);
  }

  String _whoAreU = '0';
  String get whoAreU => _whoAreU;
  set whoAreU(String _value) {
    _whoAreU = _value;
    prefs.setString('ff_whoAreU', _value);
  }

  bool _punch = false;
  bool get punch => _punch;
  set punch(bool _value) {
    _punch = _value;
    prefs.setBool('ff_punch', _value);
  }

  String _firstPunch = '';
  String get firstPunch => _firstPunch;
  set firstPunch(String _value) {
    _firstPunch = _value;
    prefs.setString('ff_firstPunch', _value);
  }

  String _lastPunch = '';
  String get lastPunch => _lastPunch;
  set lastPunch(String _value) {
    _lastPunch = _value;
    prefs.setString('ff_lastPunch', _value);
  }


  dynamic _user;
  dynamic get user => _user;
  set user(dynamic _value) {
    _user = _value;
    prefs.setString('ff_user', jsonEncode(_value));
  }

  dynamic _businessDetail;
  dynamic get businessDetail => _businessDetail;
  set businessDetail(dynamic _value) {
    _businessDetail = _value;
    prefs.setString('ff_businessDetail', jsonEncode(_value));
  }

  dynamic _employeeDetail;
  dynamic get employeeDetail => _employeeDetail;
  set employeeDetail(dynamic _value) {
    _employeeDetail = _value;
    prefs.setString('ff_employeeDetail', jsonEncode(_value));
  }
  dynamic _queueID;
  dynamic get queueID => _queueID;
  set queueID(dynamic _value) {
    _queueID = _value;
    prefs.setString('ff_queueID', jsonEncode(_value));
  }
}

LatLng? _latLngFromString(String? val) {
  if (val == null) {
    return null;
  }
  final split = val.split(',');
  final lat = double.parse(split.first);
  final lng = double.parse(split.last);
  return LatLng(lat, lng);
}
extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
