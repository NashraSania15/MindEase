// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class SupportScreen extends StatelessWidget {
//   const SupportScreen({super.key});

//   Future<void> _makeCall(String number) async {
//     final uri = Uri(scheme: 'tel', path: number);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEFF6F5),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: isDark
//                 ? const [Color(0xFF0D0D1A), Color(0xFF1A1A2E)]
//                 : const [Color(0xFFF7F7FB), Color(0xFFEFF6F5)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.arrow_back, color: textColor),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Text(
//                       'Support & Therapy',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         color: textColor,
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 6),

//                 Padding(
//                   padding: EdgeInsets.only(left: 8),
//                   child: Text(
//                     'Choose the support that feels right for you',
//                     style: TextStyle(color: subtextColor),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // ── AI Therapist Card ──
//                 Container(
//                   padding: const EdgeInsets.all(18),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
//                     ),
//                     borderRadius: BorderRadius.circular(22),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.chat_bubble_outline,
//                               color: Colors.white),
//                           SizedBox(width: 8),
//                           Text(
//                             'Talk to AI Therapist',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 10),

//                       const Text(
//                         '24/7 supportive conversations, guided exercises, '
//                         'breathing techniques, and journaling prompts',
//                         style: TextStyle(color: Colors.white),
//                       ),

//                       const SizedBox(height: 14),

//                       _bullet('🧘 Guided stress-relief exercises'),
//                       _bullet('🫁 Breathing & meditation guidance'),
//                       _bullet('📓 Reflective journaling support'),

//                       const SizedBox(height: 14),

//                       // Coming soon label
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.schedule,
//                                 size: 16, color: Colors.white),
//                             SizedBox(width: 6),
//                             Text(
//                               'Coming Soon',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // ── Professional Help Section ──
//                 Container(
//                   padding: const EdgeInsets.all(18),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFD9C7F3), Color(0xFFCBB7F0)],
//                     ),
//                     borderRadius: BorderRadius.circular(22),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Professional Help',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       const Text(
//                         'Indian Mental Health Helplines',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 12,
//                         ),
//                       ),

//                       const SizedBox(height: 14),

//                       _helpTileWithCall(
//                         context: context,
//                         icon: Icons.phone,
//                         title: 'iCall – TISS',
//                         subtitle: 'Mon–Sat, 8AM–10PM',
//                         number: '9152987821',
//                       ),

//                       _helpTileWithCall(
//                         context: context,
//                         icon: Icons.phone,
//                         title: 'Vandrevala Foundation',
//                         subtitle: '24/7 Helpline (Multilingual)',
//                         number: '18602662345',
//                       ),

//                       _helpTileWithCall(
//                         context: context,
//                         icon: Icons.phone,
//                         title: 'NIMHANS',
//                         subtitle: 'Mon–Sat, 9:30AM–5PM',
//                         number: '08046110007',
//                       ),

//                       _helpTileWithCall(
//                         context: context,
//                         icon: Icons.phone,
//                         title: 'Snehi',
//                         subtitle: '24/7 Emotional Support',
//                         number: '04424640050',
//                       ),

//                       // Find Therapist — Coming Soon
//                       Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: cardColor,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.location_on,
//                                 color: Colors.purple),
//                             const SizedBox(width: 10),
//                             const Expanded(
//                               child: Column(
//                                 crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Find Therapist Near You',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w600)),
//                                   Text(
//                                     'Locate licensed therapists nearby',
//                                     style: TextStyle(
//                                         color: Colors.grey, fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.purple.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Text(
//                                 'Soon',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.purple,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // ── SOS Crisis Card ──
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: isDark ? const Color(0xFF2C1A1A) : const Color(0xFFFFE1E1),
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.sos, color: Colors.red),
//                           SizedBox(width: 6),
//                           Text(
//                             'In Crisis? Get Immediate Help',
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),

//                       _crisisLine(
//                         label: 'Vandrevala Foundation (24/7)',
//                         number: '1860-2662-345',
//                         onTap: () => _makeCall('18602662345'),
//                       ),
//                       const SizedBox(height: 8),
//                       _crisisLine(
//                         label: 'iCall – TISS Helpline',
//                         number: '9152987821',
//                         onTap: () => _makeCall('9152987821'),
//                       ),
//                       const SizedBox(height: 8),
//                       _crisisLine(
//                         label: 'KIRAN Mental Health',
//                         number: '1800-599-0019',
//                         onTap: () => _makeCall('18005990019'),
//                       ),
//                       const SizedBox(height: 8),
//                       _crisisLine(
//                         label: 'Police Emergency',
//                         number: '112',
//                         onTap: () => _makeCall('112'),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Disclaimer
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: cardColor,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: isDark
//                         ? []
//                         : [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.04),
//                               blurRadius: 8,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                   ),
//                   child: Text(
//                     '💚 This app provides support but is not a substitute for '
//                     'professional medical advice, diagnosis, or treatment. '
//                     'Always seek the advice of qualified health providers.',
//                     style: TextStyle(fontSize: 12, color: textColor),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Helpers ──

//   static Widget _bullet(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(
//         text,
//         style: const TextStyle(color: Colors.white),
//       ),
//     );
//   }

//   Widget _helpTileWithCall({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required String number,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

//     return GestureDetector(
//       onTap: () => _makeCall(number),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: cardColor,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: isDark
//               ? []
//               : [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: Colors.purple),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
//                   Text(subtitle,
//                       style: TextStyle(
//                           color: subtextColor, fontSize: 12)),
//                   const SizedBox(height: 2),
//                   Text(
//                     number,
//                     style: const TextStyle(
//                       color: Color(0xFF4CAF50),
//                       fontWeight: FontWeight.w600,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               height: 36,
//               width: 36,
//               decoration: BoxDecoration(
//                 color: isDark ? const Color(0xFF1A2E2A) : const Color(0xFFEAFBF6),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.call,
//                   color: Color(0xFF4CAF50), size: 18),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   static Widget _crisisLine({
//     required String label,
//     required String number,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Row(
//         children: [
//           const Text('📞 ', style: TextStyle(fontSize: 14)),
//           Expanded(
//             child: Text(
//               '$label — $number',
//               style: const TextStyle(
//                 color: Colors.red,
//                 decoration: TextDecoration.underline,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//           const Icon(Icons.call, size: 16, color: Colors.red),
//         ],
//       ),
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class SupportScreen extends StatelessWidget {
//   const SupportScreen({super.key});

//   Future<void> _makeCall(String number) async {
//     final uri = Uri(scheme: 'tel', path: number);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEFF6F5),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: isDark
//                 ? const [Color(0xFF0D0D1A), Color(0xFF1A1A2E)]
//                 : const [Color(0xFFF7F7FB), Color(0xFFEFF6F5)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.arrow_back, color: textColor),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Text(
//                       'Support & Therapy',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         color: textColor,
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 6),

//                 Padding(
//                   padding: EdgeInsets.only(left: 8),
//                   child: Text(
//                     'Choose the support that feels right for you',
//                     style: TextStyle(color: subtextColor),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // ── AI Therapist Card ──
//                 Container(
//                   padding: const EdgeInsets.all(18),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
//                     ),
//                     borderRadius: BorderRadius.circular(22),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.chat_bubble_outline,
//                               color: Colors.white),
//                           SizedBox(width: 8),
//                           Text(
//                             'Talk to AI Therapist',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 10),

//                       const Text(
//                         '24/7 supportive conversations, guided exercises, '
//                         'breathing techniques, and journaling prompts',
//                         style: TextStyle(color: Colors.white),
//                       ),

//                       const SizedBox(height: 14),

//                       _bullet('🧘 Guided stress-relief exercises'),
//                       _bullet('🫁 Breathing & meditation guidance'),
//                       _bullet('📓 Reflective journaling support'),

//                       const SizedBox(height: 14),

//                       // Coming soon label
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.schedule,
//                                 size: 16, color: Colors.white),
//                             SizedBox(width: 6),
//                             Text(
//                               'Coming Soon',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // ── Professional Help Section ──
//                 Container(
//                   padding: const EdgeInsets.all(18),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFD9C7F3), Color(0xFFCBB7F0)],
//                     ),
//                     borderRadius: BorderRadius.circular(22),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Professional Help',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       const Text(
//                         'Indian Mental Health Helplines',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 12,
//                         ),
//                       ),

//                       const SizedBox(height: 14),

//                       _helpTileWithCall(
//                         context: context,
//                         icon: Icons.phone,
//                         title: 'iCall – TISS',
//                         subtitle: 'Mon–Sat, 8AM–10PM',
//                         number: '9152987821',
//                       ),

//                       _helpTileWithCall(
//                         context: context,
//                         icon: Icons.phone,
//                         title: 'Vandrevala Foundation',
//                         subtitle: '24/7 Helpline (Multilingual)',
//                         number: '18602662345',
//                       ),

//                       _helpTileWithCall(
//                         context: context,
//                         icon: Icons.phone,
//                         title: 'NIMHANS',
//                         subtitle: 'Mon–Sat, 9:30AM–5PM',
//                         number: '08046110007',
//                       ),

//                       _helpTileWithCall(
//                         context: context,
//                         icon: Icons.phone,
//                         title: 'Snehi',
//                         subtitle: '24/7 Emotional Support',
//                         number: '04424640050',
//                       ),

//                       // Find Therapist — Coming Soon
//                       Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: cardColor,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.location_on,
//                                 color: Colors.purple),
//                             const SizedBox(width: 10),
//                             const Expanded(
//                               child: Column(
//                                 crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Find Therapist Near You',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w600)),
//                                   Text(
//                                     'Locate licensed therapists nearby',
//                                     style: TextStyle(
//                                         color: Colors.grey, fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.purple.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Text(
//                                 'Soon',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.purple,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // ── SOS Crisis Card ──
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: isDark ? const Color(0xFF2C1A1A) : const Color(0xFFFFE1E1),
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.sos, color: Colors.red),
//                           SizedBox(width: 6),
//                           Text(
//                             'In Crisis? Get Immediate Help',
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),

//                       _crisisLine(
//                         label: 'Vandrevala Foundation (24/7)',
//                         number: '1860-2662-345',
//                         onTap: () => _makeCall('18602662345'),
//                       ),
//                       const SizedBox(height: 8),
//                       _crisisLine(
//                         label: 'iCall – TISS Helpline',
//                         number: '9152987821',
//                         onTap: () => _makeCall('9152987821'),
//                       ),
//                       const SizedBox(height: 8),
//                       _crisisLine(
//                         label: 'KIRAN Mental Health',
//                         number: '1800-599-0019',
//                         onTap: () => _makeCall('18005990019'),
//                       ),
//                       const SizedBox(height: 8),
//                       _crisisLine(
//                         label: 'Police Emergency',
//                         number: '112',
//                         onTap: () => _makeCall('112'),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Disclaimer
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: cardColor,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: isDark
//                         ? []
//                         : [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.04),
//                               blurRadius: 8,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                   ),
//                   child: Text(
//                     '💚 This app provides support but is not a substitute for '
//                     'professional medical advice, diagnosis, or treatment. '
//                     'Always seek the advice of qualified health providers.',
//                     style: TextStyle(fontSize: 12, color: textColor),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Helpers ──

//   static Widget _bullet(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(
//         text,
//         style: const TextStyle(color: Colors.white),
//       ),
//     );
//   }

//   Widget _helpTileWithCall({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required String number,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

//     return GestureDetector(
//       onTap: () => _makeCall(number),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: cardColor,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: isDark
//               ? []
//               : [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: Colors.purple),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
//                   Text(subtitle,
//                       style: TextStyle(
//                           color: subtextColor, fontSize: 12)),
//                   const SizedBox(height: 2),
//                   Text(
//                     number,
//                     style: const TextStyle(
//                       color: Color(0xFF4CAF50),
//                       fontWeight: FontWeight.w600,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               height: 36,
//               width: 36,
//               decoration: BoxDecoration(
//                 color: isDark ? const Color(0xFF1A2E2A) : const Color(0xFFEAFBF6),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.call,
//                   color: Color(0xFF4CAF50), size: 18),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   static Widget _crisisLine({
//     required String label,
//     required String number,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Row(
//         children: [
//           const Text('📞 ', style: TextStyle(fontSize: 14)),
//           Expanded(
//             child: Text(
//               '$label — $number',
//               style: const TextStyle(
//                 color: Colors.red,
//                 decoration: TextDecoration.underline,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//           const Icon(Icons.call, size: 16, color: Colors.red),
//         ],
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'nearby_therapist_page.dart';

// class SupportScreen extends StatelessWidget {
//   const SupportScreen({super.key});

//   Future<void> _makeCall(String number) async {
//     final uri = Uri(scheme: 'tel', path: number);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEFF6F5),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: isDark
//                 ? const [Color(0xFF0D0D1A), Color(0xFF1A1A2E)]
//                 : const [Color(0xFFF7F7FB), Color(0xFFEFF6F5)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [

//                 // HEADER
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.arrow_back, color: textColor),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Text(
//                       'Support & Therapy',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         color: textColor,
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 6),

//                 Padding(
//                   padding: const EdgeInsets.only(left: 8),
//                   child: Text(
//                     'Choose the support that feels right for you',
//                     style: TextStyle(color: subtextColor),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // ✅ NEW NEARBY THERAPIST CARD
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const NearbyTherapistPage(),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(18),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
//                       ),
//                       borderRadius: BorderRadius.circular(22),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Row(
//                           children: [
//                             Icon(Icons.location_on, color: Colors.white),
//                             SizedBox(width: 8),
//                             Text(
//                               'Nearby Therapist',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 10),

//                         const Text(
//                           'Find therapists and mental health clinics near your location',
//                           style: TextStyle(color: Colors.white),
//                         ),

//                         const SizedBox(height: 14),

//                         _bullet('📍 Search by location or PIN code'),
//                         _bullet('⭐ Filter by rating and availability'),
//                         _bullet('📞 Call or view on map instantly'),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // PROFESSIONAL HELP
//                 Container(
//                   padding: const EdgeInsets.all(18),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFD9C7F3), Color(0xFFCBB7F0)],
//                     ),
//                     borderRadius: BorderRadius.circular(22),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Professional Help',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),

//                       const SizedBox(height: 6),

//                       const Text(
//                         'Indian Mental Health Helplines',
//                         style: TextStyle(color: Colors.white70, fontSize: 12),
//                       ),

//                       const SizedBox(height: 14),

//                       _helpTileWithCall(
//                         context: context,
//                         title: 'iCall – TISS',
//                         subtitle: 'Mon–Sat, 8AM–10PM',
//                         number: '9152987821',
//                       ),

//                       _helpTileWithCall(
//                         context: context,
//                         title: 'Vandrevala Foundation',
//                         subtitle: '24/7 Helpline',
//                         number: '18602662345',
//                       ),

//                       _helpTileWithCall(
//                         context: context,
//                         title: 'NIMHANS',
//                         subtitle: 'Mon–Sat, 9:30AM–5PM',
//                         number: '08046110007',
//                       ),

//                       _helpTileWithCall(
//                         context: context,
//                         title: 'Snehi',
//                         subtitle: '24/7 Emotional Support',
//                         number: '04424640050',
//                       ),
//                     ],
//                   ),
//                 ),


//                 const SizedBox(height: 20),

//               const SizedBox(height: 20),

// // ── SOS Crisis Card ──
// Container(
//   padding: const EdgeInsets.all(16),
//   decoration: BoxDecoration(
//     color: isDark ? const Color(0xFF2C1A1A) : const Color(0xFFFFE1E1),
//     borderRadius: BorderRadius.circular(18),
//   ),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Row(
//         children: [
//           Icon(Icons.sos, color: Colors.red),
//           SizedBox(width: 6),
//           Text(
//             'In Crisis? Get Immediate Help',
//             style: TextStyle(
//               color: Colors.red,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 12),

//       _crisisLine(
//         label: 'Vandrevala Foundation (24/7)',
//         number: '1860-2662-345',
//         onTap: () => _makeCall('18602662345'),
//       ),
//       const SizedBox(height: 8),

//       _crisisLine(
//         label: 'iCall – TISS Helpline',
//         number: '9152987821',
//         onTap: () => _makeCall('9152987821'),
//       ),
//       const SizedBox(height: 8),

//       _crisisLine(
//         label: 'KIRAN Mental Health',
//         number: '1800-599-0019',
//         onTap: () => _makeCall('18005990019'),
//       ),
//       const SizedBox(height: 8),

//       _crisisLine(
//         label: 'Police Emergency',
//         number: '112',
//         onTap: () => _makeCall('112'),
//       ),
//     ],
//   ),
// ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   static Widget _bullet(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(text, style: const TextStyle(color: Colors.white)),
//     );
//   }

//   Widget _helpTileWithCall({
//     required BuildContext context,
//     required String title,
//     required String subtitle,
//     required String number,
//   }) {
//     return GestureDetector(
//       onTap: () => _makeCall(number),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.phone, color: Colors.purple),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//                   Text(subtitle, style: const TextStyle(fontSize: 12)),
//                   Text(number, style: const TextStyle(color: Colors.green)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   static Widget _crisisLine({
//     required String label,
//     required String number,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Text(
//         '$label — $number',
//         style: const TextStyle(color: Colors.red),
//       ),
//     );
//   }
// }
























import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'nearby_therapist_page.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _makeCall(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEFF6F5),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF0D0D1A), Color(0xFF1A1A2E)]
                : const [Color(0xFFF7F7FB), Color(0xFFEFF6F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // HEADER
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Support & Therapy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Choose the support that feels right for you',
                    style: TextStyle(color: subtextColor),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 NEARBY THERAPIST BUTTON (UPDATED DESIGN)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NearbyTherapistPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.location_on,
                                  color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Nearby Therapist',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 16),
                            ],
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Find therapists and mental health clinics near your location',
                            style: TextStyle(color: Colors.white),
                          ),

                          const SizedBox(height: 14),

                          _bullet('📍 Search by location or PIN code'),
                          _bullet('⭐ Filter by rating and availability'),
                          _bullet('📞 Call or view on map instantly'),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // PROFESSIONAL HELP
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
                      const SizedBox(height: 6),
                      const Text(
                        'Indian Mental Health Helplines',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 14),

                      _helpTile(context, 'iCall – TISS',
                          'Mon–Sat, 8AM–10PM', '9152987821'),
                      _helpTile(context, 'Vandrevala Foundation',
                          '24/7 Helpline', '18602662345'),
                      _helpTile(context, 'NIMHANS',
                          'Mon–Sat, 9:30AM–5PM', '08046110007'),
                      _helpTile(context, 'Snehi',
                          '24/7 Emotional Support', '04424640050'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔴 SOS SECTION (FULL)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C1A1A)
                        : const Color(0xFFFFE1E1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
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
                      const SizedBox(height: 12),

                      _crisisLine('Vandrevala (24/7)',
                          '1860-2662-345', () => _makeCall('18602662345')),
                      _crisisLine('iCall – TISS',
                          '9152987821', () => _makeCall('9152987821')),
                      _crisisLine('KIRAN Mental Health',
                          '1800-599-0019', () => _makeCall('18005990019')),
                      _crisisLine('Emergency', '112',
                          () => _makeCall('112')),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 💚 DISCLAIMER
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '💚 This app provides support but is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of qualified health providers.',
                    style: TextStyle(
                        fontSize: 12, color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _helpTile(
      BuildContext context, String title, String subtitle, String number) {
    return GestureDetector(
      onTap: () => _makeCall(number),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.phone, color: Colors.purple),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12)),
                  Text(number,
                      style:
                          const TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _crisisLine(
      String label, String number, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          '$label — $number',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}