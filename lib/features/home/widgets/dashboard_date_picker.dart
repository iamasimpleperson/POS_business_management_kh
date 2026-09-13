import 'package:flutter/material.dart';

class DashboardDatePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const DashboardDatePickerWidget({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DashboardDatePickerWidget> createState() => _DashboardDatePickerWidgetState();
}

class _DashboardDatePickerWidgetState extends State<DashboardDatePickerWidget> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  final List<String> _khmerMonths = [
    'មករា', 'កុម្ភៈ', 'មីនា', 'មេសា', 'ឧសភា', 'មិថុនា',
    'កក្កដា', 'សីហា', 'កញ្ញា', 'តុលា', 'វិច្ឆិកា', 'ធ្នូ'
  ];

  String _formatDate(DateTime date) {
    return '${date.day} ${_khmerMonths[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Ensure the initial date has no time component
    DateTime safeInitialDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
    // Prevent the assertion error if safeInitialDate somehow became later than today
    if (safeInitialDate.isAfter(today)) {
      safeInitialDate = today;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: DateTime(2000),
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              _formatDate(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
