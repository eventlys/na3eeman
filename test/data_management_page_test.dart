import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Packages/features/owner/dashboard/pages/data_management_page.dart';

void main() {
  testWidgets('DataManagementPage shows export and import sections', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: DataManagementPage(),
    ));

    // Verify sections existence
    expect(find.text('Export Data'), findsOneWidget);
    expect(find.text('Import Data'), findsOneWidget);
    
    // Verify specific dataset chips or buttons (mocking actual implementation details found in file)
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}
