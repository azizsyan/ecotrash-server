import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecotrash/core/providers/auth_provider.dart';
import 'package:ecotrash/main.dart';

void main() {
  testWidgets('Login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const EcoTrashApp(),
      ),
    );

    expect(find.text('EcoTrash'), findsOneWidget);
  });
}
