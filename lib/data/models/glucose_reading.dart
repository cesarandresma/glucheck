import '../../core/constants/measurement_contexts.dart';

enum GlucoseSource { manual, imported, device }

class GlucoseReading {
  GlucoseReading({
    required this.id,
    required this.userId,
    required this.valueMgDl,
    required this.measuredAt,
    required this.context,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.source = GlucoseSource.manual,
    this.isDemo = false,
  });

  final String id;
  final String userId;
  final double valueMgDl;
  final DateTime measuredAt;
  final String context;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GlucoseSource source;
  final bool isDemo;

  GlucoseReading copyWith({
    String? id,
    String? userId,
    double? valueMgDl,
    DateTime? measuredAt,
    String? context,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    GlucoseSource? source,
    bool? isDemo,
  }) {
    return GlucoseReading(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      valueMgDl: valueMgDl ?? this.valueMgDl,
      measuredAt: measuredAt ?? this.measuredAt,
      context: context ?? this.context,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'valueMgDl': valueMgDl,
      'measuredAt': measuredAt.toUtc().millisecondsSinceEpoch,
      'context': context,
      'notes': notes,
      'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
      'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
      'source': source.name,
      'isDemo': isDemo,
    };
  }

  factory GlucoseReading.fromMap(String id, Map<String, dynamic> map) {
    return GlucoseReading(
      id: id,
      userId: map['userId'] as String,
      valueMgDl: (map['valueMgDl'] as num).toDouble(),
      measuredAt: DateTime.fromMillisecondsSinceEpoch(
        map['measuredAt'] as int,
        isUtc: true,
      ),
      context: map['context'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] as int,
        isUtc: true,
      ),
      source: GlucoseSource.values.firstWhere(
        (s) => s.name == (map['source'] as String? ?? 'manual'),
        orElse: () => GlucoseSource.manual,
      ),
      isDemo: map['isDemo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toLocalJson() => {'id': id, ...toMap()};

  factory GlucoseReading.fromLocalJson(Map<dynamic, dynamic> json) {
    return GlucoseReading.fromMap(
      json['id'] as String,
      Map<String, dynamic>.from(json)..remove('id'),
    );
  }

  static bool isValidContext(String context) =>
      MeasurementContexts.all.contains(context);
}
