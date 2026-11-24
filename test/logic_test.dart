import 'package:flutter_test/flutter_test.dart';
import 'package:kinfirm/data/app_store.dart';
import 'package:kinfirm/data/family_contact.dart';
import 'package:kinfirm/logic/red_flags.dart';
import 'package:kinfirm/logic/verify_message.dart';

void main() {
  group('assessRisk', () {
    test('nothing ticked is "unknown", never safe', () {
      final r = assessRisk(const []);
      expect(r.level, RiskLevel.unknown);
      expect(r.headline.toLowerCase(), isNot(contains('safe')));
      expect(r.advice, contains('check'));
    });

    test('any severe sign alone is high', () {
      for (final f in RedFlag.values.where((f) => f.severe)) {
        expect(assessRisk([f]).level, RiskLevel.high, reason: f.name);
      }
    });

    test('one or two mild signs are medium', () {
      expect(assessRisk([RedFlag.urgency]).level, RiskLevel.medium);
      expect(
        assessRisk([RedFlag.urgency, RedFlag.authority]).level,
        RiskLevel.medium,
      );
    });

    test('three mild signs together are high', () {
      expect(
        assessRisk([RedFlag.urgency, RedFlag.authority, RedFlag.unusualNumber])
            .level,
        RiskLevel.high,
      );
    });

    test('duplicates are ignored and flags are kept in a stable order', () {
      final r = assessRisk([
        RedFlag.urgency,
        RedFlag.giftCards,
        RedFlag.urgency,
      ]);
      expect(r.flags, [RedFlag.giftCards, RedFlag.urgency]);
    });
  });

  group('verify message', () {
    const contact = FamilyContact(
      id: '1',
      name: 'Alex',
      phone: '(555) 123-4567',
    );

    test('includes who they claimed to be, amount and warning signs', () {
      final msg = buildVerifyMessage(
        senderName: 'Mary',
        contact: contact,
        claimedToBe: 'my grandson',
        amount: r'$3,000',
        flags: [RedFlag.giftCards, RedFlag.keepSecret],
      );
      expect(msg, startsWith('Mary here'));
      expect(msg, contains('saying they are my grandson'));
      expect(msg, contains(r'($3,000)'));
      expect(msg, contains('wants gift cards, told me to keep it secret'));
      expect(msg, contains("won't send anything"));
    });

    test('works with nothing filled in', () {
      final msg = buildVerifyMessage(senderName: ' ', contact: contact);
      expect(msg, startsWith('Me here'));
      expect(msg, contains('asking for money.'));
      expect(msg, isNot(contains('Warning signs')));
    });

    test('sms link keeps spaces as %20, not +', () {
      final uri = smsUri(contact, 'hi there');
      expect(uri.toString(), 'sms:5551234567?body=hi%20there');
    });

    test('tel link strips formatting', () {
      expect(telUri('877-908-3360').toString(), 'tel:8779083360');
    });
  });

  group('FamilyContact', () {
    test('validates phone numbers', () {
      expect(
        const FamilyContact(
          id: '',
          name: '',
          phone: '+1 555 123 4567',
        ).hasValidPhone,
        isTrue,
      );
      expect(
        const FamilyContact(id: '', name: '', phone: '123').hasValidPhone,
        isFalse,
      );
      expect(
        const FamilyContact(id: '', name: '', phone: '').hasValidPhone,
        isFalse,
      );
    });

    test('round-trips through JSON and survives corrupt data', () {
      const list = [
        FamilyContact(
          id: 'a',
          name: 'Alex',
          phone: '5551234567',
          relation: 'son',
        ),
      ];
      expect(FamilyContact.decodeList(FamilyContact.encodeList(list)), list);
      expect(FamilyContact.decodeList('not json'), isEmpty);
      expect(FamilyContact.decodeList('[{"id": 1}]'), isEmpty);
      expect(FamilyContact.decodeList(null), isEmpty);
    });
  });

  group('AppStore', () {
    test(
      'persists contacts, name, scale and keeps safe word in secret store',
      () async {
        final storage = MemoryStorage();
        final store = AppStore(storage);
        await store.load();
        await store.saveContact(
          const FamilyContact(id: 'a', name: 'Alex', phone: '5551234567'),
        );
        await store.setUserName('  Mary ');
        await store.setTextScale(5);
        await store.setSafeWord(' pancakes ');

        expect(storage.secrets['safe_word'], 'pancakes');
        expect(storage.values.values.join(), isNot(contains('pancakes')));

        final reloaded = AppStore(storage);
        await reloaded.load();
        expect(reloaded.contacts.single.name, 'Alex');
        expect(reloaded.userName, 'Mary');
        expect(reloaded.textScale, 2.0);
        expect(reloaded.safeWord, 'pancakes');

        await reloaded.saveContact(
          const FamilyContact(id: 'a', name: 'Alexander', phone: '5551234567'),
        );
        expect(reloaded.contacts.single.name, 'Alexander');
        await reloaded.removeContact('a');
        expect(reloaded.contacts, isEmpty);

        await reloaded.setSafeWord('  ');
        expect(reloaded.hasSafeWord, isFalse);
        expect(storage.secrets.containsKey('safe_word'), isFalse);
      },
    );
  });
}
