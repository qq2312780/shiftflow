class Shift {
  final int? id;
  final String name;
  final String startTime; // HH:mm
  final String endTime;   // HH:mm
  final int colorValue;
  final double hourlyRate;
  final double? overtimeRate;

  Shift({
    this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.colorValue,
    required this.hourlyRate,
    this.overtimeRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'colorValue': colorValue,
      'hourlyRate': hourlyRate,
      'overtimeRate': overtimeRate,
    };
  }

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] as int?,
      name: map['name'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      colorValue: map['colorValue'] as int,
      hourlyRate: map['hourlyRate'] as double,
      overtimeRate: map['overtimeRate'] as double?,
    );
  }

  Shift copyWith({
    int? id,
    String? name,
    String? startTime,
    String? endTime,
    int? colorValue,
    double? hourlyRate,
    double? overtimeRate,
  }) {
    return Shift(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      colorValue: colorValue ?? this.colorValue,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      overtimeRate: overtimeRate ?? this.overtimeRate,
    );
  }

  Duration get duration {
    final parts = startTime.split(':');
    final startHour = int.parse(parts[0]);
    final startMin = int.parse(parts[1]);
    final endParts = endTime.split(':');
    final endHour = int.parse(endParts[0]);
    final endMin = int.parse(endParts[1]);
    
    var startMinutes = startHour * 60 + startMin;
    var endMinutes = endHour * 60 + endMin;
    if (endMinutes < startMinutes) endMinutes += 24 * 60;
    return Duration(minutes: endMinutes - startMinutes);
  }

  double get hours => duration.inMinutes / 60.0;

  @override
  String toString() => '$name ($startTime-$endTime)';
}
