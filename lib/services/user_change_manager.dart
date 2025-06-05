import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserChange {
  final String type; // add, update, delete
  final String entity; // warehouse, medicine
  final Map<String, dynamic> data;
  final DateTime timestamp;

  UserChange({
    required this.type,
    required this.entity,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'entity': entity,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory UserChange.fromJson(Map<String, dynamic> json) => UserChange(
        type: json['type'],
        entity: json['entity'],
        data: Map<String, dynamic>.from(json['data']),
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class UserChangeManager {
  static const String _key = 'user_changes';

  static Future<List<UserChange>> getChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => UserChange.fromJson(json.decode(e))).toList();
  }

  static Future<void> addChange(UserChange change) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(json.encode(change.toJson()));
    await prefs.setStringList(_key, list);
  }

  static Future<void> clearChanges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<String> exportChanges() async {
    final changes = await getChanges();
    return json.encode(changes.map((e) => e.toJson()).toList());
  }

  static Future<void> importChanges(String jsonStr) async {
    final prefs = await SharedPreferences.getInstance();
    final List<dynamic> decoded = json.decode(jsonStr);
    final list = decoded.map((e) => json.encode(e)).toList();
    await prefs.setStringList(_key, list);
  }
}
