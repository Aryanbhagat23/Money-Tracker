/// The warning signs a person can tick off while (or after) someone asks
/// them for money. Each one comes from FBI / FTC guidance on imposter,
/// grandparent and "government agent" scams.
enum RedFlag {
  giftCards(
    question: 'They want gift cards',
    why: 'No real person, company or government agency asks to be paid in gift cards.',
    severe: true,
  ),
  crypto(
    question: 'They want Bitcoin, crypto, or a Bitcoin ATM',
    why: 'Crypto payments can almost never be reversed. Scammers love them for that reason.',
    severe: true,
  ),
  wireOrCash(
    question: 'They want a wire transfer, cash, or a courier to pick up money',
    why: 'Wires and cash handed to a courier are very hard to get back.',
    severe: true,
  ),
  keepSecret(
    question: 'They told me not to tell anyone',
    why: 'Scammers ask for secrecy so nobody can warn you. Family never needs you to hide an emergency.',
    severe: true,
  ),
  remoteAccess(
    question:
        'They want me to install an app or let them into my computer or phone',
    why: 'Remote access lets them see your bank and move your money.',
    severe: true,
  ),
  authority(
    question: 'They say they are police, a lawyer, the IRS, Social Security, or my bank',
    why: 'Real officials never demand payment over the phone or threaten arrest.',
    severe: false,
  ),
  familyEmergency(
    question: 'It is a family member in trouble (jail, accident, hospital)',
    why: 'This is the "grandparent scam". AI can now copy a voice from a few seconds of audio.',
    severe: false,
  ),
  urgency(
    question: 'They say I must act right now',
    why: 'Pressure is a trick to stop you from thinking or checking.',
    severe: false,
  ),
  unusualNumber(
    question: 'The call or message came from a number I do not know',
    why: 'Scammers use new numbers. Even a familiar number on screen can be faked.',
    severe: false,
  ),
  codeOrPassword(
    question: 'They want a code sent to my phone, or my password',
    why: 'Sharing a code lets them break into your accounts.',
    severe: true,
  );

  const RedFlag({
    required this.question,
    required this.why,
    required this.severe,
  });

  /// Plain-language yes/no prompt shown to the user.
  final String question;

  /// Why this sign matters, shown when it was ticked.
  final String why;

  /// A sign that on its own is almost always a scam.
  final bool severe;
}

/// How worried the person should be. There is deliberately no "safe" level:
/// the app can never know a request is genuine, only that it found no
/// warning signs. Every result still tells the person to verify.
enum RiskLevel { high, medium, unknown }

class RiskResult {
  const RiskResult(this.level, this.flags);

  final RiskLevel level;
  final List<RedFlag> flags;

  String get headline {
    switch (level) {
      case RiskLevel.high:
        return 'Stop. This looks like a scam.';
      case RiskLevel.medium:
        return 'Be careful. This has warning signs.';
      case RiskLevel.unknown:
        return 'No warning signs picked, but still check.';
    }
  }

  String get advice {
    switch (level) {
      case RiskLevel.high:
        return 'Do not send money or share any codes. Hang up and call your '
            'family member on the number you already have for them.';
      case RiskLevel.medium:
        return 'Do not pay yet. Hang up and check with a family member or '
            'call the organization on a number you look up yourself.';
      case RiskLevel.unknown:
        return 'Scams can still look normal. Before you send money, check '
            'with a family member you trust.';
    }
  }
}

/// Scores the ticked warning signs.
///
/// High: any severe sign, or three or more signs together.
/// Medium: one or two non-severe signs.
/// Unknown: nothing ticked (never "safe").
RiskResult assessRisk(Iterable<RedFlag> ticked) {
  final flags = ticked.toSet().toList()
    ..sort((a, b) => a.index.compareTo(b.index));
  if (flags.isEmpty) return RiskResult(RiskLevel.unknown, flags);
  final anySevere = flags.any((f) => f.severe);
  if (anySevere || flags.length >= 3) return RiskResult(RiskLevel.high, flags);
  return RiskResult(RiskLevel.medium, flags);
}
