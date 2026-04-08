class StressEntry {
  final String timestamp;
  final double combinedStress;
  final double fatigueLevel;
  final String emotion;

  StressEntry({
    required this.timestamp,
    required this.combinedStress,
    required this.fatigueLevel,
    required this.emotion,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'combinedStress': combinedStress,
    'fatigueLevel': fatigueLevel,
    'emotion': emotion,
  };

  factory StressEntry.fromJson(Map<String, dynamic> json) => StressEntry(
    timestamp: json['timestamp'] ?? '',
    combinedStress: (json['combinedStress'] as num?)?.toDouble() ?? 0.0,
    fatigueLevel: (json['fatigueLevel'] as num?)?.toDouble() ?? 0.0,
    emotion: json['emotion'] ?? '',
  );
}

class WeeklyEntry {
  final String day; // Monday, Tuesday, etc.
  final String date; // Full date string
  final List<StressEntry> entries;

  WeeklyEntry({
    required this.day,
    required this.date,
    required this.entries,
  });

  Map<String, dynamic> toJson() => {
    'day': day,
    'date': date,
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  factory WeeklyEntry.fromJson(Map<String, dynamic> json) => WeeklyEntry(
    day: json['day'] ?? '',
    date: json['date'] ?? '',
    entries: (json['entries'] as List?)
            ?.map((e) => StressEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
