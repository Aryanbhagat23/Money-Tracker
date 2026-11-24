import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'family_contact.dart';

/// Where the app keeps its data. Everything stays on the phone: there is no
/// account and no server in this version.
abstract class AppStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);

  /// For secrets such as the family safe word.
  Future<String?> readSecret(String key);
  Future<void> writeSecret(String key, String value);
  Future<void> deleteSecret(String key);
}

class DeviceStorage implements AppStorage {
  DeviceStorage(this._prefs, [FlutterSecureStorage? secure])
    : _secure = secure ?? const FlutterSecureStorage();

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  @override
  Future<String?> read(String key) async => _prefs.getString(key);
  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);
  @override
  Future<void> delete(String key) => _prefs.remove(key);
  @override
  Future<String?> readSecret(String key) => _secure.read(key: key);
  @override
  Future<void> writeSecret(String key, String value) =>
      _secure.write(key: key, value: value);
  @override
  Future<void> deleteSecret(String key) => _secure.delete(key: key);
}

class MemoryStorage implements AppStorage {
  final Map<String, String> values = {};
  final Map<String, String> secrets = {};

  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<void> delete(String key) async => values.remove(key);
  @override
  Future<String?> readSecret(String key) async => secrets[key];
  @override
  Future<void> writeSecret(String key, String value) async =>
      secrets[key] = value;
  @override
  Future<void> deleteSecret(String key) async => secrets.remove(key);
}

/// App state: the user's name, trusted family contacts, safe word, and
/// display preferences.
class AppStore extends ChangeNotifier {
  AppStore(this._storage);

  static const _kContacts = 'contacts';
  static const _kUserName = 'user_name';
  static const _kTextScale = 'text_scale';
  static const _kOnboarded = 'onboarded';
  static const _kSafeWord = 'safe_word';

  final AppStorage _storage;

  List<FamilyContact> _contacts = [];
  String _userName = '';
  String? _safeWord;
  double _textScale = 1.25;
  bool _onboarded = false;

  List<FamilyContact> get contacts => List.unmodifiable(_contacts);
  String get userName => _userName;
  String? get safeWord => _safeWord;
  bool get hasSafeWord => (_safeWord ?? '').isNotEmpty;
  double get textScale => _textScale;
  bool get onboarded => _onboarded;

  Future<void> load() async {
    _contacts = FamilyContact.decodeList(await _storage.read(_kContacts));
    _userName = await _storage.read(_kUserName) ?? '';
    _textScale =
        double.tryParse(await _storage.read(_kTextScale) ?? '') ?? 1.25;
    _onboarded = (await _storage.read(_kOnboarded)) == 'true';
    _safeWord = await _storage.readSecret(_kSafeWord);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim();
    await _storage.write(_kUserName, _userName);
    notifyListeners();
  }

  Future<void> setTextScale(double scale) async {
    _textScale = scale.clamp(1.0, 2.0);
    await _storage.write(_kTextScale, _textScale.toString());
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboarded = true;
    await _storage.write(_kOnboarded, 'true');
    notifyListeners();
  }

  Future<void> setSafeWord(String? word) async {
    final trimmed = word?.trim() ?? '';
    if (trimmed.isEmpty) {
      _safeWord = null;
      await _storage.deleteSecret(_kSafeWord);
    } else {
      _safeWord = trimmed;
      await _storage.writeSecret(_kSafeWord, trimmed);
    }
    notifyListeners();
  }

  Future<void> saveContact(FamilyContact contact) async {
    final i = _contacts.indexWhere((c) => c.id == contact.id);
    if (i >= 0) {
      _contacts[i] = contact;
    } else {
      _contacts.add(contact);
    }
    await _persistContacts();
  }

  Future<void> removeContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    await _persistContacts();
  }

  Future<void> _persistContacts() async {
    await _storage.write(_kContacts, FamilyContact.encodeList(_contacts));
    notifyListeners();
  }

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
