class Schedule {
  final int? id;
  final String date; // yyyy-MM-dd
  final int shiftId;
  final String? note;
  final bool isLeave;
  final String? leaveType; // 年假、病假、事假、调休

  Schedule({
    this.id,
    required this.date,
    required this.shiftId,
    this.note,
    this.isLeave = false,
    this.leaveType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'shiftId': shiftId,
      'note': note,
      'isLeave': isLeave ? 1 : 0,
      'leaveType': leaveType,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as int?,
      date: map['date'] as String,
      shiftId: map['shiftId'] as int,
      note: map['note'] as String?,
      isLeave: (map['isLeave'] as int) == 1,
      leaveType: map['leaveType'] as String?,
    );
  }

  Schedule copyWith({
    int? id,
    String? date,
    int? shiftId,
    String? note,
    bool? isLeave,
    String? leaveType,
  }) {
    return Schedule(
      id: id ?? this.id,
      date: date ?? this.date,
      shiftId: shiftId ?? this.shiftId,
      note: note ?? this.note,
      isLeave: isLeave ?? this.isLeave,
      leaveType: leaveType ?? this.leaveType,
    );
  }
}
