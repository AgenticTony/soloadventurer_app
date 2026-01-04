import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/screens/create_journal_entry_screen.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';

/// Example screen demonstrating how to use CreateJournalEntryScreen
///
/// This shows how to integrate the journal entry creation screen into your app.
class JournalEntryExample extends ConsumerWidget {
  const JournalEntryExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Travel Journal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateJournalEntryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Entry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateJournalEntryScreen(
                      tripId: 'example-trip-id',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.flight_takeoff),
              label: const Text('Create Entry for Trip'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider scope for running the example
class JournalEntryExampleApp extends StatelessWidget {
  const JournalEntryExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: MaterialApp(
        home: JournalEntryExample(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Usage instructions:
///
/// 1. To test the CreateJournalEntryScreen in isolation:
/// ```dart
/// runApp(const JournalEntryExampleApp());
/// ```
///
/// 2. To integrate into your app's navigation:
/// Add to your app router:
/// ```dart
/// case CreateJournalEntryScreen.routeName:
///   screen = const CreateJournalEntryScreen();
///   break;
/// ```
///
/// 3. To navigate to the screen:
/// ```dart
/// Navigator.of(context).pushNamed(CreateJournalEntryScreen.routeName);
///
/// // Or with a trip ID:
/// Navigator.of(context).push(
///   MaterialPageRoute(
///     builder: (context) => CreateJournalEntryScreen(
///       tripId: 'your-trip-id',
///     ),
///   ),
/// );
/// ```
///
/// 4. To check if entry was saved:
/// ```dart
/// final result = await Navigator.of(context).push<bool>(
///   MaterialPageRoute(
///     builder: (context) => const CreateJournalEntryScreen(),
///   ),
/// );
///
/// if (result == true) {
///   // Entry was saved successfully
///   // Refresh your journal list or show success message
/// }
/// ```
