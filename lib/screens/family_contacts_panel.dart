import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../data/family_contact.dart';
import '../logic/red_flags.dart';
import '../logic/verify_message.dart';
import '../theme.dart';
import '../widgets/effects.dart';
import 'setup_screen.dart';

/// Safe-word reminder plus a Call / "Is this really you?" text button for
/// every trusted family member.
class FamilyContactsPanel extends StatelessWidget {
  const FamilyContactsPanel({
    super.key,
    this.claimedToBe = '',
    this.amount = '',
    this.flags = const [],
  });

  final String claimedToBe;
  final String amount;
  final List<RedFlag> flags;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.store(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (store.hasSafeWord) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: Brand.caution,
              borderRadius: BorderRadius.circular(22),
              boxShadow: softShadow(Brand.amber),
            ),
            child: const Row(
              children: [
                Icon(Icons.key_rounded, color: Brand.navy, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Ask the caller: "What is our family safe word?"\n'
                    'If they cannot say it, hang up.',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: Brand.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        const Text(
          'Check with your family',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Brand.navy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Call them on the number saved here, not a number the caller gave '
          'you.',
          style: TextStyle(fontSize: 16, color: Color(0xFF3A4A63)),
        ),
        const SizedBox(height: 12),
        if (store.contacts.isEmpty)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'You have not added a family member yet.',
                  style: TextStyle(fontSize: 18, color: Brand.navy),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SetupScreen()),
                  ),
                  icon: const Icon(Icons.person_add_rounded),
                  label: const Text('Add family member'),
                ),
              ],
            ),
          ),
        for (final contact in store.contacts)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Avatar(name: contact.name),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Brand.navy,
                              ),
                            ),
                            if (contact.relation.isNotEmpty)
                              Text(
                                contact.relation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Brand.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _GradientAction(
                    key: ValueKey('call-${contact.id}'),
                    icon: Icons.call_rounded,
                    label: 'Call ${contact.name}',
                    onTap: () => AppScope.open(context, telUri(contact.phone)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    key: ValueKey('text-${contact.id}'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                    ),
                    onPressed: () =>
                        AppScope.open(context, _sms(store.userName, contact)),
                    icon: const Icon(Icons.sms_rounded),
                    label: const Text('Text: "Is this really you?"'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Uri _sms(String userName, FamilyContact contact) => smsUri(
    contact,
    buildVerifyMessage(
      senderName: userName,
      contact: contact,
      claimedToBe: claimedToBe,
      amount: amount,
      flags: flags,
    ),
  );
}

/// Round avatar with the person's initials on a gradient.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.name, this.size = 56});

  final String name;
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: Brand.calm,
    ),
    child: Text(
      _initials,
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.38,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _GradientAction extends StatelessWidget {
  const _GradientAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: softShadow(Brand.teal),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Brand.teal, Brand.mint]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
