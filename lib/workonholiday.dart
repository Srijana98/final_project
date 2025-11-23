import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workonholidayhistory.dart';

class WorkonHolidayEntryPage extends StatefulWidget {
   final Map<String, dynamic>? existingData;
  const WorkonHolidayEntryPage({super.key, this.existingData});

  @override
  State<WorkonHolidayEntryPage> createState() => _WorkonHolidayEntryPageState();
}

class _WorkonHolidayEntryPageState extends State<WorkonHolidayEntryPage> {
  final Color _customBlue = const Color(0xFF346CB0);
  final String _entryType = 'WORKFROMHOLI';

  late TextEditingController _fromDateController;
  late TextEditingController _toDateController;
  late TextEditingController _purposeController;

  bool _fromIsBS = true;
  bool _toIsBS = true;

  List<PlatformFile> _attachments = [];

  // Holiday API Data
  List<Holiday> _holidays = [];
  Holiday? _selectedHoliday;

  @override
  void initState() {
    super.initState();
    _fromDateController = TextEditingController();
    _toDateController = TextEditingController();
    _purposeController = TextEditingController();

    _fetchHolidays();
    
    
    
     
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  // Fetch holidays from API
  Future<void> _fetchHolidays() async {
    const url = '${baseUrl}/api/v1/employee/holidays';
    final headers = {
      'empid': '1', // Replace with dynamic empid
      'orgid': '1', // Replace with dynamic orgid
      'locationid': '1',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List holidaysJson = data['holidays'];
          setState(() {
            _holidays = holidaysJson.map((e) => Holiday.fromJson(e)).toList();
          });
        }
      } else {
        print('Failed to load holidays: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching holidays: $e');
    }
  }

  // Date Picker (BS/AD)
  Future<void> _selectDate(TextEditingController controller, bool isFrom) async {
    final isBS = isFrom ? _fromIsBS : _toIsBS;
    if (isBS) {
      final picked = await showNepaliDatePicker(
        context: context,
        initialDate: NepaliDateTime.now(),
        firstDate: NepaliDateTime(2000),
        lastDate: NepaliDateTime(2090),
      );
      if (picked != null) {
        controller.text =
            '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
      }
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2023),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        controller.text = DateFormat('yyyy/MM/dd').format(picked);
      }
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() => _attachments.addAll(result.files));
    }
  }

  Widget _buildRow(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13, height: 0.6)),
          const SizedBox(height: 4),
          field,
        ],
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, bool isFrom) {
    final isBS = isFrom ? _fromIsBS : _toIsBS;
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _selectDate(controller, isFrom),
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF346CB0), width: 2),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isFrom) _fromIsBS = !_fromIsBS;
                else _toIsBS = !_toIsBS;
              });
              _selectDate(controller, isFrom);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _customBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(isBS ? 'BS' : 'AD',
                  style: const TextStyle(fontSize: 10, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurposeField() {
    return TextField(
      controller: _purposeController,
      maxLines: 4,
      style: const TextStyle(fontSize: 13),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        isDense: true,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCCCCCC)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCCCCCC)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF346CB0), width: 2),
        ),
      ),
    );
  }

  
  Widget _buildHolidayDropdown() {
  return DropdownButtonFormField<Holiday>(
    value: _selectedHoliday,
    hint: const Text('--Select--'),
    isExpanded: true, // ✅ allows text to use full width
    items: _holidays
        .map((h) => DropdownMenuItem(
              value: h,
              child: Text(
                '${h.eventname} (${h.startDateBS} to ${h.endDateBS})',
                overflow: TextOverflow.ellipsis, // ✅ prevents overflow
                maxLines: 1,
              ),
            ))
        .toList(),
    onChanged: (Holiday? value) {
      setState(() {
        _selectedHoliday = value;
        _fromDateController.text = value?.startDateBS ?? '';
        _toDateController.text = value?.endDateBS ?? '';
      });
    },
    decoration: const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      border: UnderlineInputBorder(),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFCCCCCC)),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 2),
      ),
    ),
  );
}


  Widget _buildAttachmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: _pickFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: _customBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Choose File', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _attachments.isEmpty
                    ? 'No file selected'
                    : '${_attachments.length} file(s) selected',
                style: const TextStyle(fontSize: 13, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 8),
          ..._attachments.map(
            (file) => ListTile(
              dense: true,
              leading:
                  const Icon(Icons.description, size: 20, color: Color(0xFF346CB0)),
              title: Text(file.name,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                onPressed: () => setState(() => _attachments.remove(file)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  
  Future<void> _submitWorkonHoliday() async {
  const String url = 'https://demo.smarthajiri.com/api/v1/work_from_home/store';

  // if (_fromDateController.text.isEmpty ||
  //     _toDateController.text.isEmpty ||
  //     _purposeController.text.isEmpty) {
  if (_fromDateController.text.isEmpty ||
    _toDateController.text.isEmpty ||
    _purposeController.text.isEmpty ||
    _selectedHoliday == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Please fill all required fields'),
      backgroundColor: Colors.red,
    ));
    return;
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final empid = prefs.getString('empid') ?? '1';
    final orgid = prefs.getString('orgid') ?? '1';
    final locationid = prefs.getString('locationid') ?? '1';

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll({
      'empid': empid,
      'orgid': orgid,
      'locationid': locationid,
    });

    request.fields['empid'] = empid;
    request.fields['orgid'] = orgid;
    request.fields['locationid'] = locationid;
   // request.fields['holiday_id'] = _entryType;
   request.fields['holiday_id'] = _selectedHoliday?.id ?? '';

    request.fields['entry_type'] = _entryType;
    request.fields['from_date'] = _fromDateController.text.trim();
    request.fields['to_date'] = _toDateController.text.trim();
    request.fields['purpose'] = _purposeController.text.trim();

    
    if (_attachments.isNotEmpty && _attachments.first.path != null) {
  request.files.add(await http.MultipartFile.fromPath(
    'attachment', // ✅ remove the []
    _attachments.first.path!,
  ));
}


    // 🧾 Log all outgoing request details
    print('📡 ====== API REQUEST ======');
    print('➡️ URL: $url');
    print('🧩 Headers: ${request.headers}');
    print('📦 Fields: ${request.fields}');
    print('📎 Files: ${_attachments.map((f) => f.name).toList()}');
    print('===========================');

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    final result = json.decode(responseBody);

    // 🧾 Log the full response
    print('✅ ====== API RESPONSE ======');
    print('🔢 Status Code: ${response.statusCode}');
    print('💬 Response Body: $responseBody');
    print('=============================');

    if (response.statusCode == 200 && result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Work on Holiday request submitted successfully!'),
        backgroundColor: _customBlue,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Failed: ${result['message'] ?? 'Something went wrong'}'),
        backgroundColor: Colors.red,
      ));
    }
  } catch (e) {
    print('❌ ERROR during request: $e'); // also log error in console
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error: $e'),
      backgroundColor: Colors.red,
    ));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _customBlue,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Work On Holiday Entry",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildRow('Holiday:', _buildHolidayDropdown()),
            _buildRow('From Date:', _buildDateField(_fromDateController, true)),
            _buildRow('To Date:', _buildDateField(_toDateController, false)),
            _buildRow('Purpose:', _buildPurposeField()),
            const SizedBox(height: 16),
            _buildRow('Attachment:', _buildAttachmentField()),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submitWorkonHoliday,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _customBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model for Holiday
 class Holiday {
 final String id;
 final String eventname;
 final String startDateBS;
 final String endDateBS;

 Holiday({
required this.id,
  required this.eventname,
  required this.startDateBS,
  required this.endDateBS,
 });

 factory Holiday.fromJson(Map<String, dynamic> json) {
 return Holiday(
 id: json['id'],
 eventname: json['eventname'],
  startDateBS: json['start_datebs'],
  endDateBS: json['end_datebs'],
   );
  }
}


