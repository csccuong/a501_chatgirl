import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class TestCrashlyticsPage extends StatelessWidget {
  const TestCrashlyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Crashlytics')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Test non-fatal error
                try {
                  throw Exception('Test non-fatal error from Crashlytics');
                } catch (e, stack) {
                  FirebaseCrashlytics.instance.recordError(e, stack);
                }
              },
              child: const Text('Test Non-Fatal Error'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Test fatal crash
                throw Exception('Test fatal crash from Crashlytics');
              },
              child: const Text('Test Fatal Crash (App will close)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Test custom log
                FirebaseCrashlytics.instance.log('User tapped test button');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Log sent to Crashlytics')),
                );
              },
              child: const Text('Send Custom Log'),
            ),
          ],
        ),
      ),
    );
  }
}
