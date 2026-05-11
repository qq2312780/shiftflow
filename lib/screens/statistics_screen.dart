import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/shift.dart';
import '../models/schedule.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _month = DateTime.now();
  List<Shift> _shifts = [];
  List<Schedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final shifts = await DBHelper.instance.getAllShifts();
    final start = DateFormat('yyyy-MM-dd').format(DateTime(_month.year, _month.month, 1));
    final end = DateFormat('yyyy-MM-dd').format(DateTime(_month.year, _month.month + 1, 0));
    final schedules = await DBHelper.instance.getSchedulesByDateRange(start, end);

    if (mounted) {
      setState(() {
        _shifts = shifts;
        _schedules = schedules;
      });
    }
  }

  void _prevMonth() {
    setState(() => _month = DateTime(_month.year, _month.month - 1, 1));
    _loadData();
  }

  void _nextMonth() {
    setState(() => _month = DateTime(_month.year, _month.month + 1, 1));
    _loadData();
  }

  Map<int, int> _getShiftCounts() {
    final counts = <int, int>{};
    for (final s in _schedules.where((s) => !s.isLeave)) {
      counts[s.shiftId] = (counts[s.shiftId] ?? 0) + 1;
    }
    return counts;
  }

  double _getTotalHours() {
    double total = 0;
    for (final s in _schedules.where((s) => !s.isLeave)) {
      final shift = _shifts.firstWhere((sh) => sh.id == s.shiftId, orElse: () => _shifts.first);
      total += shift.hours;
    }
    return total;
  }

  double _getEstimatedSalary() {
    double total = 0;
    for (final s in _schedules.where((s) => !s.isLeave)) {
      final shift = _shifts.firstWhere((sh) => sh.id == s.shiftId, orElse: () => _shifts.first);
      total += shift.hours * shift.hourlyRate;
    }
    return total;
  }

  int _getLeaveDays() {
    return _schedules.where((s) => s.isLeave).length;
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('yyyy年M月').format(_month);
    final totalHours = _getTotalHours();
    final salary = _getEstimatedSalary();
    final leaveDays = _getLeaveDays();
    final shiftCounts = _getShiftCounts();

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: [
                _buildSummaryCard('总工时', '${totalHours.toStringAsFixed(1)}h', Icons.timer, Colors.blue),
                const SizedBox(width: 12),
                _buildSummaryCard('预估薪资', '¥${salary.toStringAsFixed(0)}', Icons.attach_money, Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryCard('排班天数', '${_schedules.where((s) => !s.isLeave).length}天', Icons.calendar_today, Colors.orange),
                const SizedBox(width: 12),
                _buildSummaryCard('休假天数', '${leaveDays}天', Icons.beach_access, Colors.grey),
              ],
            ),
            const SizedBox(height: 24),
            const Text('班次分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._shifts.map((shift) {
              final count = shiftCounts[shift.id] ?? 0;
              final percentage = _schedules.where((s) => !s.isLeave).isEmpty
                  ? 0.0
                  : count / _schedules.where((s) => !s.isLeave).length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: Color(shift.colorValue), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    SizedBox(width: 60, child: Text(shift.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(Color(shift.colorValue)),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(width: 40, child: Text('${count}天', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            const Text('每日明细', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._schedules.map((s) {
              final shift = _shifts.firstWhere((sh) => sh.id == s.shiftId, orElse: () => _shifts.first);
              final day = DateFormat('M/d EEEE', 'zh_CN').format(DateTime.parse(s.date));
              return ListTile(
                dense: true,
                leading: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: Color(shift.colorValue), shape: BoxShape.circle),
                ),
                title: Text('$day ${shift.name}'),
                subtitle: s.note != null && s.note!.isNotEmpty ? Text(s.note!, style: TextStyle(fontSize: 12, color: Colors.grey[500])) : null,
                trailing: s.isLeave
                    ? Text(s.leaveType ?? '休假', style: TextStyle(fontSize: 12, color: Colors.grey[500]))
                    : Text('${shift.hours.toStringAsFixed(1)}h', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
