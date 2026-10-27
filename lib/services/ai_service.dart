import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';

class AssistantMessage {
  const AssistantMessage({required this.role, required this.content});
  final String role;
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AiService {
  AiService({
    required this.baseUrl,
    required FirebaseAuth auth,
    http.Client? client,
  }) : _auth = auth,
       _client = client ?? http.Client();

  final String baseUrl;
  final FirebaseAuth _auth;
  final http.Client _client;

  Future<String> askAssistant({
    required String question,
    List<AssistantMessage>? history,
  }) async {
    if (baseUrl.isEmpty) {
      throw const NotConfiguredException(
        'Configure la URL del servidor del asistente en Ajustes.',
      );
    }
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('Debe iniciar sesión para usar el asistente.');
    }
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw const AuthException('Sesión expirada. Vuelva a iniciar sesión.');
    }

    final uri = Uri.parse('$baseUrl/assistant');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'question': question,
        'history': history?.map((m) => m.toJson()).toList() ?? [],
        'disclaimerAccepted': true,
      }),
    );

    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }
    if (response.statusCode == 503) {
      throw const NotConfiguredException(
        'El proveedor de IA no está configurado en el servidor.',
      );
    }
    if (response.statusCode >= 400) {
      throw FirebaseAppException(
        'No se pudo obtener respuesta del asistente (${response.statusCode}).',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final answer = body['answer'] as String?;
    if (answer == null || answer.isEmpty) {
      throw const FirebaseAppException('Respuesta vacía del asistente.');
    }
    return '$answer\n\n${AppConstants.assistantDisclaimer}';
  }

  void dispose() => _client.close();
}
