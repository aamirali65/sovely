import 'dart:convert';
import 'package:flutter/services.dart';

class SoundModel {
  final String id;
  final String name;
  final String assetPath;
  final String iconName;
  final String category;
  final bool isPremium;
  final String imagePath;

  const SoundModel({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.iconName,
    required this.category,
    required this.imagePath,
    this.isPremium = false,
  });

  factory SoundModel.fromJson(Map<String, dynamic> json) => SoundModel(
    id: json['id'],
    name: json['name'],
    assetPath: json['assetPath'],
    iconName: json['iconName'],
    category: json['category'],
    imagePath: json['imagePath'] ?? '',
    isPremium: json['isPremium'] ?? false,
  );
}

List<SoundModel> kSounds = [];

Future<void> loadSounds() async {
  final String data = await rootBundle.loadString('assets/sounds.json');
  final List<dynamic> json = jsonDecode(data);
  kSounds = json.map((e) => SoundModel.fromJson(e)).toList();
}