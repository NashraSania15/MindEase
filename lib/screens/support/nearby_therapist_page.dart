

// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mindease/data/therapist_data.dart';

// class NearbyTherapistPage extends StatefulWidget {
//   const NearbyTherapistPage({super.key});

//   @override
//   State<NearbyTherapistPage> createState() =>
//       _NearbyTherapistPageState();
// }

// class _NearbyTherapistPageState
//     extends State<NearbyTherapistPage> {

//   final TextEditingController _controller =
//       TextEditingController();

//   List<Map<String, dynamic>> _therapists = [];
//   List<Map<String, dynamic>> wishlistData = [];
//   Set<String> wishlistIds = {};

//   bool showResults = false;
//   String selectedFilter = "all";

//   final String userId = "demo_user";

//   @override
//   void initState() {
//     super.initState();
//     _loadWishlist();
//   }

//   Future<void> _loadWishlist() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection("users")
//         .doc(userId)
//         .collection("wishlist")
//         .get();

//     wishlistIds =
//         snapshot.docs.map((e) => e.id).toSet();

//     wishlistData =
//         snapshot.docs.map((e) => e.data()).toList();

//     setState(() {});
//   }

//   Future<void> _toggleWishlist(
//       Map<String, dynamic> t) async {
//     final id = t["name"];

//     final ref = FirebaseFirestore.instance
//         .collection("users")
//         .doc(userId)
//         .collection("wishlist")
//         .doc(id);

//     if (wishlistIds.contains(id)) {
//       await ref.delete();
//       wishlistIds.remove(id);
//     } else {
//       await ref.set(t);
//       wishlistIds.add(id);
//     }

//     await _loadWishlist();
//   }

//   // ✅ FIXED SEARCH FUNCTION
//   void _search() {
//     final input =
//         _controller.text.toLowerCase().trim();

//     List<Map<String, dynamic>> results = [];

//     therapistData.forEach((area, data) {
//       final Map<String, dynamic> areaData = data;

//       if (input.contains(area) ||
//           input.contains(areaData["pincode"])) {
//         results.addAll(
//           List<Map<String, dynamic>>.from(
//               areaData["places"]),
//         );
//       }

//       for (var place in areaData["places"]) {
//         if ((place["name"] ?? "")
//             .toLowerCase()
//             .contains(input)) {
//           results.add(
//               Map<String, dynamic>.from(place));
//         }
//       }
//     });

//     final unique = {
//       for (var e in results) e["name"]: e
//     }.values.toList();

//     setState(() {
//       _therapists = unique;
//       showResults = true;
//       selectedFilter = "all";
//     });
//   }

//   void _call(String phone) async {
//     if (phone.isEmpty) return;
//     await launchUrl(Uri.parse("tel:$phone"));
//   }

//   void _map(String name, String address) async {
//     final query =
//         Uri.encodeComponent("$name $address");
//     final url =
//         "https://www.google.com/maps/search/?api=1&query=$query";
//     await launchUrl(Uri.parse(url));
//   }

//   // ✅ FIXED FILTER
//   List<Map<String, dynamic>> get filteredList {
//     if (selectedFilter == "top") {
//       return _therapists
//           .where((t) =>
//               (double.tryParse(
//                           t["rating"] ?? "0") ??
//                       0) >=
//                   4.5)
//           .toList();
//     } else if (selectedFilter == "wishlist") {
//       return wishlistData;
//     }
//     return _therapists;
//   }

//   @override
//   Widget build(BuildContext context) {

//     final isDark =
//         Theme.of(context).brightness ==
//             Brightness.dark;

//     return Scaffold(
//       backgroundColor:
//           isDark ? const Color(0xFF020617) : Colors.white,

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [

//               Row(
//                 children: const [
//                   BackButton(),
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         "Nearby Therapist",
//                         style: TextStyle(
//                             fontSize: 20,
//                             fontWeight:
//                                 FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 48)
//                 ],
//               ),

//               const SizedBox(height: 6),

//               const Center(
//                 child: Text(
//                   "Find the right support near you",
//                   style:
//                       TextStyle(color: Colors.grey),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration:
//                           InputDecoration(
//                         hintText:
//                             "Enter area or pincode",
//                         filled: true,
//                         fillColor: isDark
//                             ? Colors.white10
//                             : Colors.grey[200],
//                         border:
//                             OutlineInputBorder(
//                           borderRadius:
//                               BorderRadius.circular(
//                                   20),
//                           borderSide:
//                               BorderSide.none,
//                         ),
//                         prefixIcon: const Icon(
//                             Icons.location_on,
//                             color: Colors.teal),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: _search,
//                     child: Container(
//                       padding:
//                           const EdgeInsets.all(14),
//                       decoration:
//                           BoxDecoration(
//                         color: Colors.teal,
//                         borderRadius:
//                             BorderRadius.circular(
//                                 16),
//                       ),
//                       child: const Icon(
//                         Icons.search,
//                         color: Colors.white,
//                       ),
//                     ),
//                   )
//                 ],
//               ),

//               const SizedBox(height: 20),

//               if (!showResults)
//                 const Center(
//                   child: Text("Search for therapists"),
//                 ),

//               if (showResults) ...[
//                 const SizedBox(height: 20),

//                 ...filteredList.map((t) {
//                   final isSaved =
//                       wishlistIds.contains(t["name"]);

//                   return Container(
//                     margin:
//                         const EdgeInsets.only(bottom: 16),
//                     padding:
//                         const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: isDark
//                           ? const Color(0xFF1E293B)
//                           : Colors.grey[100],
//                       borderRadius:
//                           BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 t["name"],
//                                 style: const TextStyle(
//                                     fontWeight:
//                                         FontWeight.bold),
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () =>
//                                   _toggleWishlist(t),
//                               child: Icon(
//                                 isSaved
//                                     ? Icons.favorite
//                                     : Icons
//                                         .favorite_border,
//                                 color: Colors.red,
//                               ),
//                             )
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Text(t["address"]),
//                         const SizedBox(height: 6),
//                         Text("⭐ ${t["rating"]}"),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () =>
//                                     _call(t["phone"] ?? ""),
//                                 child: const Text("Call"),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () => _map(
//                                     t["name"],
//                                     t["address"]),
//                                 style:
//                                     ElevatedButton.styleFrom(
//                                         backgroundColor:
//                                             Colors.teal),
//                                 child:
//                                     const Text("View on Map"),
//                               ),
//                             )
//                           ],
//                         )
//                       ],
//                     ),
//                   );
//                 })
//               ]
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindease/data/therapist_data.dart';

class NearbyTherapistPage extends StatefulWidget {
  const NearbyTherapistPage({super.key});

  @override
  State<NearbyTherapistPage> createState() =>
      _NearbyTherapistPageState();
}

class _NearbyTherapistPageState
    extends State<NearbyTherapistPage> {

  final TextEditingController _controller =
      TextEditingController();

  List<Map<String, dynamic>> _therapists = [];
  List<Map<String, dynamic>> wishlistData = [];
  Set<String> wishlistIds = {};

  bool showResults = false;
  String selectedFilter = "all";

  final String userId = "demo_user";

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("wishlist")
        .get();

    wishlistIds =
        snapshot.docs.map((e) => e.id).toSet();

    wishlistData =
        snapshot.docs.map((e) => e.data()).toList();

    setState(() {});
  }

  Future<void> _toggleWishlist(
      Map<String, dynamic> t) async {
    final id = t["name"];

    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("wishlist")
        .doc(id);

    if (wishlistIds.contains(id)) {
      await ref.delete();
      wishlistIds.remove(id);
    } else {
      await ref.set(t);
      wishlistIds.add(id);
    }

    await _loadWishlist();
  }

  // ✅ FIXED SEARCH
  void _search() {
    final input =
        _controller.text.toLowerCase().trim();

    List<Map<String, dynamic>> results = [];

    therapistData.forEach((area, data) {
      final areaData = data;

      if (input.contains(area) ||
          input.contains(areaData["pincode"])) {
        results.addAll(
          List<Map<String, dynamic>>.from(
              areaData["places"]),
        );
      }

      for (var place in areaData["places"]) {
        if ((place["name"] ?? "")
            .toLowerCase()
            .contains(input)) {
          results.add(
              Map<String, dynamic>.from(place));
        }
      }
    });

    final unique = {
      for (var e in results) e["name"]: e
    }.values.toList();

    setState(() {
      _therapists = unique;
      showResults = true;
      selectedFilter = "all";
    });
  }

  void _call(String phone) async {
    if (phone.isEmpty) return;
    await launchUrl(Uri.parse("tel:$phone"));
  }

  void _map(String name, String address) async {
    final query =
        Uri.encodeComponent("$name $address");
    final url =
        "https://www.google.com/maps/search/?api=1&query=$query";
    await launchUrl(Uri.parse(url));
  }

  // ✅ SAFE FILTER
  List<Map<String, dynamic>> get filteredList {
    if (selectedFilter == "top") {
      return _therapists
          .where((t) =>
              (double.tryParse(
                          t["rating"] ?? "0") ??
                      0) >=
                  4.5)
          .toList();
    } else if (selectedFilter == "wishlist") {
      return wishlistData;
    }
    return _therapists;
  }

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF020617) : Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // HEADER
              Row(
                children: const [
                  BackButton(),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Nearby Therapist",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: 48)
                ],
              ),

              const SizedBox(height: 6),

              const Center(
                child: Text(
                  "Find the right support near you",
                  style:
                      TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              // SEARCH BAR
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration:
                          InputDecoration(
                        hintText:
                            "Enter area or pincode",
                        filled: true,
                        fillColor: isDark
                            ? Colors.white10
                            : Colors.grey[200],
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                          borderSide:
                              BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                            Icons.location_on,
                            color: Colors.teal),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _search,
                    child: Container(
                      padding:
                          const EdgeInsets.all(14),
                      decoration:
                          BoxDecoration(
                        color: Colors.teal,
                        borderRadius:
                            BorderRadius.circular(
                                16),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // 🔥 HOME UI
              if (!showResults) ...[

                const Text(
                  "Popular Areas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    "kukatpally",
                    "banjara hills",
                    "jubilee hills",
                    "gachibowli",
                    "miyapur",
                    "uppal",
                    "secunderabad"
                  ].map((area) {
                    return GestureDetector(
                      onTap: () {
                        _controller.text = area;
                        _search();
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10),
                        decoration:
                            BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.grey[200],
                          borderRadius:
                              BorderRadius.circular(
                                  30),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on,
                                size: 16,
                                color: Colors.teal),
                            const SizedBox(width: 5),
                            Text(area),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // CARD
                Container(
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : Colors.grey[100],
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/icons/mental_card.png.jpeg",
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your mental well-being matters",
                              style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Explore trusted therapists available in your area.",
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 34),

                const Text("How it works",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold)),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    _step(Icons.search, "Search"),
                    _step(Icons.visibility, "Explore"),
                    _step(Icons.call, "Contact"),
                  ],
                ),
              ],

              // 🔥 RESULTS UI (BEAUTIFUL ONE)
              if (showResults) ...[
                const SizedBox(height: 20),

                Row(
                  children: [
                    _filterBtn("All", "all"),
                    _filterBtn("Top Rated", "top"),
                    _filterBtn("Wishlist", "wishlist"),
                  ],
                ),

                const SizedBox(height: 20),

                ...filteredList.map((t) {
                  final isSaved =
                      wishlistIds.contains(t["name"]);

                  return Container(
                    margin:
                        const EdgeInsets.only(bottom: 16),
                    padding:
                        const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.grey[100],
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Colors.teal
                                      .withOpacity(0.2),
                              child: Text(
                                t["name"][0],
                                style: const TextStyle(
                                    color: Colors.teal),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                t["name"],
                                style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _toggleWishlist(t),
                              icon: Icon(
                                isSaved
                                    ? Icons.favorite
                                    : Icons
                                        .favorite_border,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(t["address"]),
                        const SizedBox(height: 6),
                        Text("⭐ ${t["rating"]}"),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    _call(
                                        t["phone"] ?? ""),
                                child:
                                    const Text("Call"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _map(
                                    t["name"],
                                    t["address"]),
                                style:
                                    ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.teal),
                                child: const Text(
                                    "View on Map"),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                })
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.teal,
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(text),
      ],
    );
  }

  Widget _filterBtn(String text, String value) {
    final isSelected = selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.teal
                : Colors.grey[300],
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}