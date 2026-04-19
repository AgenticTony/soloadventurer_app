import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';
import 'package:soloadventurer/features/verification/presentation/widgets/verification_badge.dart';

void main() {
  group('VerificationBadge', () {
    Widget buildWidget(VerificationTier tier, {double size = 16, bool showBackground = true}) {
      return MaterialApp(
        home: Scaffold(
          body: VerificationBadge(
            tier: tier,
            size: size,
            showBackground: showBackground,
          ),
        ),
      );
    }

    testWidgets('renders nothing for unverified', (tester) async {
      await tester.pumpWidget(buildWidget(VerificationTier.unverified));
      expect(find.byType(VerificationBadge), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsNothing);
      expect(find.byIcon(Icons.shield), findsNothing);
    });

    testWidgets('renders checkmark for emailVerified', (tester) async {
      await tester.pumpWidget(buildWidget(VerificationTier.emailVerified));
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('renders shield for idVerified', (tester) async {
      await tester.pumpWidget(buildWidget(VerificationTier.idVerified));
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('renders without background when showBackground is false', (tester) async {
      await tester.pumpWidget(buildWidget(VerificationTier.emailVerified, showBackground: false));
      expect(find.byIcon(Icons.verified), findsOneWidget);
      // No Container wrapping the icon (just the icon itself)
      final icon = tester.widget<Icon>(find.byIcon(Icons.verified));
      expect(icon.size, 16);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(buildWidget(VerificationTier.idVerified, size: 24));
      final icon = tester.widget<Icon>(find.byIcon(Icons.shield));
      expect(icon.size, 22); // size - 2 because of background
    });
  });

  group('VerificationStatusCard', () {
    Widget buildCard(VerificationTier tier, {VoidCallback? onTapVerify}) {
      return MaterialApp(
        home: Scaffold(
          body: VerificationStatusCard(
            tier: tier,
            onTapVerify: onTapVerify,
          ),
        ),
      );
    }

    testWidgets('shows "Not Verified" for unverified', (tester) async {
      await tester.pumpWidget(buildCard(VerificationTier.unverified));
      expect(find.text('Not Verified'), findsOneWidget);
    });

    testWidgets('shows "Photo Verified" for emailVerified', (tester) async {
      await tester.pumpWidget(buildCard(VerificationTier.emailVerified));
      expect(find.text('Photo Verified'), findsOneWidget);
    });

    testWidgets('shows "ID Verified" for idVerified', (tester) async {
      await tester.pumpWidget(buildCard(VerificationTier.idVerified));
      expect(find.text('ID Verified'), findsOneWidget);
    });

    testWidgets('shows "Verify Now" link when onTapVerify provided and unverified', (tester) async {
      await tester.pumpWidget(buildCard(
        VerificationTier.unverified,
        onTapVerify: () {},
      ));
      expect(find.text('Verify Now'), findsOneWidget);
    });

    testWidgets('does not show "Verify Now" when verified', (tester) async {
      await tester.pumpWidget(buildCard(
        VerificationTier.emailVerified,
        onTapVerify: () {},
      ));
      expect(find.text('Verify Now'), findsNothing);
    });
  });
}
