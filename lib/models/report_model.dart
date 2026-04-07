class ReportModel {
  String name;
  String date;
  int face;
  int voice;
  int text;
  int combined;
  String emotion;
  String reason;
  String future;

  ReportModel({
    required this.name,
    required this.date,
    required this.face,
    required this.voice,
    required this.text,
    required this.combined,
    required this.emotion,
    required this.reason,
    required this.future,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date,
    'face': face,
    'voice': voice,
    'text': text,
    'combined': combined,
    'emotion': emotion,
    'reason': reason,
    'future': future,
  };

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
    name: json['name'] ?? '',
    date: json['date'] ?? '',
    face: json['face'] ?? 0,
    voice: json['voice'] ?? 0,
    text: json['text'] ?? 0,
    combined: json['combined'] ?? 0,
    emotion: json['emotion'] ?? '',
    reason: json['reason'] ?? '',
    future: json['future'] ?? '',
  );
}
