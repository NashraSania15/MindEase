// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';

// class RelaxingSoundsPage extends StatefulWidget {
//   const RelaxingSoundsPage({super.key});

//   @override
//   State<RelaxingSoundsPage> createState() => _RelaxingSoundsPageState();
// }

// class _RelaxingSoundsPageState extends State<RelaxingSoundsPage> {

//   final AudioPlayer _player = AudioPlayer();
//   String? currentPlaying;

//   final List<Map<String, String>> sounds = [
//     {"title": "Birds", "file": "icons/sounds/birds.mp3"},
//     {"title": "Calm Music", "file": "icons/sounds/calm_music.mp3"},
//     {"title": "Flute", "file": "icons/sounds/flute.mp3"},
//     {"title": "Forest", "file": "icons/sounds/forest.mp3"},
//     {"title": "Guitar", "file": "icons/sounds/guitar.mp3"},
//     {"title": "Indigo Music", "file": "icons/sounds/indigo_music.mp3"},
//     {"title": "Ocean Waves", "file": "icons/sounds/ocean.mp3"},
//     {"title": "Rain", "file": "icons/sounds/rain.mp3"},
//     {"title": "Relaxing Music", "file": "icons/sounds/relaxing_music.mp3"},
//     {"title": "River", "file": "icons/sounds/river.mp3"},
//     {"title": "Sleep Music", "file": "icons/sounds/sleep_music.mp3"},
//     {"title": "Soft Piano", "file": "icons/sounds/soft_piano.mp3"},
//     {"title": "Thunder", "file": "icons/sounds/thunder.mp3"},
//   ];

//   void playSound(String file) async {
//     await _player.stop();
//     await _player.play(AssetSource(file));

//     setState(() {
//       currentPlaying = file;
//     });
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Relaxing Sounds"),
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: sounds.length,
//         itemBuilder: (context, index) {

//           final sound = sounds[index];
//           final isPlaying = currentPlaying == sound["file"];

//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Row(
//               children: [

//                 const Icon(Icons.music_note, color: Colors.teal),

//                 const SizedBox(width: 12),

//                 Expanded(
//                   child: Text(
//                     sound["title"]!,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),

//                 IconButton(
//                   icon: Icon(
//                     isPlaying ? Icons.stop : Icons.play_arrow,
//                     color: Colors.teal,
//                   ),
//                   onPressed: () {
//                     if (isPlaying) {
//                       _player.stop();
//                       setState(() {
//                         currentPlaying = null;
//                       });
//                     } else {
//                       playSound(sound["file"]!);
//                     }
//                   },
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }












import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class RelaxingSoundsPage extends StatefulWidget {
  const RelaxingSoundsPage({super.key});

  @override
  State<RelaxingSoundsPage> createState() => _RelaxingSoundsPageState();
}

class _RelaxingSoundsPageState extends State<RelaxingSoundsPage> {
  final AudioPlayer _player = AudioPlayer();
  String? currentPlaying;

  final List<Map<String, String>> sounds = [
    {
      "title": "Birds",
      "subtitle": "Chirping birds in the morning",
      "file": "icons/sounds/birds.mp3",
      "image": "assets/icons/sound_icons/birds.jpeg"
    },
    {
      "title": "Calm Music",
      "subtitle": "Soothing melodies to relax",
      "file": "icons/sounds/calm_music.mp3",
      "image": "assets/icons/sound_icons/calm_music.jpeg"
    },
    {
      "title": "Flute",
      "subtitle": "Peaceful flute tunes",
      "file": "icons/sounds/flute.mp3",
      "image": "assets/icons/sound_icons/flute.jpeg"
    },
    {
      "title": "Forest",
      "subtitle": "Sounds of a calm forest",
      "file": "icons/sounds/forest.mp3",
      "image": "assets/icons/sound_icons/forest.jpeg"
    },
    {
      "title": "Guitar",
      "subtitle": "Soft guitar instrumentals",
      "file": "icons/sounds/guitar.mp3",
      "image": "assets/icons/sound_icons/guitar.jpeg"
    },
    {
      "title": "Indigo Music",
      "subtitle": "Deep ambient vibes",
      "file": "icons/sounds/indigo_music.mp3",
      "image": "assets/icons/sound_icons/indigo.jpeg"
    },
    {
      "title": "Ocean Waves",
      "subtitle": "Waves crashing on the shore",
      "file": "icons/sounds/ocean.mp3",
      "image": "assets/icons/sound_icons/ocean.jpeg"
    },
    {
      "title": "Rain",
      "subtitle": "Gentle rain for deep sleep",
      "file": "icons/sounds/rain.mp3",
      "image": "assets/icons/sound_icons/rain.jpeg"
    },
    {
      "title": "Relaxing Music",
      "subtitle": "Soft melodies to calm your mind",
      "file": "icons/sounds/relaxing_music.mp3",
      "image": "assets/icons/sound_icons/relaxing_music.jpeg"
    },
    {
      "title": "River",
      "subtitle": "Flowing river sounds",
      "file": "icons/sounds/river.mp3",
      "image": "assets/icons/sound_icons/river.jpeg"
    },
    {
      "title": "Sleep Music",
      "subtitle": "Peaceful tunes for deep sleep",
      "file": "icons/sounds/sleep_music.mp3",
      "image": "assets/icons/sound_icons/sleep_music.jpeg"
    },
    {
      "title": "Soft Piano",
      "subtitle": "Gentle piano melodies",
      "file": "icons/sounds/soft_piano.mp3",
      "image": "assets/icons/sound_icons/soft_piano.jpeg"
    },
    {
      "title": "Thunder",
      "subtitle": "Deep rumbling thunder sounds",
      "file": "icons/sounds/thunder.mp3",
      "image": "assets/icons/sound_icons/thunder.jpeg"
    },
  ];

  void playSound(String file) async {
    await _player.stop();
    await _player.play(AssetSource(file));

    setState(() {
      currentPlaying = file;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Relaxing Sounds",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Unwind your mind, relax your body 🌿",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                final sound = sounds[index];
                final isPlaying = currentPlaying == sound["file"];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // LEFT IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          sound["image"]!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sound["title"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sound["subtitle"]!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // PLAY BUTTON
                      GestureDetector(
                        onTap: () {
                          if (isPlaying) {
                            _player.stop();
                            setState(() {
                              currentPlaying = null;
                            });
                          } else {
                            playSound(sound["file"]!);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
                            ),
                          ),
                          child: Icon(
                            isPlaying ? Icons.stop : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}