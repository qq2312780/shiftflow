import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/shift.dart';
import '../models/schedule.dart';

class LoopSettingScreen extends StatefulWidget {
  const LoopSettingScreen({super.key});

  @override
  State<LoopSettingScreen> createState() => _LoopSettingScreenState();
}

class _LoopSettingScreenState extends State<LoopSettingScreen> {
  List<Shift> _shifts = [];
  DateTime _startDate = DateTime.now();
  int _loopDays = 7; // 循环周期天数
  List<int?> _pattern = []; // 每天的班次ID，null表示休息
  int _generateMonths = 3; // 生成未来几个月

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    final shifts = await DBHelper.instance.getAllShifts();
    if (mounted) {
      setState(() {
        _shifts = shifts;
        if (_pattern.isEmpty) {
          _pattern = List.filled(_loopDays, null);
        }
      });
    }
  }

  Future<void> _generateSchedule() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认生成'),
        content: Text(
          '将根据 $_loopDays 天循环模板，从 ${DateFormat('yyyy-MM-dd').format(_startDate)} 开始，'
          '生成未来 $_generateMonths 个月的排班。\n\n这会覆盖已存在的排班，确定吗？',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('生成')),
        ],
      ),
    );

    if (confirmed != true) return;

    final endDate = DateTime(_startDate.year, _startDate.month + _generateMonths, _startDate.day);
    final totalDays = endDate.difference(_startDate).inDays;
    int generated = 0;

    for (int i = 0; i < totalDays; i++) {
      final date = _startDate.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final patternIndex = i % _loopDays;
      final shiftId = _pattern[patternIndex];

      // 删除已存在的排班
      final existing = await DBHelper.instance.getScheduleByDate(dateStr);
      if (existing != null) {
        await DBHelper.instance.deleteSchedule(existing.id!);
      }

      if (shiftId != null) {
        await DBHelper.instance.insertSchedule(Schedule(
          date: dateStr,
          shiftId: shiftId,
        ));
        generated++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已生成 $generated 天排班')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('循环排班'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 开始日期
            ListTile(
              title: const Text('开始日期'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (picked != null) {
                  setState(() => _startDate = picked);
                }
              },
            ),
            const Divider(),
            // 循环周期
            ListTile(
              title: const Text('循环周期'),
              subtitle: Text('$_loopDays 天为一个循环'),
              trailing: SizedBox(
                width: 120,
                child: Slider(
                  value: _loopDays.toDouble(),
                  min: 2,
                  max: 14,
                  divisions: 12,
                  label: '$_loopDays 天',
                  onChanged: (v) {
                    setState(() {
                      _loopDays = v.round();
                      if (_pattern.length > _loopDays) {
                        _pattern = _pattern.sublist(0, _loopDays);
                      } else if (_pattern.length < _loopDays) {
                        _pattern.addAll(List.filled(_loopDays - _pattern.length, null));
                      }
                    });
                  },
                ),
              ),
            ),
            const Divider(),
            // 循环模板
            const Text('循环模板', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('点击每天选择班次，空白=休息', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_loopDays, (index) {
                final shiftId = _pattern[index];
                final shift = shiftId != null
                    ? _shifts.firstWhere((s) => s.id == shiftId, orElse: () => _shifts.first)
                    : null;
                return InkWell(
                  onTap: () => _showDayShiftPicker(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: shift != null ? Color(shift.colorValue) : Colors.grey[300]!),
                      color: shift != null ? Color(shift.colorValue).withOpacity(0.1) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('第${index + 1}天', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          shift?.name ?? '休息',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: shift != null ? Color(shift.colorValue) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const Divider(height: 32),
            // 生成时长
            ListTile(
              title: const Text('生成时长'),
              subtitle: Text('生成未来 $_generateMonths 个月'),
              trailing: SizedBox(
                width: 120,
                child: Slider(
                  value: _generateMonths.toDouble(),
                  min: 1,
                  max: 12,
                  divisions: 11,
                  label: '$_generateMonths 个月',
                  onChanged: (v) => setState(() => _generateMonths = v.round()),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _generateSchedule,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('一键生成排班', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDayShiftPicker(int dayIndex) async {
    final shiftId = await showModalBottomSheet<int?>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('第${dayIndex + 1}天', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.bed, color: Colors.grey),
                title: const Text('休息'),
                onTap: () => Navigator.pop(context, null),
              ),
              const Divider(),
              ..._shifts.map((shift) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(shift.colorValue),
                  radius: 12,
                ),
                title: Text(shift.name),
                subtitle: Text('${shift.startTime} - ${shift.endTime}'),
                onTap: () => Navigator.pop(context, shift.id),
              )),
            ],
          ),
        ),
      ),
    );

    if (shiftId != null || shiftId == null) {
      setState(() => _pattern[dayIndex] = shiftId);
    }
  }
}
