class WasteEntry {
  final String id;
  final String name;
  final String chef;
  final String reason;
  final double totalWeight;
  final double wasteWeight;
  final double limit;
  final DateTime date;

  WasteEntry({
    required this.id,
    required this.name,
    required this.chef,
    required this.reason,
    required this.totalWeight,
    required this.wasteWeight,
    required this.limit,
    required this.date,
  });

  double get calculatedPercent => totalWeight > 0 ? (wasteWeight / totalWeight) * 100 : 0.0;

  factory WasteEntry.fromMap(Map<String, dynamic> map, String documentId) {
    return WasteEntry(
      id: documentId,
      name: map['name'] ?? '',
      chef: map['chef'] ?? '',
      reason: map['reason'] ?? '',
      totalWeight: (map['totalWeight'] ?? 0).toDouble(),
      wasteWeight: (map['wasteWeight'] ?? 0).toDouble(),
      limit: (map['limit'] ?? 10).toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'chef': chef,
      'reason': reason,
      'totalWeight': totalWeight,
      'wasteWeight': wasteWeight,
      'limit': limit,
      'date': date.toIso8601String(),
    };
  }
}