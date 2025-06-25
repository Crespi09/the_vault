import 'package:dio/dio.dart';
import 'package:vault_app/services/auth_service.dart';

class ApiService {
  late Dio _dio;
  final AuthService _authService;

  ApiService(this._authService) {
    _dio = Dio();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Aggiungi automaticamente il token a ogni richiesta
          if (_authService.isAuthenticated) {
            options.headers['Authorization'] =
                'Bearer ${_authService.accessToken}';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Gestisci errori 401 (token scaduto)
          if (error.response?.statusCode == 401) {
            // Qui potresti implementare il refresh del token
            _authService.logout();
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
