// Basic Flutter widget test for app initialization
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:sportspace_app/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Build our app with CookieRequest provider
    await tester.pumpWidget(
      Provider(
        create: (_) => CookieRequest(),
        child: const MyApp(),
      ),
    );

    // Just verify the app builds - don't check layout as test environment may have different constraints
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
