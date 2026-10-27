import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../core/errors/app_exception.dart';
import '../../services/ai_service.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';

class ChatEntry {
  ChatEntry({required this.isUser, required this.text});
  final bool isUser;
  final String text;
}

class AssistantController extends GetxController {
  AssistantController(this._auth, this._prefs, this._firebaseAuth);

  final AuthService _auth;
  final PreferencesService _prefs;
  final FirebaseAuth _firebaseAuth;

  final messages = <ChatEntry>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  AiService _serviceForUser() {
    final user = _auth.currentUser!;
    final url = _prefs.assistantBaseUrl(user.uid);
    return AiService(baseUrl: url, auth: _firebaseAuth);
  }

  Future<void> send(String question) async {
    if (question.trim().isEmpty) return;
    if (_auth.currentUser == null) {
      errorMessage.value = 'Sesión expirada.';
      return;
    }

    messages.add(ChatEntry(isUser: true, text: question.trim()));
    isLoading.value = true;
    errorMessage.value = null;
    final ai = _serviceForUser();
    try {
      final history = messages
          .take(messages.length - 1)
          .map(
            (m) => AssistantMessage(
              role: m.isUser ? 'user' : 'assistant',
              content: m.text,
            ),
          )
          .toList();
      final answer = await ai.askAssistant(
        question: question,
        history: history,
      );
      messages.add(ChatEntry(isUser: false, text: answer));
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'No se pudo contactar al asistente.';
    } finally {
      isLoading.value = false;
      ai.dispose();
    }
  }
}
