import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ocr_app/main.dart';
import 'package:ocr_app/providers/ocr_provider.dart';

void main() {
  testWidgets('App should start with HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OcrProvider()),
        ],
        child: const OcrApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('OCR识别'), findsOneWidget);
    expect(find.text('拍照识别'), findsOneWidget);
    expect(find.text('从相册选择'), findsOneWidget);
  });

  testWidgets('Should show camera and gallery buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OcrProvider()),
        ],
        child: const OcrApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.camera_alt), findsWidgets);
    expect(find.byIcon(Icons.photo_library), findsOneWidget);
  });

  testWidgets('Should have bottom navigation bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OcrProvider()),
        ],
        child: const OcrApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('识别'), findsOneWidget);
    expect(find.text('历史'), findsOneWidget);
  });
}
