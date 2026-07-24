import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chat_volc/main.dart';
import 'package:chat_volc/services/api_client.dart';
import 'package:chat_volc/services/session_controller.dart';

void main() {
  testWidgets('Login screen shows Chat Volc', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final session = SessionController(ApiClient());
    await session.load();
    await tester.pumpWidget(ChatVolcApp(session: session));
    await tester.pumpAndSettle();

    expect(find.textContaining('Chat Volc'), findsWidgets);
  });
}
