import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindease/services/diary_service.dart';
import 'package:mindease/services/text_analysis_service.dart';
import 'diary_detail_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  int selectedMood = 0;
  int tabIndex = 0;

  final TextEditingController _textController = TextEditingController();
  final DiaryService _diaryService = DiaryService();

  bool _isSaving = false;

  // ── PIN State ─────────────────────────────────────────────────────────────
  bool _pinVerified = false;
  bool _isCheckingPin = false;
  final TextEditingController _pinController = TextEditingController();
  bool _isSettingPin = false;
  String _pinError = '';

  static const _moods = ['😊 Happy', '😐 Neutral', '😔 Sad', '😣 Stressed'];

  @override
  void dispose() {
    _textController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // ── Save Entry ─────────────────────────────────────────────────────────────

  Future<void> _saveEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before saving.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // ── AI stress analysis (best-effort; diary saves even if this fails) ──
      double? textStress;
      try {
        final result = await TextAnalysisService.analyzeText(text);
        textStress = result.stressLevel;
      } catch (_) {
        // Silently continue — stress field will be null for this entry.
      }

      await _diaryService.addEntry(
        text: text,
        mood: _moods[selectedMood],
        textStress: textStress,
      );

      _textController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diary entry saved ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Failed to save: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── PIN Handling ───────────────────────────────────────────────────────────

  Future<void> _onHistoryTabTapped() async {
    setState(() {
      tabIndex = 1;
      _isCheckingPin = true;
      _pinVerified = false;
      _pinError = '';
      _pinController.clear();
    });

    final hasPin = await _diaryService.hasPinSet();

    if (mounted) {
      setState(() {
        _isSettingPin = !hasPin;
        _isCheckingPin = false;
      });
    }
  }

  Future<void> _submitPin() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4 || int.tryParse(pin) == null) {
      setState(() => _pinError = 'Enter a 4-digit PIN.');
      return;
    }

    if (_isSettingPin) {
      try {
        await _diaryService.setPin(pin);
        if (mounted) setState(() => _pinVerified = true);
      } catch (_) {
        if (mounted) setState(() => _pinError = 'Failed to set PIN. Try again.');
      }
    } else {
      try {
        final ok = await _diaryService.verifyPin(pin);
        if (mounted) {
          if (ok) {
            setState(() => _pinVerified = true);
          } else {
            setState(() => _pinError = 'Incorrect PIN. Try again.');
            _pinController.clear();
          }
        }
      } catch (_) {
        if (mounted) setState(() => _pinError = 'Failed to verify PIN. Try again.');
      }
    }
  }

  // ── Change PIN (user knows old PIN) ─────────────────────────────────────

  Future<void> _showResetPinDialog() async {
    final oldPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    bool success = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? errorMsg;
        bool loading = false;

        return StatefulBuilder(
          builder: (ctx, setDS) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: const Text('Change Diary PIN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your current PIN, then set a new one.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _pinField(oldPinCtrl, 'Current PIN'),
                  const SizedBox(height: 12),
                  _pinField(newPinCtrl, 'New 4-digit PIN'),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(errorMsg!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 13)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      loading ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final oldPin = oldPinCtrl.text.trim();
                          final newPin = newPinCtrl.text.trim();

                          if (oldPin.length != 4 ||
                              int.tryParse(oldPin) == null) {
                            setDS(() => errorMsg =
                                'Current PIN must be 4 digits.');
                            return;
                          }
                          if (newPin.length != 4 ||
                              int.tryParse(newPin) == null) {
                            setDS(() =>
                                errorMsg = 'New PIN must be 4 digits.');
                            return;
                          }

                          setDS(() {
                            loading = true;
                            errorMsg = null;
                          });

                          try {
                            final ok = await _diaryService
                                .resetPin(oldPin, newPin);
                            if (!ctx.mounted) return;
                            if (ok) {
                              success = true;
                              Navigator.pop(ctx);
                            } else {
                              setDS(() {
                                loading = false;
                                errorMsg = 'Incorrect current PIN.';
                              });
                              oldPinCtrl.clear();
                            }
                          } catch (_) {
                            if (!ctx.mounted) return;
                            setDS(() {
                              loading = false;
                              errorMsg =
                                  'Something went wrong. Try again.';
                            });
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2))
                      : const Text('Change',
                          style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
      },
    );

    oldPinCtrl.dispose();
    newPinCtrl.dispose();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN changed successfully ✅')),
      );
    }
  }

  // ── Forgot PIN (re-authenticate with account password) ──────────────────

  Future<void> _showForgotPinDialog() async {
    final passwordCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    bool success = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? errorMsg;
        bool loading = false;

        return StatefulBuilder(
          builder: (ctx, setDS) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: const Text('Reset Diary PIN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Verify your account password to reset your diary PIN.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    enabled: !loading,
                    decoration: InputDecoration(
                      labelText: 'Account Password',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _pinField(newPinCtrl, 'New 4-digit PIN'),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(errorMsg!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 13)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      loading ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final password = passwordCtrl.text.trim();
                          final newPin = newPinCtrl.text.trim();

                          if (password.isEmpty) {
                            setDS(() => errorMsg =
                                'Enter your account password.');
                            return;
                          }
                          if (newPin.length != 4 ||
                              int.tryParse(newPin) == null) {
                            setDS(() =>
                                errorMsg = 'PIN must be 4 digits.');
                            return;
                          }

                          setDS(() {
                            loading = true;
                            errorMsg = null;
                          });

                          try {
                            await _diaryService.resetPinWithPassword(
                                password, newPin);
                            if (!ctx.mounted) return;
                            success = true;
                            Navigator.pop(ctx);
                          } catch (e) {
                            if (!ctx.mounted) return;
                            final msg = e.toString().toLowerCase();
                            final isWrongPassword =
                                msg.contains('wrong-password') ||
                                    msg.contains('invalid-credential') ||
                                    msg.contains('invalid_credential') ||
                                    msg.contains('user-not-found') ||
                                    msg.contains('password');
                            setDS(() {
                              loading = false;
                              errorMsg = isWrongPassword
                                  ? 'Incorrect password. Try again.'
                                  : 'Something went wrong. Try again.';
                            });
                            if (isWrongPassword) passwordCtrl.clear();
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2))
                      : const Text('Reset',
                          style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
      },
    );

    passwordCtrl.dispose();
    newPinCtrl.dispose();

    if (success && mounted) {
      setState(() => _pinVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diary PIN reset successfully ✅')),
      );
    }
  }

  // ── Helper: shared PIN field styling ──────────────────────────────────────

  Widget _pinField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      maxLength: 4,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F7FB), Color(0xFFEFF6F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.arrow_back_ios, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'My Private Diary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '🔒 Encrypted & Only You Can Access',
                      style: TextStyle(color: Colors.green, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          _toggleButton('Write Entry', 0),
                          _toggleButton('Diary History', 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Expanded(
                child:
                    tabIndex == 0 ? _buildWriteTab() : _buildHistoryTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── WRITE TAB ────────────────────────────────────

  Widget _buildWriteTab() {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(now);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('How are you feeling today?'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Mood selector
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _mood('😊', 'Happy', 0),
                _mood('😐', 'Neutral', 1),
                _mood('😔', 'Sad', 2),
                _mood('😣', 'Stressed', 3),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Diary text area
          Container(
            height: 190,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText:
                    'Write freely… no one is judging you.\n'
                    'This is your safe space to express your thoughts, '
                    'feelings, and experiences.',
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Save Entry button ─────────────────────────────────────────────
          GestureDetector(
            onTap: _isSaving ? null : _saveEntry,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: _isSaving
                      ? [Colors.grey.shade300, Colors.grey.shade300]
                      : [const Color(0xFF9BE7C4), const Color(0xFF7AD7C1)],
                ),
              ),
              child: Center(
                child: Text(
                  _isSaving ? 'Saving…' : 'Save Entry',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─────────────────────────── HISTORY TAB ──────────────────────────────────

  Widget _buildHistoryTab() {
    if (_isCheckingPin) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_pinVerified) {
      return _buildPinScreen();
    }

    return Column(
      children: [
        // Unlocked header with Change PIN
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _showResetPinDialog,
                icon: const Icon(Icons.lock_reset, size: 16),
                label: const Text('Change PIN',
                    style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF7AD7C1),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _diaryService.getEntries(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 40),
                      const SizedBox(height: 12),
                      const Text(
                        'Failed to load diary entries.\nPlease try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No diary entries yet.\nStart writing to see your history here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final entries = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final rawData = entries[index].data();
                  final data = rawData is Map<String, dynamic>
                      ? rawData
                      : <String, dynamic>{};
                  final text = data['text'] ?? '';
                  final mood = data['mood'] ?? '';
                  final createdAt = data['createdAt'] as Timestamp?;
                  final dateStr = createdAt != null
                      ? DateFormat('MMM d, yyyy – h:mm a')
                          .format(createdAt.toDate())
                      : '';
                  final textStress = data['textStress'] as num?;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DiaryDetailScreen(entry: data),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(dateStr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              const Spacer(),
                              if (textStress != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: textStress >= 70
                                        ? const Color(0x22F44336)
                                        : textStress >= 40
                                            ? const Color(0x22FF9800)
                                            : const Color(0x224CAF50),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Stress ${textStress.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: textStress >= 70
                                          ? const Color(0xFFF44336)
                                          : textStress >= 40
                                              ? const Color(0xFFFF9800)
                                              : const Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(mood,
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(text,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xFF555555))),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── PIN SCREEN ───────────────────────────────────

  Widget _buildPinScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            height: 72,
            width: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
              ),
            ),
            child: const Icon(Icons.lock, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 20),
          Text(
            _isSettingPin ? 'Set Your Diary PIN' : 'Enter Diary PIN',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSettingPin
                ? 'Create a 4-digit PIN to protect your diary'
                : 'Enter your 4-digit PIN to unlock',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              letterSpacing: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              hintText: '• • • •',
            ),
          ),
          if (_pinError.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(_pinError,
                style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _submitPin,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                ),
              ),
              child: Center(
                child: Text(
                  _isSettingPin ? 'Set PIN' : 'Unlock',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          // Forgot PIN – only when verifying
          if (!_isSettingPin) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showForgotPinDialog,
              child: const Text(
                'Forgot PIN?',
                style: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─────────────────────────── SHARED WIDGETS ───────────────────────────────

  Widget _toggleButton(String text, int index) {
    final isActive = tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 1) {
            _onHistoryTabTapped();
          } else {
            setState(() => tabIndex = 0);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF9BE7C4)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mood(String emoji, String label, int index) {
    final selected = selectedMood == index;
    return GestureDetector(
      onTap: () => setState(() => selectedMood = index),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: selected ? 28 : 24)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.grey,
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}
