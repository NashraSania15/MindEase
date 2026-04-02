import 'package:flutter/material.dart';
import 'wellness_detail_screen.dart';
import 'breathing_meditation_screen.dart';

/// Data model for a wellness issue/category.
class WellnessCategory {
  final String emoji;
  final String title;
  final String description;
  final Color accentColor;
  final String tag; // 'calm', 'anxiety', 'panic', or 'general'
  final List<WellnessTip> exercises;
  final List<WellnessTip> tips;
  final List<WellnessTip> suggestions;

  const WellnessCategory({
    required this.emoji,
    required this.title,
    required this.description,
    required this.accentColor,
    this.tag = 'general',
    required this.exercises,
    required this.tips,
    required this.suggestions,
  });
}

/// A single tip / exercise / suggestion.
class WellnessTip {
  final String icon;
  final String title;
  final String detail;

  const WellnessTip({
    required this.icon,
    required this.title,
    required this.detail,
  });
}

// ─── Hardcoded wellness data ───

final List<WellnessCategory> wellnessCategories = [
  // ───────── Calmness ─────────
  WellnessCategory(
    emoji: '🌊',
    title: 'Calmness',
    description: 'Find your inner peace',
    accentColor: const Color(0xFF9BE7C4),
    tag: 'calm',
    exercises: const [
      WellnessTip(icon: '🌬️', title: 'Deep Breathing', detail: 'Inhale slowly for 4 seconds, hold for 4, exhale for 6. Repeat 5–10 times to activate your body\'s relaxation response.'),
      WellnessTip(icon: '🧘', title: 'Body Scan Meditation', detail: 'Lie down comfortably. Starting from your toes, slowly bring attention to each body part, releasing tension as you go. Spend 10–15 minutes.'),
      WellnessTip(icon: '🎵', title: 'Listen to Calm Music', detail: 'Play soft instrumental or nature sounds. Let the rhythm slow your heartbeat and ease your mind for at least 10 minutes.'),
    ],
    tips: const [
      WellnessTip(icon: '🕯️', title: 'Create a Calm Space', detail: 'Dim the lights, light a candle, and remove distractions. A peaceful environment helps your mind settle quickly.'),
      WellnessTip(icon: '📵', title: 'Digital Detox', detail: 'Put your phone on silent and step away from screens for 20–30 minutes. Let your brain rest from constant stimulation.'),
      WellnessTip(icon: '🍵', title: 'Drink Herbal Tea', detail: 'Chamomile or lavender tea can naturally calm your nervous system. Sip slowly and focus on the warmth.'),
    ],
    suggestions: const [
      WellnessTip(icon: '📖', title: 'Read Something Light', detail: 'Pick up a feel-good book or magazine. Reading shifts your focus and helps break the cycle of racing thoughts.'),
      WellnessTip(icon: '🌿', title: 'Spend Time in Nature', detail: 'Even a 10-minute walk in a park or garden can reduce cortisol levels and bring a sense of calm.'),
    ],
  ),

  // ───────── Stress Relief ─────────
  WellnessCategory(
    emoji: '🍃',
    title: 'Stress Relief',
    description: 'Let go of tension',
    accentColor: const Color(0xFF81D4A2),
    tag: 'calm',
    exercises: const [
      WellnessTip(icon: '💪', title: 'Progressive Muscle Relaxation', detail: 'Tense each muscle group for 5 seconds, then release. Start from your feet and work up to your face. This contrast helps your body truly relax.'),
      WellnessTip(icon: '🏃', title: '10-Minute Walk', detail: 'Get outside and walk briskly. Movement releases endorphins — your body\'s natural stress fighters.'),
      WellnessTip(icon: '🤸', title: 'Neck & Shoulder Stretches', detail: 'Roll your shoulders backward 10 times, then gently tilt your head to each side. Hold for 15 seconds per side.'),
    ],
    tips: const [
      WellnessTip(icon: '📝', title: 'Write It Down', detail: 'Journaling your worries transfers them from your mind to paper. Spend 5 minutes writing whatever comes to your mind without judgment.'),
      WellnessTip(icon: '🤝', title: 'Talk to Someone', detail: 'Sharing your stress with a trusted friend, family member, or counselor can lighten the emotional load significantly.'),
      WellnessTip(icon: '⏰', title: 'Take Regular Breaks', detail: 'Every 45–60 minutes, stand up, stretch, and look away from your screen. Short breaks prevent stress from building up.'),
    ],
    suggestions: const [
      WellnessTip(icon: '🎨', title: 'Do Something Creative', detail: 'Draw, paint, cook, or craft. Creative activities engage a different part of your brain and reduce stress hormones.'),
      WellnessTip(icon: '😂', title: 'Watch Something Funny', detail: 'Laughter triggers the release of endorphins. Watch a funny video or comedy show to shift your mood.'),
    ],
  ),

  // ───────── Anxiety ─────────
  WellnessCategory(
    emoji: '🦋',
    title: 'Anxiety',
    description: 'Ease your anxious mind',
    accentColor: const Color(0xFFA8D8EA),
    tag: 'anxiety',
    exercises: const [
      WellnessTip(icon: '✋', title: '5-4-3-2-1 Grounding', detail: 'Notice 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste. This brings you back to the present moment.'),
      WellnessTip(icon: '🫧', title: 'Box Breathing', detail: 'Inhale for 4 seconds, hold 4, exhale 4, hold 4. Repeat 4 times. This technique is used by Navy SEALs to stay calm under pressure.'),
      WellnessTip(icon: '🏠', title: 'Safe Space Visualization', detail: 'Close your eyes and imagine a place where you feel completely safe. Notice every detail — colors, sounds, temperature. Stay there for 5 minutes.'),
    ],
    tips: const [
      WellnessTip(icon: '☕', title: 'Reduce Caffeine', detail: 'Caffeine can worsen anxiety symptoms. Try switching to decaf or herbal tea, especially after noon.'),
      WellnessTip(icon: '🛏️', title: 'Establish a Routine', detail: 'Predictable daily routines reduce uncertainty, which is one of the biggest anxiety triggers.'),
      WellnessTip(icon: '💭', title: 'Challenge Negative Thoughts', detail: 'Ask yourself: "Is this thought based on facts or fear?" Often, anxiety exaggerates the worst-case scenario.'),
    ],
    suggestions: const [
      WellnessTip(icon: '🐾', title: 'Spend Time with Animals', detail: 'Petting a cat or dog reduces cortisol and boosts oxytocin. Even watching animal videos can help!'),
      WellnessTip(icon: '🧩', title: 'Do a Puzzle or Game', detail: 'Engaging in a puzzle redirects anxious energy into something productive and calming.'),
    ],
  ),

  // ───────── Focus ─────────
  WellnessCategory(
    emoji: '🎯',
    title: 'Focus',
    description: 'Sharpen your concentration',
    accentColor: const Color(0xFFFFD59E),
    tag: 'general',
    exercises: const [
      WellnessTip(icon: '🍅', title: 'Pomodoro Technique', detail: 'Work for 25 minutes with full focus, then take a 5-minute break. After 4 cycles, take a longer 15–20 minute break.'),
      WellnessTip(icon: '👁️', title: 'Candle Gazing (Trataka)', detail: 'Stare at a candle flame for 2–3 minutes without blinking. This ancient technique strengthens mental focus and eye muscles.'),
      WellnessTip(icon: '🔢', title: 'Counting Meditation', detail: 'Count your breaths from 1 to 10, then restart. If you lose count, begin again. Simple but powerful for building concentration.'),
    ],
    tips: const [
      WellnessTip(icon: '📋', title: 'Prioritize One Task', detail: 'Multitasking reduces productivity by 40%. Pick one task, work on it completely, then move to the next.'),
      WellnessTip(icon: '🔕', title: 'Silence Notifications', detail: 'Turn off non-essential notifications. Each interruption takes an average of 23 minutes to fully recover from.'),
      WellnessTip(icon: '💧', title: 'Stay Hydrated', detail: 'Even mild dehydration can impair focus and cognitive function. Keep a water bottle nearby and sip regularly.'),
    ],
    suggestions: const [
      WellnessTip(icon: '🎧', title: 'Use Focus Music', detail: 'Instrumental lo-fi, classical, or binaural beats can create a focused atmosphere without distracting lyrics.'),
      WellnessTip(icon: '🗂️', title: 'Declutter Your Workspace', detail: 'A clean, organized space reduces visual distractions and helps your brain focus on the task at hand.'),
    ],
  ),

  // ───────── Sleep ─────────
  WellnessCategory(
    emoji: '🌙',
    title: 'Sleep',
    description: 'Drift into restful sleep',
    accentColor: const Color(0xFFB8B5E0),
    tag: 'calm',
    exercises: const [
      WellnessTip(icon: '🌬️', title: '4-7-8 Breathing', detail: 'Inhale for 4 seconds, hold for 7, exhale slowly for 8. This activates the parasympathetic nervous system and signals your body to sleep.'),
      WellnessTip(icon: '🦶', title: 'Toe Tensing Exercise', detail: 'While lying in bed, curl your toes tightly for 5 seconds, then release. Repeat 10 times. This draws tension away from your mind.'),
      WellnessTip(icon: '🧘', title: 'Yoga Nidra', detail: 'Practice "yogic sleep" — a guided relaxation where you lie still and follow body-awareness instructions. 20 minutes equals 2 hours of sleep.'),
    ],
    tips: const [
      WellnessTip(icon: '📱', title: 'No Screens Before Bed', detail: 'Blue light from screens suppresses melatonin. Stop using phones/laptops at least 30 minutes before bedtime.'),
      WellnessTip(icon: '🌡️', title: 'Keep Your Room Cool', detail: 'The ideal sleep temperature is 18–20°C (65–68°F). A cool room helps your body lower its core temperature for better sleep.'),
      WellnessTip(icon: '⏰', title: 'Consistent Sleep Schedule', detail: 'Go to bed and wake up at the same time every day — even on weekends. This sets your internal clock for better sleep quality.'),
    ],
    suggestions: const [
      WellnessTip(icon: '🥛', title: 'Warm Milk or Herbal Tea', detail: 'A warm drink before bed can be a soothing sleep ritual. Avoid caffeine — try chamomile, valerian, or warm milk with honey.'),
      WellnessTip(icon: '📓', title: 'Gratitude Journaling', detail: 'Write 3 things you\'re grateful for before bed. This shifts your mind from worries to positive thoughts, making sleep easier.'),
    ],
  ),

  // ───────── Headache Relief ─────────
  WellnessCategory(
    emoji: '💆',
    title: 'Headache Relief',
    description: 'Soothe head tension',
    accentColor: const Color(0xFFF5C6C6),
    tag: 'general',
    exercises: const [
      WellnessTip(icon: '👐', title: 'Temple Massage', detail: 'Place your fingertips on your temples and gently massage in small circles for 2–3 minutes. Apply light to medium pressure.'),
      WellnessTip(icon: '🧊', title: 'Cold Compress', detail: 'Apply a cold cloth or ice pack wrapped in a towel to your forehead for 15 minutes. Cold constricts blood vessels and numbs the pain.'),
      WellnessTip(icon: '👀', title: 'Eye Relaxation', detail: 'Close your eyes and gently place your palms over them (palming). Sit in darkness for 2 minutes. This relieves eye strain headaches.'),
    ],
    tips: const [
      WellnessTip(icon: '💧', title: 'Drink Water', detail: 'Dehydration is one of the most common headache triggers. Drink a full glass of water slowly and see if it helps within 20 minutes.'),
      WellnessTip(icon: '💡', title: 'Dim the Lights', detail: 'Bright or fluorescent lights can worsen headaches. Lower the brightness or move to a dimly lit room.'),
      WellnessTip(icon: '🧣', title: 'Loosen Tight Accessories', detail: 'Tight ponytails, headbands, or hats can cause external compression headaches. Loosen them and let your head breathe.'),
    ],
    suggestions: const [
      WellnessTip(icon: '🌿', title: 'Peppermint Oil', detail: 'Apply diluted peppermint oil to your temples. The menthol increases blood flow and provides a cooling, pain-relieving sensation.'),
      WellnessTip(icon: '😌', title: 'Rest in a Quiet Room', detail: 'Lie down in a dark, quiet room for 15–20 minutes. Reducing sensory input gives your nervous system a chance to recover.'),
    ],
  ),

  // ───────── Peace ─────────
  WellnessCategory(
    emoji: '☮️',
    title: 'Peace',
    description: 'Embrace tranquility',
    accentColor: const Color(0xFFC5E1A5),
    tag: 'calm',
    exercises: const [
      WellnessTip(icon: '🕊️', title: 'Loving-Kindness Meditation', detail: 'Silently repeat: "May I be happy. May I be healthy. May I be at peace." Then extend these wishes to others. Practice for 10 minutes.'),
      WellnessTip(icon: '🌳', title: 'Nature Walk Meditation', detail: 'Walk slowly in nature, paying attention to each step. Feel the ground beneath your feet. Notice sounds, smells, and sights mindfully.'),
      WellnessTip(icon: '🎶', title: 'Humming Meditation', detail: 'Close your eyes and hum gently. Feel the vibration in your chest and head. This calms the vagus nerve and promotes inner peace.'),
    ],
    tips: const [
      WellnessTip(icon: '🤫', title: 'Practice Silence', detail: 'Spend 10 minutes in complete silence — no music, no talking, no screens. Just be present with your thoughts.'),
      WellnessTip(icon: '🙏', title: 'Forgive Someone', detail: 'Holding grudges disturbs inner peace. Write a letter of forgiveness (you don\'t have to send it). Release the emotional weight.'),
      WellnessTip(icon: '🌅', title: 'Watch a Sunrise/Sunset', detail: 'Witnessing nature\'s transitions reminds us of life\'s beauty. Sit quietly and absorb the colors and calmness.'),
    ],
    suggestions: const [
      WellnessTip(icon: '🧹', title: 'Simplify Your Space', detail: 'A cluttered space reflects a cluttered mind. Tidy one area of your room — the process itself can be meditative and calming.'),
      WellnessTip(icon: '💌', title: 'Write a Gratitude Letter', detail: 'Write a heartfelt letter to someone you appreciate. Gratitude fills you with warmth and a deep sense of peace.'),
    ],
  ),

  // ───────── Happiness ─────────
  WellnessCategory(
    emoji: '😊',
    title: 'Happiness',
    description: 'Cultivate joy within',
    accentColor: const Color(0xFFFFE082),
    tag: 'general',
    exercises: const [
      WellnessTip(icon: '💃', title: 'Dance for 5 Minutes', detail: 'Put on your favorite upbeat song and dance freely. Movement combined with music is one of the fastest mood boosters.'),
      WellnessTip(icon: '😄', title: 'Smiling Meditation', detail: 'Sit quietly and place a gentle smile on your face. Even a "fake" smile can trick your brain into releasing happy chemicals.'),
      WellnessTip(icon: '🎨', title: 'Creative Expression', detail: 'Draw, paint, write a poem, or cook something new. The act of creating triggers flow state and deep satisfaction.'),
    ],
    tips: const [
      WellnessTip(icon: '🌞', title: 'Get Sunlight', detail: 'Spend 15–20 minutes in natural sunlight. Sunlight boosts serotonin — the "feel good" hormone responsible for happiness.'),
      WellnessTip(icon: '🤗', title: 'Give Someone a Compliment', detail: 'Genuine compliments make both the giver and receiver happier. Try complimenting one person today.'),
      WellnessTip(icon: '🎯', title: 'Set a Small Goal & Achieve It', detail: 'Accomplishing even a tiny goal gives a dopamine boost. Clean a drawer, finish one page, or make one call.'),
    ],
    suggestions: const [
      WellnessTip(icon: '📸', title: 'Revisit Happy Memories', detail: 'Look through old photos or videos that make you smile. Reliving happy moments reactivates those positive emotions.'),
      WellnessTip(icon: '🎁', title: 'Do a Random Act of Kindness', detail: 'Buy someone coffee, hold the door, or send a kind message. Kindness releases oxytocin — the "love hormone."'),
    ],
  ),

  // ───────── Motivation ─────────
  WellnessCategory(
    emoji: '🚀',
    title: 'Motivation',
    description: 'Ignite your drive',
    accentColor: const Color(0xFFFFAB91),
    tag: 'general',
    exercises: const [
      WellnessTip(icon: '📝', title: 'Write Your "Why"', detail: 'Write down WHY your goal matters to you. When motivation fades, reconnecting with your purpose reignites the fire.'),
      WellnessTip(icon: '🏋️', title: 'Start with 2 Minutes', detail: 'Tell yourself "I\'ll just do 2 minutes." Starting is the hardest part — once you begin, momentum takes over.'),
      WellnessTip(icon: '🎭', title: 'Visualization Exercise', detail: 'Close your eyes and vividly imagine yourself achieving your goal. Feel the emotions of success. This primes your brain for action.'),
    ],
    tips: const [
      WellnessTip(icon: '📊', title: 'Track Your Progress', detail: 'Seeing how far you\'ve come (even small steps) creates a sense of accomplishment and motivation to keep going.'),
      WellnessTip(icon: '👥', title: 'Surround Yourself with Doers', detail: 'Motivation is contagious. Spend time with people who inspire and challenge you to grow.'),
      WellnessTip(icon: '🎵', title: 'Create a Power Playlist', detail: 'Music can instantly shift your energy. Create a playlist of songs that make you feel unstoppable.'),
    ],
    suggestions: const [
      WellnessTip(icon: '📚', title: 'Read/Watch Inspiring Stories', detail: 'Stories of people who overcame challenges remind us that struggle is part of success. Read a biography or watch a documentary.'),
      WellnessTip(icon: '🏆', title: 'Reward Yourself', detail: 'After completing a difficult task, treat yourself to something you enjoy. Positive reinforcement builds lasting motivation.'),
    ],
  ),

  // ───────── Gratitude ─────────
  WellnessCategory(
    emoji: '🙏',
    title: 'Gratitude',
    description: 'Appreciate life\'s blessings',
    accentColor: const Color(0xFFCE93D8),
    tag: 'calm',
    exercises: const [
      WellnessTip(icon: '📓', title: '3 Good Things', detail: 'Every evening, write down 3 good things that happened today — no matter how small. This rewires your brain to notice positivity.'),
      WellnessTip(icon: '💌', title: 'Gratitude Letter', detail: 'Write a letter to someone who made a difference in your life. You can deliver it or keep it. The act of writing is the healing part.'),
      WellnessTip(icon: '🧘', title: 'Gratitude Meditation', detail: 'Sit quietly and mentally list things you\'re grateful for — health, people, experiences. Feel genuine thankfulness for each one.'),
    ],
    tips: const [
      WellnessTip(icon: '🗣️', title: 'Say "Thank You" More', detail: 'Express gratitude verbally throughout your day. Thank the barista, your friend, your parent. Small acknowledgments make a big impact.'),
      WellnessTip(icon: '🌍', title: 'Appreciate Simple Things', detail: 'Notice the warmth of the sun, the taste of food, the comfort of your bed. We often overlook what we already have.'),
      WellnessTip(icon: '📷', title: 'Gratitude Photo Album', detail: 'Take one photo daily of something you\'re grateful for. At month\'s end, you\'ll have a visual reminder of life\'s beautiful moments.'),
    ],
    suggestions: const [
      WellnessTip(icon: '🤝', title: 'Volunteer Your Time', detail: 'Helping others puts our own problems in perspective and fills us with gratitude for what we have.'),
      WellnessTip(icon: '🌸', title: 'Start Your Day with Gratitude', detail: 'Before getting out of bed, think of one thing you\'re looking forward to today. It sets a positive tone for the entire day.'),
    ],
  ),

  // ───────── Loneliness ─────────
  WellnessCategory(
    emoji: '🫂',
    title: 'Loneliness',
    description: 'Feel connected again',
    accentColor: const Color(0xFFB3E5FC),
    tag: 'anxiety',
    exercises: const [
      WellnessTip(icon: '📞', title: 'Call an Old Friend', detail: 'Reach out to someone you haven\'t spoken to in a while. A 10-minute call can dissolve feelings of isolation.'),
      WellnessTip(icon: '✍️', title: 'Journal Your Feelings', detail: 'Write about how you\'re feeling without judgment. Putting emotions into words helps process loneliness instead of suppressing it.'),
      WellnessTip(icon: '🤲', title: 'Self-Compassion Exercise', detail: 'Place your hand on your heart and say: "This is a moment of suffering. Suffering is part of being human. May I be kind to myself."'),
    ],
    tips: const [
      WellnessTip(icon: '🏘️', title: 'Join a Community', detail: 'Look for local clubs, online groups, or classes that match your interests. Shared activities create natural connections.'),
      WellnessTip(icon: '🐶', title: 'Adopt or Visit Animals', detail: 'Pets provide unconditional love. Even visiting an animal shelter for an hour can reduce feelings of loneliness.'),
      WellnessTip(icon: '🍳', title: 'Cook for Someone', detail: 'Invite a neighbor or friend for a meal. Sharing food is one of humanity\'s oldest ways of building connection.'),
    ],
    suggestions: const [
      WellnessTip(icon: '📖', title: 'Read a Memoir', detail: 'Reading someone else\'s life story can make you feel understood and less alone in your experiences.'),
      WellnessTip(icon: '🎭', title: 'Attend a Local Event', detail: 'Go to a library talk, a local market, or a community gathering. Being around people — even strangers — reduces isolation.'),
    ],
  ),

  // ───────── Anger Management ─────────
  WellnessCategory(
    emoji: '🔥',
    title: 'Anger Management',
    description: 'Cool down & respond wisely',
    accentColor: const Color(0xFFEF9A9A),
    tag: 'panic',
    exercises: const [
      WellnessTip(icon: '🔟', title: 'Count to 10 Slowly', detail: 'When anger rises, count slowly to 10 before reacting. This pause allows your rational brain to catch up with your emotions.'),
      WellnessTip(icon: '🧊', title: 'Splash Cold Water', detail: 'Splash cold water on your face or hold an ice cube. The cold activates the dive reflex and instantly lowers your heart rate.'),
      WellnessTip(icon: '🚶', title: 'Walk Away for 5 Minutes', detail: 'Remove yourself from the situation. Walk around the block or to another room. Distance provides perspective.'),
    ],
    tips: const [
      WellnessTip(icon: '🗣️', title: 'Use "I" Statements', detail: 'Instead of "You always...", say "I feel... when...". This reduces defensiveness and opens constructive dialogue.'),
      WellnessTip(icon: '🎯', title: 'Identify the Root Cause', detail: 'Anger is often a secondary emotion. Ask yourself: "Am I actually hurt, afraid, or frustrated?" Address the real feeling.'),
      WellnessTip(icon: '📝', title: 'Anger Journal', detail: 'After calming down, write what triggered you, how you reacted, and what you\'d do differently. This builds emotional intelligence.'),
    ],
    suggestions: const [
      WellnessTip(icon: '🥊', title: 'Physical Release', detail: 'Channel anger into exercise — a run, boxing workout, or even squeezing a stress ball. Physical activity metabolizes stress hormones.'),
      WellnessTip(icon: '🎵', title: 'Listen to Calming Music', detail: 'Slow, soothing music can lower blood pressure and heart rate. Build a "cool down" playlist for tense moments.'),
    ],
  ),

  // ───────── Panic Attack ─────────
  WellnessCategory(
    emoji: '🆘',
    title: 'Panic Attack',
    description: 'Immediate relief techniques',
    accentColor: const Color(0xFFFF8A80),
    tag: 'panic',
    exercises: const [
      WellnessTip(icon: '🫁', title: 'Slow Breathing', detail: 'Breathe in for 4 counts, out for 6 counts. Focus only on the breath. This slows your heart rate and signals safety to your brain.'),
      WellnessTip(icon: '🧊', title: 'Hold Ice or Cold Water', detail: 'Hold ice cubes or splash cold water on your wrists and face. The shock of cold redirects your nervous system away from panic.'),
      WellnessTip(icon: '✋', title: '5-4-3-2-1 Grounding', detail: 'Name 5 things you see, 4 you touch, 3 you hear, 2 you smell, 1 you taste. This grounds you firmly in the present moment.'),
    ],
    tips: const [
      WellnessTip(icon: '🗣️', title: 'Talk to Yourself Kindly', detail: 'Say: "This will pass. I am safe. My body is reacting, but I am not in danger." Reassurance calms the fight-or-flight response.'),
      WellnessTip(icon: '🪑', title: 'Sit Down Somewhere Safe', detail: 'Find a safe spot, sit down, close your eyes if possible. Reducing stimulation helps your body de-escalate.'),
      WellnessTip(icon: '📞', title: 'Call Someone You Trust', detail: 'Hearing a calm, familiar voice during a panic attack can be incredibly grounding and reassuring.'),
    ],
    suggestions: const [
      WellnessTip(icon: '🧸', title: 'Hold a Comfort Object', detail: 'A soft blanket, stress ball, or familiar object can ground you through touch and provide a sense of safety.'),
      WellnessTip(icon: '🎧', title: 'Listen to a Guided Meditation', detail: 'A calm voice walking you through relaxation can override the panic signals. Keep a favorite meditation saved on your phone.'),
    ],
  ),
];

// ─── Tab filter labels ───
const List<Map<String, String>> _categoryTabs = [
  {'key': 'all', 'label': 'All', 'emoji': '🌟'},
  {'key': 'calm', 'label': 'Calm', 'emoji': '🌊'},
  {'key': 'anxiety', 'label': 'Anxiety', 'emoji': '🦋'},
  {'key': 'panic', 'label': 'Panic', 'emoji': '🆘'},
  {'key': 'general', 'label': 'General', 'emoji': '🎯'},
];

// ─── Categories Screen ───

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  String _selectedTab = 'all';
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  List<WellnessCategory> get _filteredCategories {
    if (_selectedTab == 'all') return wellnessCategories;
    return wellnessCategories.where((c) => c.tag == _selectedTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0D0D1A), const Color(0xFF1A1A2E)]
                : [const Color(0xFFF7F7FB), const Color(0xFFEFF6F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Meditation & Wellness',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Motivational banner ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9BE7C4).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Text('🧘', style: TextStyle(fontSize: 28)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'What\'s bothering you today?\nLet us help you feel better.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Breathing exercise button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BreathingMeditationScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF9BE7C4).withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF9BE7C4).withOpacity(0.3),
                                const Color(0xFF7AD7C1).withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text('🫁', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Breathing Exercise',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                'Guided deep breathing animation',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.play_circle_fill,
                            color: const Color(0xFF9BE7C4), size: 32),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Category filter tabs ──
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: _categoryTabs.length,
                  itemBuilder: (context, index) {
                    final tab = _categoryTabs[index];
                    final isSelected = _selectedTab == tab['key'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedTab = tab['key']!);
                        _fadeCtrl.reset();
                        _fadeCtrl.forward();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isSelected
                              ? const Color(0xFF9BE7C4)
                              : (isDark
                                  ? const Color(0xFF1E1E2C)
                                  : Colors.white),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${tab['emoji']} ${tab['label']}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // ── Category list ──
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final cat = _filteredCategories[index];
                      return _CategoryCard(
                        category: cat,
                        cardColor: cardColor,
                        textColor: textColor,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final WellnessCategory category;
  final Color cardColor;
  final Color textColor;

  const _CategoryCard({
    required this.category,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalItems =
        category.exercises.length +
        category.tips.length +
        category.suggestions.length;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WellnessDetailScreen(category: category),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji circle
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: category.accentColor.withOpacity(isDark ? 0.15 : 0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Title + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Tip count + arrow
            Text(
              '$totalItems tips',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade500 : Colors.grey,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right,
                color: isDark ? Colors.grey.shade500 : Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
