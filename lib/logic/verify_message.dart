import '../data/family_contact.dart';
import 'red_flags.dart';

/// Builds the text message sent to a trusted family member when the user
/// presses "Is this really you?".
String buildVerifyMessage({
  required String senderName,
  required FamilyContact contact,
  String claimedToBe = '',
  String amount = '',
  Iterable<RedFlag> flags = const [],
}) {
  final who = senderName.trim().isEmpty ? 'Me' : senderName.trim();
  final claimed = claimedToBe.trim();
  final money = amount.trim();

  final buffer = StringBuffer()
    ..write('$who here, checking with you before I do anything. ')
    ..write(
      claimed.isEmpty
          ? 'Someone just contacted me asking for money'
          : 'Someone saying they are $claimed just contacted me asking for money',
    )
    ..write(money.isEmpty ? '.' : ' ($money).');

  final flagList = flags.toList();
  if (flagList.isNotEmpty) {
    buffer
      ..write(' Warning signs: ')
      ..write(flagList.map(_shortLabel).join(', '))
      ..write('.');
  }

  buffer.write(
    ' Was this you, or do you know about it? Please call me back. '
    "I won't send anything until we talk.",
  );
  return buffer.toString();
}

String _shortLabel(RedFlag flag) {
  switch (flag) {
    case RedFlag.giftCards:
      return 'wants gift cards';
    case RedFlag.crypto:
      return 'wants crypto';
    case RedFlag.wireOrCash:
      return 'wants wire or cash';
    case RedFlag.keepSecret:
      return 'told me to keep it secret';
    case RedFlag.remoteAccess:
      return 'wants access to my device';
    case RedFlag.authority:
      return 'claims to be an official';
    case RedFlag.familyEmergency:
      return 'family emergency story';
    case RedFlag.urgency:
      return 'says it is urgent';
    case RedFlag.unusualNumber:
      return 'unknown number';
    case RedFlag.codeOrPassword:
      return 'wants a code or password';
  }
}

/// Built with encodeComponent rather than queryParameters: the latter turns
/// spaces into "+", which some SMS apps show literally.
Uri smsUri(FamilyContact contact, String body) => Uri(
  scheme: 'sms',
  path: contact.dialable,
  query: 'body=${Uri.encodeComponent(body)}',
);

Uri telUri(String number) =>
    Uri(scheme: 'tel', path: number.replaceAll(RegExp(r'[^0-9+]'), ''));
