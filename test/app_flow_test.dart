import 'package:flutter_test/flutter_test.dart';
import 'package:kinfirm/data/app_store.dart';
import 'package:kinfirm/data/family_contact.dart';
import 'package:kinfirm/main.dart';
import 'package:kinfirm/services/launcher.dart';
import 'package:material_ui/material_ui.dart';

Future<(AppStore, RecordingLauncher)> pumpApp(
  WidgetTester tester, {
  bool onboarded = true,
  bool withContact = true,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  final store = AppStore(MemoryStorage());
  await store.load();
  if (withContact) {
    await store.saveContact(
      const FamilyContact(
        id: 'c1',
        name: 'Alex',
        phone: '555-123-4567',
        relation: 'grandson',
      ),
    );
  }
  await store.setUserName('Mary');
  await store.setTextScale(1.0);
  if (onboarded) await store.completeOnboarding();
  final launcher = RecordingLauncher();
  await tester.pumpWidget(KinfirmApp(store: store, launcher: launcher));
  await tester.pumpAndSettle();
  return (store, launcher);
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    // Lazily built list items: scroll until it exists.
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('gift-card request shows a scam warning and texts family', (
    tester,
  ) async {
    final (_, launcher) = await pumpApp(tester);

    await tapAndSettle(tester, find.byKey(const ValueKey('btn-asking')));
    expect(find.text('Pause. You are in control.'), findsOneWidget);
    await tapAndSettle(tester, find.text('I have paused'));

    await tester.enterText(find.byType(TextField).at(0), 'my grandson');
    await tester.enterText(find.byType(TextField).at(1), r'$2,000');
    await tapAndSettle(tester, find.byKey(const ValueKey('flag-giftCards')));
    await tapAndSettle(tester, find.text('What does this mean?'));

    expect(find.text('Stop. This looks like a scam.'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('text-c1')));
    final sms = launcher.opened.single;
    expect(sms.scheme, 'sms');
    expect(sms.path, '5551234567');
    final body = Uri.decodeComponent(sms.query.substring('body='.length));
    expect(body, contains('Mary here'));
    expect(body, contains('my grandson'));
    expect(body, contains('wants gift cards'));

    await tapAndSettle(tester, find.byKey(const ValueKey('call-c1')));
    expect(launcher.opened.last.toString(), 'tel:5551234567');

    await tapAndSettle(tester, find.text('Back to start'));
    expect(find.byKey(const ValueKey('btn-asking')), findsOneWidget);
  });

  testWidgets('no ticks gives a "still check" result, not "safe"', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapAndSettle(tester, find.byKey(const ValueKey('btn-asking')));
    await tapAndSettle(tester, find.text('I have paused'));
    await tapAndSettle(tester, find.text('What does this mean?'));
    expect(
      find.text('No warning signs picked, but still check.'),
      findsOneWidget,
    );
  });

  testWidgets('safe word reminder appears once a safe word is set', (
    tester,
  ) async {
    final (store, _) = await pumpApp(tester);
    await store.setSafeWord('pancakes');
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.byKey(const ValueKey('btn-family')));
    expect(
      find.textContaining('What is our family safe word?'),
      findsOneWidget,
    );
    expect(find.textContaining('pancakes'), findsNothing);
  });

  testWidgets('already-paid screen shows method steps and report links', (
    tester,
  ) async {
    final (_, launcher) = await pumpApp(tester);
    await tapAndSettle(tester, find.byKey(const ValueKey('btn-paid')));
    await tapAndSettle(tester, find.byKey(const ValueKey('paid-giftCard')));
    expect(
      find.textContaining('Call the company that sold the gift card'),
      findsOneWidget,
    );
    await tapAndSettle(tester, find.text('Report to the FTC'));
    expect(launcher.opened.last.host, 'reportfraud.ftc.gov');
  });

  testWidgets('onboarding: add a contact, then start', (tester) async {
    final (store, _) = await pumpApp(
      tester,
      onboarded: false,
      withContact: false,
    );
    expect(find.text('Welcome to Kinfirm'), findsOneWidget);

    final start = find.byKey(const ValueKey('finish-onboarding'));
    expect(tester.widget<FilledButton>(start).onPressed, isNull);

    await tapAndSettle(tester, find.text('Add a family member you trust'));
    await tester.enterText(find.byKey(const ValueKey('contact-name')), 'Alex');
    await tester.enterText(find.byKey(const ValueKey('contact-phone')), '12');
    await tapAndSettle(tester, find.byKey(const ValueKey('save-contact')));
    expect(find.text('Please enter a full phone number'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('contact-phone')),
      '555 123 4567',
    );
    await tapAndSettle(tester, find.byKey(const ValueKey('save-contact')));
    expect(store.contacts.single.name, 'Alex');

    await tapAndSettle(tester, start);
    expect(store.onboarded, isTrue);
    expect(find.byKey(const ValueKey('btn-asking')), findsOneWidget);
  });

  testWidgets('checking earns praise and a counter on the home screen', (
    tester,
  ) async {
    final (store, _) = await pumpApp(tester);
    expect(find.textContaining('You checked'), findsNothing);

    await tapAndSettle(tester, find.byKey(const ValueKey('btn-asking')));
    await tapAndSettle(tester, find.text('I have paused'));
    await tapAndSettle(tester, find.text('What does this mean?'));
    expect(find.text('You did the right thing.'), findsOneWidget);
    expect(store.pauseCount, 1);

    await tapAndSettle(tester, find.text('Back to start'));
    expect(find.text('You checked 1 time. Well done!'), findsOneWidget);
  });

  testWidgets('protection score reflects setup progress', (tester) async {
    final (store, _) = await pumpApp(tester);
    // Contact + name set, no safe word yet: 2 of 3.
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('Next: choose a family safe word.'), findsOneWidget);

    await store.setSafeWord('pancakes');
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Fully protected'), findsOneWidget);
  });

  testWidgets('works with reduced motion and the largest text size', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final (store, _) = await pumpApp(tester);
    await store.setTextScale(2.0);
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.byKey(const ValueKey('btn-asking')));
    expect(find.text('You are calm\nand in control'), findsOneWidget);
    await tapAndSettle(tester, find.text('I have paused'));
    await tapAndSettle(tester, find.byKey(const ValueKey('flag-crypto')));
    await tapAndSettle(tester, find.text('What does this mean?'));
    expect(find.text('Stop. This looks like a scam.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
