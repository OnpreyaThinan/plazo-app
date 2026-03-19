import 'dart:typed_data';

enum ItemType { task, exam }

class PlazoItem {
  String id;
  ItemType type;
  String title;
  String subject;
  String date;
  String time;
  String description;
  String? location;
  bool isCompleted;

  PlazoItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subject,
    required this.date,
    required this.time,
    this.description = '',
    this.location,
    this.isCompleted = false,
  });
}

class UserProfile {
  String name;
  String email;
  String avatarUrl;
  Uint8List? avatarBytes;

  UserProfile({
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.avatarBytes,
  });
}
