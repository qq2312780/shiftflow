import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../database/db_helper.dart';
import '../models/shift.dart';

class ShiftLibraryScreen extends StatefulWidget {
  const ShiftLibraryScreen({super.key});

  @override
  State<ShiftLibraryScreen> createState() => _ShiftLibraryScreenState();
}

class _ShiftLibraryScreenState extends State<ShiftLibraryScreen> {
  List<Shift> _shifts = [];

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    final shifts = await DBHelper.instance.getAllShifts();
    if (mounted) setState(() => _shifts = shifts);
  }

  Future<void> _showShiftEditor({Shift? shift}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ShiftEditorDialog(shift: shift),
    );

    if (result != null) {
      if (shift != null) {
        await DBHelper.instance.updateShift(
          shift.copyWith(
            name: result['name'],
            startTime: result['startTime'],
            endTime: result['endTime'],
            colorValue: result['colorValue'],
            hourlyRate: result['hourlyRate'],
            overtimeRate: result['overtimeRate'],
          ),
        );
      } else {
        await DBHelper.instance.insertShift(Shift(
          name: result['name'],
          startTime: result['startTime'],
          endTime: result['endTime'],
          colorValue: result['colorValue'],
          hourlyRate: result['hourlyRate'],
          overtimeRate: result['overtimeRate'],
        ));
      }
      _loadShifts();
    }
  }

  Future<void> _deleteShift(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除班次后，已排班的记录会保留但显示为未知班次。确定删除吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );

    if (confirmed == true) {
      await DBHelper.instance.deleteShift(id);
      _loadShifts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('班次库'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _shifts.length,
        itemBuilder: (context, index) {
          final shift = _shifts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(shift.colorValue),
                child: const SizedBox(width: 16, height: 16),
              ),
              title: Text(shift.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${shift.startTime} - ${shift.endTime} \u00b7 \uffe5${shift.hourlyRate}/小时'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showShiftEditor(shift: shift),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _deleteShift(shift.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showShiftEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ShiftEditorDialog extends StatefulWidget {
  final Shift? shift;
  const _ShiftEditorDialog({this.shift});

  @override
  State<_ShiftEditorDialog> createState() => _ShiftEditorDialogState();
}

class _ShiftEditorDialogState extends State<_ShiftEditorDialog> {
  final _nameController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _rateController = TextEditingController();
  final _otController = TextEditingController();
  Color _color = Colors.blue;

  @override
  void initState() {
    super.initState();
    if (widget.shift != null) {
      _nameController.text = widget.shift!.name;
      _startController.text = widget.shift!.startTime;
      _endController.text = widget.shift!.endTime;
      _rateController.text = widget.shift!.hourlyRate.toString();
      _otController.text = widget.shift!.overtimeRate?.toString() ?? '';
      _color = Color(widget.shift!.colorValue);
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final parts = controller.text.isNotEmpty
        ? controller.text.split(':').map(int.parse).toList()
        : [9, 0];
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: parts[0], minute: parts[1]),
    );
    if (time != null) {
      controller.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.shift == null ? '新增班次' : '编辑班次'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '班次名称')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startController,
                    decoration: const InputDecoration(labelText: '开始时间'),
                    readOnly: true,
                    onTap: () => _pickTime(_startController),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _endController,
                    decoration: const InputDecoration(labelText: '结束时间'),
                    readOnly: true,
                    onTap: () => _pickTime(_endController),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    decoration: const InputDecoration(labelText: '时薪'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _otController,
                    decoration: const InputDecoration(labelText: '加班倍率'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('选择颜色', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                const Color(0xFF1565C0), Colors.green, Colors.orange, Colors.red,
                Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
              ].map((c) {
                final isSelected = _color.value == c.value;
                return InkWell(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'name': _nameController.text.trim(),
              'startTime': _startController.text,
              'endTime': _endController.text,
              'colorValue': _color.value,
              'hourlyRate': double.tryParse(_rateController.text) ?? 20.0,
              'overtimeRate': _otController.text.isEmpty ? null : double.tryParse(_otController.text),
            });
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
