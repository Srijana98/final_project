import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

class SubstituteLeavePage extends StatefulWidget {
  @override
  _SubstituteLeavePageState createState() => _SubstituteLeavePageState();
}

class _SubstituteLeavePageState extends State<SubstituteLeavePage> {
  List<LeaveEntry> leaveEntries = [LeaveEntry()];
  TextEditingController remarksController = TextEditingController();
  TextEditingController totalDaysController = TextEditingController();

  void _addNewEntry() {
    setState(() {
      leaveEntries.add(LeaveEntry());
    });
  }

  void _removeEntry(int index) {
    setState(() {
      leaveEntries.removeAt(index);
    });
  }

  Future<void> _selectDate(int index, bool isDutyDate) async {
    final entry = leaveEntries[index];
    final isBS = isDutyDate ? entry.dutyIsBS : entry.leaveIsBS;

    if (isBS) {
      final picked = await showNepaliDatePicker(
        context: context,
        initialDate: NepaliDateTime.now(),
        firstDate: NepaliDateTime(2000),
        lastDate: NepaliDateTime(2090),
      );
      if (picked != null) {
        setState(() {
          if (isDutyDate) {
            entry.dutyDate = picked;
          } else {
            entry.leaveDate = picked;
          }
        });
      }
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          if (isDutyDate) {
            entry.dutyDate = picked;
          } else {
            entry.leaveDate = picked;
          }
        });
      }
    }
  }

  String _formatDate(dynamic date, bool isBS) {
    if (date == null) return '';
    if (isBS) {
      NepaliDateTime nepaliDate = date is NepaliDateTime ? date : NepaliDateTime.fromDateTime(date);
      return NepaliDateFormat('yyyy-MM-dd').format(nepaliDate);
    } else {
      DateTime englishDate = date is DateTime ? date : date.toDateTime();
      return DateFormat('yyyy-MM-dd').format(englishDate);
    }
  }

  Widget _datePickerWidget({
    required dynamic date,
    required bool isBS,
    required VoidCallback onTap,
    required VoidCallback toggleCalendar,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              _formatDate(date, isBS),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: toggleCalendar,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF346CB0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isBS ? 'BS' : 'AD',
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _tableCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF346CB0),
        centerTitle: true,
        title: const Text("Substitute Leave Deposit", style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Days", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: totalDaysController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      border: TableBorder.all(color: Colors.grey.shade400),
                      columnWidths: const {
                        0: FixedColumnWidth(40),
                        1: FixedColumnWidth(160),
                        2: FixedColumnWidth(100),
                        3: FixedColumnWidth(100),
                        4: FixedColumnWidth(160),
                        5: FixedColumnWidth(200),
                        6: FixedColumnWidth(40),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.blue.shade50),
                          children: [
                            _tableHeader("S.N"),
                            _tableHeader("Select Duty Date"),
                            _tableHeader("Half Duty"),
                            _tableHeader("Apply Leave"),
                            _tableHeader("Select Leave Date"),
                            _tableHeader("Remarks"),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: _addNewEntry,
                                tooltip: "Add Row",
                              ),
                            ),
                          ],
                        ),
                        ...leaveEntries.asMap().entries.map((entry) {
                          int index = entry.key;
                          LeaveEntry item = entry.value;

                          return TableRow(
                            children: [
                              _tableCell(Text('${index + 1}')),
                              _tableCell(
                                _datePickerWidget(
                                  date: item.dutyDate,
                                  isBS: item.dutyIsBS,
                                  onTap: () => _selectDate(index, true),
                                  toggleCalendar: () {
                                    setState(() {
                                      item.dutyIsBS = !item.dutyIsBS;
                                      if (item.dutyDate != null) {
                                        item.dutyDate = item.dutyIsBS
                                            ? NepaliDateTime.fromDateTime(
                                                item.dutyDate is DateTime
                                                    ? item.dutyDate
                                                    : item.dutyDate.toDateTime())
                                            : item.dutyDate is NepaliDateTime
                                                ? item.dutyDate.toDateTime()
                                                : item.dutyDate;
                                      }
                                    });
                                  },
                                ),
                              ),
                              _tableCell(Switch(
                                value: item.isHalfDuty,
                                onChanged: (val) => setState(() => item.isHalfDuty = val),
                                activeColor: Color(0xFF346CB0),
                              )),
                              _tableCell(Switch(
                                value: item.isApplyLeave,
                                onChanged: (val) => setState(() => item.isApplyLeave = val),
                                activeColor: Color(0xFF346CB0),
                              )),
                              _tableCell(
                                _datePickerWidget(
                                  date: item.leaveDate,
                                  isBS: item.leaveIsBS,
                                  onTap: () => _selectDate(index, false),
                                  toggleCalendar: () {
                                    setState(() {
                                      item.leaveIsBS = !item.leaveIsBS;
                                      if (item.leaveDate != null) {
                                        item.leaveDate = item.leaveIsBS
                                            ? NepaliDateTime.fromDateTime(
                                                item.leaveDate is DateTime
                                                    ? item.leaveDate
                                                    : item.leaveDate.toDateTime())
                                            : item.leaveDate is NepaliDateTime
                                                ? item.leaveDate.toDateTime()
                                                : item.leaveDate;
                                      }
                                    });
                                  },
                                ),
                              ),
                              _tableCell(TextField(
                                controller: item.remarksController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                ),
                              )),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeEntry(index),
                                  tooltip: "Remove Row",
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh, color: Color(0xFF346CB0)),
                label: const Text("Re-verify Attendance & Overtime", style: TextStyle(color: Color(0xFF346CB0))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF346CB0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  // TODO: Add your logic
                },
              ),
              const SizedBox(height: 16),
              const Text("Remarks", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: remarksController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text("Save and Continue", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        // TODO: Save and Continue logic
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text("Save and Close", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF346CB0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        // TODO: Save and Close logic
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaveEntry {
  dynamic dutyDate;
  dynamic leaveDate;
  bool isHalfDuty = false;
  bool isApplyLeave = false;
  bool dutyIsBS = true;
  bool leaveIsBS = true;
  TextEditingController remarksController = TextEditingController();
}

