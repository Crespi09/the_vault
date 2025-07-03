import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vault_app/env.dart';

class UserService {
  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>> getUser(String accessToken) async {
    try {
      debugPrint('Con token: $accessToken');

      final response = await _dio.get(
        '${Env.apiBaseUrl}users/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Errore nel caricamento dati utente: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      debugPrint('Errore generico: $e');
      rethrow;
    }
  }
}
