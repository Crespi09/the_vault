import 'package:dio/dio.dart';

class UserService {
  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>> getUser(String accessToken) async {
    try {
      final response = await _dio.get(
        'http://10.0.2.2:3000/users/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
          'Errore nel caricamento dati utente: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Errore durante fetchUserData: $e');
    }
  }
}
