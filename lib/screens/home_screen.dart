import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/shift.dart';
import '../models/schedule.dart';
import 'shift_detail.dart';
import 'shift_library.dart';
import 'statistics_screen.dart';
import 'loop_setting.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _currentMonth = DateTime.now();
  List<Shift> _shifts = [];
  Map<String, Schedule> _schedules = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final shifts = await DBHelper.instance.getAllShifts();
    final schedules = await DBHelper.instance.getSchedulesByMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    final scheduleMap = {
      for (var s in schedules) s.date: s
    };

    if (mounted) {
      setState(() {
        _shifts = shifts;
        _schedules = scheduleMap;
      });
    }
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    _loadData();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    _loadData();
  }

  void _goToToday() {
    setState(() {
      _currentMonth = DateTime.now();
    });
    _loadData();
  }

  Future<void> _onDateTap(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final existing = _schedules[dateStr];

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ShiftPickerBottomSheet(
        shifts: _shifts,
        existingSchedule: existing,
        date: date,
      ),
    );

    if (result == null) return;

    if (result['delete'] == true && existing != null) {
      await DBHelper.instance.deleteSchedule(existing.id!);
    } else if (result['shiftId'] != null) {
      final shiftId = result['shiftId'] as int;
      final note = result['note'] as String?;
      final isLeave = result['isLeave'] as bool? ?? false;
      final leaveType = result['leaveType'] as String?;

      if (existing != null) {
        await DBHelper.instance.updateSchedule(
          existing.copyWith(
            shiftId: shiftId,
            note: note,
            isLeave: isLeave,
            leaveType: leaveType,
          ),
        );
      } else {
        await DBHelper.instance.insertSchedule(Schedule(
          date: dateStr,
          shiftId: shiftId,
          note: note,
          isLeave: isLeave,
          leaveType: leaveType,
        ));
      }
    }

    await _loadData();
  }

  Shift? _getShiftForSchedule(Schedule? schedule) {
    if (schedule == null) return null;
    try {
      return _shifts.firstWhere((s) => s.id == schedule.shiftId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('yyyy年M月').format(_currentMonth);
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = firstDay.weekday % 7; // 0 = Sunday

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMonth),
            Text(monthLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _goToToday,
            child: const Text('今天', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Weekday headers
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['日', '一', '二', '三', '四', '五', '六'].map((d) {
                final isWeekend = d == '日' || d == '六';
                return SizedBox(
                  width: 48,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isWeekend ? Colors.red : Colors.grey[700],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // Calendar grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
              ),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstWeekday) {
                  return const SizedBox.shrink();
                }
                final day = index - firstWeekday + 1;
                final date = DateTime(_currentMonth.year, _currentMonth.month, day);
                final dateStr = DateFormat('yyyy-MM-dd').format(date);
                final schedule = _schedules[dateStr];
                final shift = _getShiftForSchedule(schedule);
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;
                final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

                return InkWell(
                  onTap: () => _onDateTap(date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isToday ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
                      color: shift != null ? Color(shift.colorValue).withOpacity(0.15) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isWeekend ? Colors.red : (isToday ? Theme.of(context).primaryColor : Colors.black87),
                            fontSize: 14,
                          ),
                        ),
                        if (shift != null) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(shift.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            shift.name,
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(shift.colorValue),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (schedule != null && schedule.isLeave) ...[
                          const SizedBox(height: 2),
                          Text(
                            schedule.leaveType ?? '休假',
                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom actions
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomAction(Icons.schedule, '循环排班', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoopSettingScreen()));
                    }),
                    _buildBottomAction(Icons.edit_calendar, '班次库', () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftLibraryScreen()));
                      _loadData();
                    }),
                    _buildBottomAction(Icons.bar_chart, '统计', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: const Color(0xFF1565C0)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF1565C0))),
          ],
        ),
      ),
    );
  }
}

// ===== Bottom Sheet: 班次选择 =====
class _ShiftPickerBottomSheet extends StatefulWidget {
  final List<Shift> shifts;
  final Schedule? existingSchedule;
  final DateTime date;

  const _ShiftPickerBottomSheet({
    required this.shifts,
    this.existingSchedule,
    required this.date,
  });

  @override
  State<_ShiftPickerBottomSheet> createState() => _ShiftPickerBottomSheetState();
}

class _ShiftPickerBottomSheetState extends State<_ShiftPickerBottomSheet> {
  int? _selectedShiftId;
  final _noteController = TextEditingController();
  bool _isLeave = false;
  String? _leaveType;

  @override
  void initState() {
    super.initState();
    if (widget.existingSchedule != null) {
      _selectedShiftId = widget.existingSchedule!.shiftId;
      _noteController.text = widget.existingSchedule!.note ?? '';
      _isLeave = widget.existingSchedule!.isLeave;
      _leaveType = widget.existingSchedule!.leaveType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('M月d日 EEEE', 'zh_CN').format(widget.date);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(dateLabel, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('选择班次', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.shifts.map((shift) {
                    final isSelected = _selectedShiftId == shift.id;
                    return ChoiceChip(
                      label: Text(shift.name),
                      selected: isSelected,
                      selectedColor: Color(shift.colorValue).withOpacity(0.3),
                      backgroundColor: Colors.grey[100],
                      labelStyle: TextStyle(
                        color: isSelected ? Color(shift.colorValue) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedShiftId = shift.id;
                          _isLeave = false;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // 休假选项
                Row(
                  children: [
                    Checkbox(
                      value: _isLeave,
                      onChanged: (v) {
                        setState(() {
                          _isLeave = v ?? false;
                          if (_isLeave) _selectedShiftId = null;
                        });
                      },
                    ),
                    const Text('标记为休假'),
                  ],
                ),
                if (_isLeave) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['年假', '病假', '事假', '调休'].map((type) {
                      final isSelected = _leaveType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _leaveType = type),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    hintText: '添加备忘...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (widget.existingSchedule != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, {'delete': true}),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('删除'),
                        ),
                      ),
                    if (widget.existingSchedule != null) const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'shiftId': _selectedShiftId,
                            'note': _noteController.text.trim(),
                            'isLeave': _isLeave,
                            'leaveType': _leaveType,
                          });
                        },
                        child: const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
