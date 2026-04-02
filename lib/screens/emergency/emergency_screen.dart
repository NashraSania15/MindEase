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
      await _service.sendAlertToAllWithWhatsApp(_stressLevel);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('SOS alert sent to all contacts ✅')),
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

  Future<void> _onSendAlert() async {
    setState(() => _alertSending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.sendAlertToAllWithWhatsApp(_stressLevel);
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

    final saved = await _showContactFormDialog(
      title: 'Add Emergency Contact',
      nameCtrl: nameCtrl,
      phoneCtrl: phoneCtrl,
      relationCtrl: relationCtrl,
      onSave: (name, phone, relation) async {
        await _service.addContact(
          name: name,
          phone: phone,
          relation: relation,
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      relationCtrl.dispose();
    });

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact added ✅')),
      );
    }
  }

  // ─── Edit Contact Dialog ──────────────────────────────────────────────────

  Future<void> _showEditContactDialog({
    required String contactId,
    required String currentName,
    required String currentPhone,
    required String currentRelation,
  }) async {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);
    final relationCtrl = TextEditingController(text: currentRelation);

    final saved = await _showContactFormDialog(
      title: 'Edit Contact',
      nameCtrl: nameCtrl,
      phoneCtrl: phoneCtrl,
      relationCtrl: relationCtrl,
      onSave: (name, phone, relation) async {
        await _service.updateContact(
          contactId: contactId,
          name: name,
          phone: phone,
          relation: relation,
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      relationCtrl.dispose();
    });

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact updated ✅')),
      );
    }
  }

  // ─── Reusable Contact Form Dialog ─────────────────────────────────────────

  Future<bool?> _showContactFormDialog({
    required String title,
    required TextEditingController nameCtrl,
    required TextEditingController phoneCtrl,
    required TextEditingController relationCtrl,
    required Future<void> Function(String name, String phone, String relation)
        onSave,
  }) async {
    bool loading = false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? errorMsg;
        return StatefulBuilder(
          builder: (ctx, setDS) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(nameCtrl, 'Full Name', Icons.person, isDark: isDark),
                    const SizedBox(height: 12),
                    _field(phoneCtrl, 'Phone Number', Icons.phone,
                        type: TextInputType.phone, isDark: isDark),
                    const SizedBox(height: 12),
                    _field(relationCtrl, 'Relation (optional)', Icons.people,
                        isDark: isDark),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 8),
                      Text(errorMsg!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading
                      ? null
                      : () {
                          if (ctx.mounted) Navigator.pop(ctx, false);
                        },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();

                          if (name.isEmpty) {
                            setDS(() => errorMsg = 'Name cannot be empty.');
                            return;
                          }
                          if (phone.isEmpty) {
                            setDS(() =>
                                errorMsg = 'Phone number cannot be empty.');
                            return;
                          }
                          if (!EmergencyService.isValidPhone(phone)) {
                            setDS(() => errorMsg =
                                'Enter a valid phone number (at least 7 digits).');
                            return;
                          }

                          setDS(() {
                            loading = true;
                            errorMsg = null;
                          });

                          try {
                            await onSave(
                              name,
                              phone,
                              relationCtrl.text.trim(),
                            );
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx, true);
                          } catch (e) {
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx, false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: \$e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save',
                          style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
      },
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    // Whether this screen was pushed onto the navigator (e.g. from Settings)
    // vs. used as a tab in the bottom-nav — determines if the back button shows.
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF0D0D1A), Color(0xFF1A1A2E)]
                : const [Color(0xFFFFEBEE), Color(0xFFFFF3E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back row — only shown when there is a route to pop
              if (canPop)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

              // Single scrollable content — title + SOS + contacts all in one scroll
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _service.contactsStream(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];

                    return CustomScrollView(
                      slivers: [
                        // ── Header / SOS / Alert Banner ──
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                            child: Column(
                              children: [
                                // Title
                                Text(
                                  'Emergency Support',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  'You are not alone. Help is one tap away.',
                                  style: TextStyle(color: subtextColor),
                                ),

                                const SizedBox(height: 30),

                                // SOS Button
                                GestureDetector(
                                  onTap: _alertSending ? null : _onSosTap,
                                  child: Container(
                                    height: 180,
                                    width: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: _alertSending
                                            ? [
                                                Colors.grey.shade400,
                                                Colors.grey.shade300
                                              ]
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

                                // Stress Alert Banner
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: isDark
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.red.withOpacity(0.08),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 26),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'High stress detected. Consider reaching out to someone you trust.',
                                          style: TextStyle(color: textColor, fontSize: 13),
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
                                    Text(
                                      'Emergency Contacts',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                    // Add contact (+) button
                                    GestureDetector(
                                      onTap: _showAddContactDialog,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: cardColor,
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
                              ],
                            ),
                          ),
                        ),

                        // ── Contacts List or Empty State ──
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (snapshot.hasError)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'Failed to load contacts.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else if (docs.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.person_add,
                                      size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text(
                                    'No emergency contacts yet.\nTap + Add to save one.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final doc = docs[index];
                                  final data = doc.data();
                                  final name = (data['name'] ?? '').toString();
                                  final phone = (data['phone'] ?? '').toString();
                                  final relation = (data['relation'] ?? '').toString();

                                  return _contactTile(
                                    context: context,
                                    contactId: doc.id,
                                    name: name,
                                    phone: phone,
                                    relation: relation,
                                  );
                                },
                                childCount: docs.length,
                              ),
                            ),
                          ),

                        // Bottom padding so content doesn't hide behind buttons
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 16),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Action Buttons — fixed at bottom
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
              ),
            ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          Icon(Icons.person,
              color: isDark ? Colors.white70 : Colors.black87),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  relation.isEmpty ? phone : '$phone · $relation',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Edit button
          GestureDetector(
            onTap: () => _showEditContactDialog(
              contactId: contactId,
              currentName: name,
              currentPhone: phone,
              currentRelation: relation,
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.edit,
                  size: 20,
                  color: isDark ? Colors.grey.shade400 : Colors.grey),
            ),
          ),
          // Delete button
          GestureDetector(
            onTap: () => _confirmDelete(context, contactId, name),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.delete_outline,
                  size: 20,
                  color: Colors.red.shade400),
            ),
          ),
          // Call button
          GestureDetector(
            onTap: () => _service.makeCall(phone),
            child: const Icon(Icons.call, color: Colors.green),
          ),
        ],
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
    bool isDark = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFF5F5F5),
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
