import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindease/services/emergency_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final EmergencyService _service = EmergencyService();

  // Current stress level — can be updated externally via triggerEmergencyAlert().
  // ignore: prefer_final_fields
  double _stressLevel = 35.0;

  bool _alertSending = false;

  // ─── Manual SOS ───────────────────────────────────────────────────────────

  Future<void> _onSosTap() async {
    setState(() => _alertSending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.sendAlertToAll(_stressLevel);
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to send alert. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _alertSending = false);
    }
  }

  Future<void> _onSendAlert() async {
    setState(() => _alertSending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.sendAlertToAll(_stressLevel);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Alert sent to all contacts ✅')),
        );
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to send alert. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _alertSending = false);
    }
  }

  // ─── Add Contact Dialog ───────────────────────────────────────────────────

  Future<void> _showAddContactDialog() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    bool loading = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? errorMsg;
        return StatefulBuilder(
          builder: (ctx, setDS) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: const Text('Add Emergency Contact'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(nameCtrl, 'Full Name', Icons.person),
                    const SizedBox(height: 12),
                    _field(phoneCtrl, 'Phone Number', Icons.phone,
                        type: TextInputType.phone),
                    const SizedBox(height: 12),
                    _field(relationCtrl, 'Relation (optional)',
                        Icons.people),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 8),
                      Text(errorMsg!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();

                          if (name.isEmpty) {
                            setDS(() =>
                                errorMsg = 'Name cannot be empty.');
                            return;
                          }
                          if (!EmergencyService.isValidPhone(phone)) {
                            setDS(() =>
                                errorMsg = 'Enter a valid phone number.');
                            return;
                          }

                          setDS(() {
                            loading = true;
                            errorMsg = null;
                          });

                          try {
                            await _service.addContact(
                              name: name,
                              phone: phone,
                              relation: relationCtrl.text.trim(),
                            );
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                          } catch (_) {
                            if (!ctx.mounted) return;
                            setDS(() {
                              loading = false;
                              errorMsg =
                                  'Failed to save contact. Try again.';
                            });
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2))
                      : const Text('Save',
                          style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    phoneCtrl.dispose();
    relationCtrl.dispose();
  }

  // ─── Delete Contact ───────────────────────────────────────────────────────

  Future<void> _confirmDelete(
      BuildContext context, String contactId, String name) async {
    // Capture messenger before the async gap (showDialog await).
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text('Remove Contact'),
        content: Text('Remove $name from emergency contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteContact(contactId);
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('$name removed.')),
          );
        }
      } catch (_) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
                content: Text('Failed to remove contact. Try again.')),
          );
        }
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFEBEE), Color(0xFFFFF3E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Title — unchanged
                const Text(
                  'Emergency Support',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'You are not alone. Help is one tap away.',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // SOS Button — now functional
                GestureDetector(
                  onTap: _alertSending ? null : _onSosTap,
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _alertSending
                            ? [Colors.grey.shade400, Colors.grey.shade300]
                            : const [
                                Color(0xFFD32F2F),
                                Color(0xFFFF5252)
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _alertSending
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3)
                          : const Text(
                              'SOS',
                              style: TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Stress Alert Banner — unchanged
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'High stress detected. Consider reaching out to someone you trust.',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Contacts Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Add contact (+) button
                    GestureDetector(
                      onTap: _showAddContactDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, size: 16, color: Colors.red),
                            SizedBox(width: 4),
                            Text('Add',
                                style: TextStyle(
                                    color: Colors.red, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Real-time contacts list
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _service.contactsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Failed to load contacts.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_add,
                                  size: 40, color: Colors.grey),
                              const SizedBox(height: 8),
                              const Text(
                                'No emergency contacts yet.\nTap + Add to save one.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data();
                          final name =
                              (data['name'] ?? '').toString();
                          final phone =
                              (data['phone'] ?? '').toString();
                          final relation =
                              (data['relation'] ?? '').toString();

                          return _contactTile(
                            context: context,
                            contactId: doc.id,
                            name: name,
                            phone: phone,
                            relation: relation,
                          );
                        },
                      );
                    },
                  ),
                ),

                // Action Buttons — same appearance, now functional
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _service.contactsStream(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    final firstPhone = docs.isNotEmpty
                        ? (docs.first.data()['phone'] ?? '').toString()
                        : '';

                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: firstPhone.isEmpty
                                ? null
                                : () => _service.makeCall(firstPhone),
                            child: _actionButton(
                              icon: Icons.call,
                              text: 'Call Now',
                              color: firstPhone.isEmpty
                                  ? Colors.grey
                                  : Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _alertSending ? null : _onSendAlert,
                            child: _actionButton(
                              icon: Icons.message,
                              text: 'Send Alert',
                              color: _alertSending
                                  ? Colors.grey
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _contactTile({
    required BuildContext context,
    required String contactId,
    required String name,
    required String phone,
    required String relation,
  }) {
    return GestureDetector(
      onLongPress: () => _confirmDelete(context, contactId, name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    relation.isEmpty ? phone : '$phone · $relation',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _service.makeCall(phone),
              child: const Icon(Icons.call, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _actionButton({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
