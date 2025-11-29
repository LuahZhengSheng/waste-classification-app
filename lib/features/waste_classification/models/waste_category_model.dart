import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';

class WasteCategory {
  final String categoryId;
  final String name;
  final String description;
  final String disposalMethod;
  final IconData icon;
  final Color color;
  final double? basePoints;
  final List<String> examples;
  final bool isRecyclable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? emissionFactor;

  WasteCategory({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.disposalMethod,
    required this.icon,
    required this.color,
    this.basePoints,
    required this.examples,
    required this.isRecyclable,
    required this.createdAt,
    required this.updatedAt,
    this.emissionFactor,
  });

  factory WasteCategory.empty() {
    return WasteCategory(
      categoryId: '',
      name: '',
      description: '',
      disposalMethod: '',
      icon: Iconsax.trash,
      color: Colors.grey,
      basePoints: null,
      examples: [],
      isRecyclable: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      emissionFactor: null,
    );
  }

  factory WasteCategory.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return WasteCategory(
      categoryId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      disposalMethod: data['disposalMethod'] ?? '',
      icon: _parseIconData(data['icon'] ?? 'trash'),
      color: _parseColor(data['color']),
      basePoints: data['basePoints']?.toDouble(),
      examples: List<String>.from(data['examples'] ?? []),
      isRecyclable: data['isRecyclable'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      emissionFactor: data['emissionFactor']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'disposalMethod': disposalMethod,
      'icon': _iconToString(icon),
      'color': _colorToHex(color),
      'basePoints': basePoints,
      'examples': examples,
      'isRecyclable': isRecyclable,
      'emissionFactor': emissionFactor,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory WasteCategory.fromJson(Map<String, dynamic> json) {
    return WasteCategory(
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      disposalMethod: json['disposalMethod'] ?? '',
      icon: _parseIconData(json['icon'] ?? 'trash'),
      color: _parseColor(json['color']),
      basePoints: json['basePoints']?.toDouble(),
      examples: List<String>.from(json['examples'] ?? []),
      isRecyclable: json['isRecyclable'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      emissionFactor: json['emissionFactor']?.toDouble(),
    );
  }

  static IconData _parseIconData(String iconString) {
    final iconMap = {
      'battery': Iconsax.battery_charging,
      'trash': Iconsax.trash,
      'box': Iconsax.box,
      'document': Iconsax.document,
      'glass': Iconsax.glass,
      'mobile': Iconsax.mobile,
      'brush': Iconsax.brush,
      'cake': Iconsax.cake,
      'warning': Iconsax.warning_2,
      'category': Iconsax.category,
      'cpu': Iconsax.cpu,
      'tree': Iconsax.tree,
      'recycling': Icons.recycling,
      'description': Icons.description,
      'local_bar': Icons.local_bar,
      'phone_android': Icons.phone_android,
      'warning_material': Icons.warning,
      'checkroom': Icons.checkroom,
      'eco': Icons.eco,
      'hardware': Icons.hardware,
    };
    return iconMap[iconString] ?? Iconsax.trash;
  }

  static String _iconToString(IconData icon) {
    final iconMap = {
      Iconsax.battery_charging: 'battery',
      Iconsax.trash: 'trash',
      Iconsax.box: 'box',
      Iconsax.document: 'document',
      Iconsax.glass: 'glass',
      Iconsax.mobile: 'mobile',
      Iconsax.brush: 'brush',
      Iconsax.cake: 'cake',
      Iconsax.warning_2: 'warning',
      Iconsax.category: 'category',
      Iconsax.cpu: 'cpu',
      Iconsax.tree: 'tree',
      Icons.recycling: 'recycling',
      Icons.description: 'description',
      Icons.local_bar: 'local_bar',
      Icons.phone_android: 'phone_android',
      Icons.warning: 'warning_material',
      Icons.checkroom: 'checkroom',
      Icons.eco: 'eco',
      Icons.hardware: 'hardware',
    };
    return iconMap[icon] ?? 'trash';
  }

  static Color _parseColor(dynamic colorData) {
    if (colorData is String && colorData.isNotEmpty) {
      try {
        return Color(int.parse(colorData.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.green;
      }
    }
    return Colors.green;
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  WasteCategory copyWith({
    String? categoryId,
    String? name,
    String? description,
    String? disposalMethod,
    IconData? icon,
    Color? color,
    double? basePoints,
    List<String>? examples,
    bool? isRecyclable,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? emissionFactor,
  }) {
    return WasteCategory(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      disposalMethod: disposalMethod ?? this.disposalMethod,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      basePoints: basePoints ?? this.basePoints,
      examples: examples ?? this.examples,
      isRecyclable: isRecyclable ?? this.isRecyclable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emissionFactor: emissionFactor ?? this.emissionFactor,
    );
  }

  String get formattedPoints => basePoints != null ? '${basePoints!.toStringAsFixed(1)} points/kg' : 'No points';

  String get formattedExamples => examples.join(', ');

  bool get isHazardous => name.contains('Battery') || name.contains('Hazardous');

  String get disposalMethodWithEmoji {
    if (disposalMethod.contains('Recycle')) return '♻️ $disposalMethod';
    if (disposalMethod.contains('Process')) return '⚡ $disposalMethod';
    if (disposalMethod.contains('Landfill')) return '🗑️ $disposalMethod';
    return disposalMethod;
  }

  @override
  String toString() {
    return 'WasteCategory(categoryId: $categoryId, name: $name, basePoints: $basePoints, isRecyclable: $isRecyclable)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WasteCategory &&
              runtimeType == other.runtimeType &&
              categoryId == other.categoryId;

  @override
  int get hashCode => categoryId.hashCode;
}