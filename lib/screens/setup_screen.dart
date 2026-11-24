import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../data/app_store.dart';
import '../data/family_contact.dart';

/// Family contacts, safe word, name and text size.
class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.store(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Family & settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Trusted family', style: text.titleLarge),
            const SizedBox(height: 8),
            for (final c in store.contacts)
              Card(
                child: ListTile(
                  title: Text(c.name, style: text.titleMedium),
                  subtitle: Text(
                    [
                      c.relation,
                      c.phone,
                    ].where((s) => s.isNotEmpty).join(' · '),
                  ),
                  trailing: const Icon(Icons.edit_rounded),
                  onTap: () => editContact(context, existing: c),
                ),
              ),
            OutlinedButton.icon(
              key: const ValueKey('add-contact'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: () => editContact(context),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add family member'),
            ),
            const Divider(height: 40),
            Text('Family safe word', style: text.titleLarge),
            const SizedBox(height: 4),
            Text(
              'A secret word only your family knows. If someone calls asking '
              'for money, ask for the word. Never post it online.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 8),
            _SafeWordTile(store: store),
            const Divider(height: 40),
            Text('Your first name', style: text.titleLarge),
            const SizedBox(height: 4),
            Text('Used in the text you send to family.', style: text.bodyLarge),
            const SizedBox(height: 8),
            _NameField(store: store),
            const Divider(height: 40),
            Text('Text size', style: text.titleLarge),
            Slider(
              value: store.textScale,
              min: 1.0,
              max: 2.0,
              divisions: 4,
              label: '${(store.textScale * 100).round()}%',
              onChanged: store.setTextScale,
            ),
          ],
        ),
      ),
    );
  }
}

class _NameField extends StatefulWidget {
  const _NameField({required this.store});
  final AppStore store;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final _controller = TextEditingController(text: widget.store.userName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    textCapitalization: TextCapitalization.words,
    decoration: const InputDecoration(hintText: 'For example: Mary'),
    onChanged: widget.store.setUserName,
  );
}

class _SafeWordTile extends StatefulWidget {
  const _SafeWordTile({required this.store});
  final AppStore store;

  @override
  State<_SafeWordTile> createState() => _SafeWordTileState();
}

class _SafeWordTileState extends State<_SafeWordTile> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return Card(
      child: ListTile(
        title: Text(
          !store.hasSafeWord
              ? 'Not set yet'
              : _revealed
              ? store.safeWord!
              : '••••••  (tap the eye to show)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (store.hasSafeWord)
              IconButton(
                tooltip: _revealed ? 'Hide' : 'Show',
                icon: Icon(
                  _revealed
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
                onPressed: () => setState(() => _revealed = !_revealed),
              ),
            IconButton(
              key: const ValueKey('edit-safe-word'),
              tooltip: 'Change safe word',
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => editSafeWord(context, store),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> editSafeWord(BuildContext context, AppStore store) async {
  final controller = TextEditingController(text: store.safeWord ?? '');
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Family safe word'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pick something easy to remember but impossible to guess '
            'from social media, like an inside joke.',
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('safe-word-field'),
            controller: controller,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (result != null) await store.setSafeWord(result);
}

Future<void> editContact(BuildContext context, {FamilyContact? existing}) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ContactEditScreen(existing: existing)),
  );
}

class ContactEditScreen extends StatefulWidget {
  const ContactEditScreen({super.key, this.existing});
  final FamilyContact? existing;

  @override
  State<ContactEditScreen> createState() => _ContactEditScreenState();
}

class _ContactEditScreenState extends State<ContactEditScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _relation = TextEditingController(text: widget.existing?.relation);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _relation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final store = AppScope.store(context);
    final navigator = Navigator.of(context);
    await store.saveContact(
      FamilyContact(
        id: widget.existing?.id ?? AppStore.newId(),
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        relation: _relation.text.trim(),
      ),
    );
    navigator.pop();
  }

  Future<void> _delete() async {
    final store = AppScope.store(context);
    final navigator = Navigator.of(context);
    await store.removeContact(widget.existing!.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit family member' : 'Add family member'),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                key: const ValueKey('contact-name'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('contact-phone'),
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone number'),
                validator: (v) =>
                    FamilyContact(
                      id: '',
                      name: '',
                      phone: v ?? '',
                    ).hasValidPhone
                    ? null
                    : 'Please enter a full phone number',
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('contact-relation'),
                controller: _relation,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Relation (optional)',
                  hintText: 'For example: daughter, grandson',
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                key: const ValueKey('save-contact'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                ),
                onPressed: _save,
                child: const Text('Save', style: TextStyle(fontSize: 20)),
              ),
              if (editing) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Remove'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
