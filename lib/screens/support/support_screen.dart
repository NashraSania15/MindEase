import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Support & Therapy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                'Choose the support that feels right for you',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // AI Therapist Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Talk to AI Therapist',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      '24/7 supportive conversations, guided exercises, '
                          'breathing techniques, and journaling prompts',
                      style: TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 14),

                    _bullet('🧘 Guided stress-relief exercises'),
                    _bullet('🫁 Breathing & meditation guidance'),
                    _bullet('📓 Reflective journaling support'),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Start Conversation',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Professional Help Section
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD9C7F3), Color(0xFFCBB7F0)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Professional Help',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _helpTile(
                      icon: Icons.phone,
                      title: 'National Crisis Helpline',
                      subtitle: 'Available 24/7 for emergencies',
                      trailingIcon: Icons.call,
                    ),

                    _helpTile(
                      icon: Icons.psychology,
                      title: 'Mental Health Counseling',
                      subtitle: 'Connect with licensed counselors',
                    ),

                    _helpTile(
                      icon: Icons.location_on,
                      title: 'Therapist Directory',
                      subtitle: 'Find therapists in your area',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Emergency Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE1E1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.sos, color: Colors.red),
                        SizedBox(width: 6),
                        Text(
                          'In Crisis? Get Immediate Help',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      '📞 988 – Suicide & Crisis Lifeline',
                      style: TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '📞 911 – Emergency Services',
                      style: TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '💚 This app provides support but is not a substitute for '
                      'professional medical advice, diagnosis, or treatment. '
                      'Always seek the advice of qualified health providers.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  static Widget _helpTile({
    required IconData icon,
    required String title,
    required String subtitle,
    IconData? trailingIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                    const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: Colors.green),
          if (trailingIcon == null)
            const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }
}
