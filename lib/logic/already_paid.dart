/// What to do right after money has gone to a scammer, by how it was paid.
/// Based on FTC guidance ("What To Do if You Were Scammed").
enum PaidWith {
  giftCard('Gift card', [
    'Call the company that sold the gift card right away. Use the phone '
        'number on the back of the card or on the store\'s website.',
    'Tell them it was used in a scam and ask them to freeze the money '
        'and refund you.',
    'Keep the card and your receipt.',
  ]),
  bankOrCard('Bank transfer, debit or credit card', [
    'Call your bank or card company using the number on the back of your '
        'card.',
    'Say "I was scammed" and ask them to stop or reverse the payment.',
    'Ask them to watch your account and to send you a new card if needed.',
  ]),
  wire('Wire transfer (Western Union, MoneyGram, bank wire)', [
    'Call the wire company or your bank immediately and ask them to cancel '
        'the transfer.',
    'Ask for a fraud claim to be opened. Speed matters most with wires.',
  ]),
  crypto('Bitcoin, crypto, or a Bitcoin ATM', [
    'Contact the crypto exchange or ATM company you used and report the '
        'fraud. Ask them to freeze the transaction.',
    'Save the receipt, wallet address and any messages.',
  ]),
  paymentApp('Payment app (Zelle, Venmo, Cash App, PayPal)', [
    'Report the payment inside the app right away.',
    'If it is linked to your bank or card, call them too and ask to reverse '
        'it.',
  ]),
  cash('Cash (mailed or handed to someone)', [
    'If you mailed it, call the shipping company (USPS, UPS, FedEx) and ask '
        'them to stop the package.',
    'If someone picked it up in person, call your local police.',
  ]),
  gaveAccess('I gave them a code, password, or access to my device', [
    'Turn off the internet on the device or shut it down if they are '
        'still connected.',
    'From another device, change your passwords, starting with email and '
        'bank.',
    'Call your bank and tell them your account may be at risk.',
  ]);

  const PaidWith(this.label, this.steps);

  final String label;
  final List<String> steps;
}

/// Steps that apply whatever the payment method was.
const List<String> alwaysDoSteps = [
  'It is not your fault. Scammers are professionals.',
  'Do not send any more money, even if they promise to return it.',
  'Tell a family member you trust.',
  'Report it to the FTC at ReportFraud.ftc.gov and to the FBI at ic3.gov.',
  'Be careful of "recovery" offers. People who promise to get your money '
      'back for a fee are often scammers too.',
];

final Uri ftcReportUrl = Uri.parse('https://reportfraud.ftc.gov/');
final Uri ic3ReportUrl = Uri.parse('https://www.ic3.gov/');

/// AARP Fraud Watch Network Helpline: free, open to anyone, not only members.
const String aarpHelplineNumber = '877-908-3360';
