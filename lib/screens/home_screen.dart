import 'package:material_ui/material_ui.dart';

import '../widgets/big_button.dart';
import 'already_paid_screen.dart';
import 'family_contacts_panel.dart';
import 'pause_flow_screen.dart';
import 'setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kinfirm'),
        actions: [
          IconButton(
            tooltip: 'Family & settings',
            icon: const Icon(Icons.settings_rounded, size: 32),
            onPressed: () => _push(context, const SetupScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Check before you pay.', style: text.headlineSmall),
            const SizedBox(height: 20),
            BigButton(
              key: const ValueKey('btn-asking'),
              label: 'Someone is asking me for money',
              subtitle: 'A call, text, email, or visit',
              icon: Icons.pan_tool_rounded,
              color: const Color(0xFFB3261E),
              foreground: Colors.white,
              onPressed: () => _push(context, const PauseFlowScreen()),
            ),
            const SizedBox(height: 16),
            BigButton(
              key: const ValueKey('btn-family'),
              label: 'Call or text my family',
              icon: Icons.family_restroom_rounded,
              onPressed: () => _push(
                context,
                Scaffold(
                  appBar: AppBar(title: const Text('My family')),
                  body: const SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: FamilyContactsPanel(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            BigButton(
              key: const ValueKey('btn-paid'),
              label: 'I already sent money',
              subtitle: 'What to do right now',
              icon: Icons.support_rounded,
              color: Theme.of(context).colorScheme.secondaryContainer,
              foreground: Theme.of(context).colorScheme.onSecondaryContainer,
              onPressed: () => _push(context, const AlreadyPaidScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
