import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  String? _accessToken;
  String? _refreshToken;
  bool _isAuthenticated = false;

  // Getters
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _isAuthenticated;

  // Inizializza il servizio caricando i token salvati
  Future<void> init() async {
    await _loadTokens();
  }

  // Carica i token dal secure storage
  Future<void> _loadTokens() async {
    try {
      _accessToken = await _storage.read(key: _accessTokenKey);
      _refreshToken = await _storage.read(key: _refreshTokenKey);
      _isAuthenticated = _accessToken != null && _refreshToken != null;
      notifyListeners();
    } catch (e) {
      debugPrint('Errore nel caricamento dei token: $e');
    }
  }

  // Salva i token dopo il login
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);

      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _isAuthenticated = true;

      notifyListeners();
      debugPrint('Token salvati con successo');
    } catch (e) {
      debugPrint('Errore nel salvataggio dei token: $e');
      throw Exception('Impossibile salvare i token');
    }
  }

  // Logout - elimina i token
  Future<void> logout() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);

      _accessToken = null;
      _refreshToken = null;
      _isAuthenticated = false;

      notifyListeners();
      debugPrint('Logout completato');
    } catch (e) {
      debugPrint('Errore durante il logout: $e');
    }
  }

  // Elimina tutti i dati dal secure storage
  Future<void> clearAllData() async {
    try {
      await _storage.deleteAll();
      _accessToken = null;
      _refreshToken = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Errore nella pulizia dei dati: $e');
    }
  }
}
