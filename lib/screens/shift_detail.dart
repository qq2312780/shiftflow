import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/shift.dart';
import '../models/schedule.dart';

class ShiftDetailScreen extends StatefulWidget {
  final String date;
  final Schedule? schedule;

  const ShiftDetailScreen({super.key, required this.date, this.schedule});

  @override
  State<ShiftDetailScreen> createState() => _ShiftDetailScreenState();
}

class _ShiftDetailScreenState extends State<ShiftDetailScreen> {
  Shift? _shift;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.schedule != null) {
      final shift = await DBHelper.instance.getShiftById(widget.schedule!.shiftId);
      if (mounted) {
        setState(() {
          _shift = shift;
          _noteController.text = widget.schedule!.note ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.date), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_shift != null) ...[
              Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Color(_shift!.colorValue)),
                  title: Text(_shift!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${_shift!.startTime} - ${_shift!.endTime}'),
                  trailing: Text('${_shift!.hours.toStringAsFixed(1)}h'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (widget.schedule != null) {
                      await DBHelper.instance.updateSchedule(
                        widget.schedule!.copyWith(note: _noteController.text.trim()),
                      );
                    }
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('保存备注'),
                ),
              ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('暂无排班', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
