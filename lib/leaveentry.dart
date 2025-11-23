import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leave Request',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      home: const LeaveRequestPage(),
    );
  }
}

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _daysController = TextEditingController(text: '1');
  final TextEditingController _remainingController = TextEditingController();

  bool _startIsBS = true;
  bool _endIsBS = true;
  bool _halfLeave = false;
  bool _sameDate = false;
  String? _selectedSubstitute;
  String? _pickedFileName;
  String? _halfLeaveType;
  bool _isProgrammaticUpdate = false;

  final Color _customBlue = const Color(0xFF346CB0);

  // API data
  List<Map<String, dynamic>> leaveQuota = [];
  List<Map<String, dynamic>> substitutes = [];
  bool isLoading = true;

  // Headers from SharedPreferences
  Map<String, String> headers = {};

  // Selection & editable days
  Set<String> _selectedLeaveIds = {};
  Map<String, TextEditingController> _daysControllers = {};

  @override
  void initState() {
    super.initState();
    _loadHeadersAndFetch();
  }

  @override
  void dispose() {
    _daysControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _loadHeadersAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final empId = prefs.getString('employee_id') ?? '';
    final orgId = prefs.getString('org_id') ?? '';
    final locationId = prefs.getString('location_id') ?? '';
    final token = prefs.getString('token') ?? '';

    setState(() {
      headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'empid': empId,
        'orgid': orgId,
        'locationid': locationId,
        'date_type': _startIsBS ? 'NP' : 'EN',
      };
    });

    fetchLeaveData();
  }

  Future<void> fetchLeaveData() async {
    final url = Uri.parse('$baseUrl/api/v1/default_leave_form');

    try {
      final response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          leaveQuota = List.from(json['data']['leaveQuotaRecord']);
          substitutes = List.from(json['data']['substitute_employee']);
          isLoading = false;
          _initDaysControllers();
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

void _initDaysControllers() {
  _daysControllers.clear();
  for (var i = 0; i < leaveQuota.length; i++) {
    final item = leaveQuota[i];
    // use leave_catid from API if available, otherwise fallback to index
    final id = (item['leave_catid'] ?? i).toString();
    _daysControllers[id] = TextEditingController(text: '');
  }
}


  /// Date Picker
  Future<void> _selectDate(TextEditingController controller, bool isStartDate) async {
    final isBS = isStartDate ? _startIsBS : _endIsBS;
    if (isBS) {
      final picked = await showNepaliDatePicker(
        context: context,
        initialDate: NepaliDateTime.now(),
        firstDate: NepaliDateTime(2000),
        lastDate: NepaliDateTime(2090),
      );
      if (picked != null) {
        controller.text = NepaliDateFormat('yyyy/MM/dd').format(picked);
        if (_sameDate && isStartDate) _endDateController.text = controller.text;
        _updateDays();
      }
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        controller.text = DateFormat('yyyy/MM/dd').format(picked);
        if (_sameDate && isStartDate) _endDateController.text = controller.text;
        _updateDays();
      }
    }
  }

  void _updateDays() {
    if (_halfLeave) return;
    if (_startDateController.text.isNotEmpty && _endDateController.text.isNotEmpty) {
      try {
        DateTime start = DateFormat('yyyy/MM/dd').parse(_startDateController.text);
        DateTime end = DateFormat('yyyy/MM/dd').parse(_endDateController.text);
        int difference = end.difference(start).inDays + 1;
        if (difference < 0) difference = 0;
        setState(() {
          _daysController.text = difference.toString();
        });
      } catch (_) {}
    }
  }

Widget _buildDateField(TextEditingController controller, bool isStartDate) {
  return SizedBox(
    width: 130, // adjust width as needed
    child: TextField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6), // 🔹 match Days field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 30,
          minHeight: 30, // 🔹 make sure icon fits without stretching field
        ),
        suffixIcon: TextButton(
          onPressed: () {
            setState(() {
              if (isStartDate) {
                _startIsBS = !_startIsBS;
              } else {
                _endIsBS = !_endIsBS;
              }
            });
            _selectDate(controller, isStartDate);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // 🔹 remove extra padding
            minimumSize: const Size(20, 20), // 🔹 match height
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            isStartDate ? (_startIsBS ? "NP" : "EN") : (_endIsBS ? "NP" : "EN"),
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ),
      onTap: () => _selectDate(controller, isStartDate),
    ),
  );
}





/// Row Widget
Widget _buildRow(String label, Widget field, {double spacing = 4.0}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: spacing),
    child: Row(
      crossAxisAlignment:CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        
        Flexible(child: field),
      ],
    ),
  );
}

  /// File Picker
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _pickedFileName = result.files.single.name;
      });
    }
  }

  void _showNoDaysDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("demo.smarthajiri.com says"),
        content: const Text("No leave days remaining"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Leave Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: _customBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
          Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Row(
    children: [
      SizedBox(
        width: 150,
        child: Text("Start Date:",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
     

      SizedBox(
  //width: 130,
   width: 150,

  child: _buildDateField(_startDateController, true),
),

    ],
  ),
),

          

  Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Row(
    children: [
      const SizedBox(
        width: 60,
        child: Text(
          "End Date:",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),

      Checkbox(
        value: _sameDate,
        activeColor: _customBlue,
        onChanged: (val) {
          setState(() {
            _sameDate = val!;
            if (_sameDate) {
              _endDateController.text = _startDateController.text;
              _endIsBS = _startIsBS;
              _updateDays();
            }
          });
        },
      ),

      const Text("Same Date", style: TextStyle(fontSize: 12)),
      const SizedBox(width: 6),

      


Expanded(
  child: _buildDateField(_endDateController, false),
),

    ],
  ),
),
const SizedBox(height: 6),

          Row(
  children: [
    const Text('Half Leave:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    const SizedBox(width: 10),
    

    Switch(
  value: _halfLeave,
  activeColor: _customBlue,
  onChanged: (value) {
    setState(() {
      _halfLeave = value;

      if (value) {
        _daysController.text = '0.5';
        _remainingController.text = '0.5';  // 🔥 ADD THIS
      } else {
        _updateDays();
        _halfLeaveType = null;
        _remainingController.text = '';    // 🔥 ADD THIS
      }
    });
  },
),

    const SizedBox(width: 10),

    // Make dropdown flexible instead of fixed width
    if (_halfLeave)
      Flexible(
        child: DropdownButtonFormField<String>(
          value: _halfLeaveType,
          hint: const Text('--Select Leave--'),
          items: const [
            DropdownMenuItem(value: 'First Half', child: Text('First Half')),
            DropdownMenuItem(value: 'Second Half', child: Text('Second Half')),
          ],
          onChanged: (value) => setState(() => _halfLeaveType = value),
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          ),
        ),
      ),


     
  ],
),

            // Days
            _buildRow(
              'Days:',
              SizedBox(
 // width: 55, // smaller width
 width: 50,
  child: TextFormField(
    controller: _daysController,
    readOnly: true,
    style: TextStyle(fontSize: 12), // smaller text
    decoration: const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4), // smaller height
      border: OutlineInputBorder(),
    ),
  ),
),
spacing: 2,
            ),

            const SizedBox(height: 10),
            const Text('Select Leave Category:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),





// Dynamic Table with Checkbox + Editable Days + Highlight
isLoading
    ? const Center(child: CircularProgressIndicator())
    : Table(
        border: TableBorder.all(
          color: Colors.grey.shade700, // darker grey border
          width: 1.0,
        ),
        columnWidths: const {
          0: FlexColumnWidth(2.5),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1),
        },
        children: [
          

          TableRow(
         
           decoration: const BoxDecoration(color: Color(0xFF346CB0)), // blue

            children: const [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Balance',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Days',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),


...leaveQuota.asMap().entries.map((entry) {
  final index = entry.key;
  final item = entry.value;
  final id = (item['leave_catid'] ?? index).toString();
  final bool isSelected = _selectedLeaveIds.contains(id);

  return TableRow(
    children: [
    Container(
        color: isSelected ? _customBlue.withOpacity(0.1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              activeColor: _customBlue,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              



// onChanged: (bool? val) {
//   double diffDays = double.tryParse(_daysController.text) ?? 0;

//   if (val == true) {
//     // Auto-fill days but disallow more than total difference
//     double required = diffDays;

//     if (required > diffDays) {
//       _showNoDaysDialog();
//       return;
//     }

//     setState(() {
//       _selectedLeaveIds.add(id);
//       _daysControllers[id]?.text = required.toString();
//     });
//   } else {
//     setState(() {
//       _selectedLeaveIds.remove(id);
//       _daysControllers[id]?.text = '';
//     });
//   }
// },


onChanged: (bool? val) {
  double diffDays = double.tryParse(_daysController.text) ?? 0;

  if (val == true) {
    _isProgrammaticUpdate = true;

    _selectedLeaveIds.add(id);
    _daysControllers[id]?.text = diffDays.toString();

    Future.delayed(Duration(milliseconds: 50), () {
      _isProgrammaticUpdate = false;
    });
  } else {
    _isProgrammaticUpdate = true;

    _selectedLeaveIds.remove(id);
    _daysControllers[id]?.text = '';

    Future.delayed(Duration(milliseconds: 50), () {
      _isProgrammaticUpdate = false;
    });
  }

  setState(() {});
},







            ),
            Expanded(
              child: Text(
                item['leavecategory'] ?? '',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),

      // BALANCE COLUMN
      Container(
        color: isSelected ? _customBlue.withOpacity(0.1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Text(
          item['BL'] ?? '0.00',
          style: const TextStyle(fontSize: 13),
        ),
      ),

      // DAYS COLUMN
      Container(
        color: isSelected ? _customBlue.withOpacity(0.1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: isSelected
            ? SizedBox(
                width: 50,
                child: TextFormField(
                  controller: _daysControllers[id],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                 // onChanged: (v) {},

//                  onChanged: (value) {
//   double diffDays = double.tryParse(_daysController.text) ?? 0;
//   double entered = double.tryParse(value) ?? 0;

//   if (entered > diffDays) {
//     _showNoDaysDialog();

//     // reset to max allowed
//     _daysControllers[id]?.text = diffDays.toString();
//   }
// },

onChanged: (value) {
  if (_isProgrammaticUpdate) return;

  double diffDays = double.tryParse(_daysController.text) ?? 0;
  double entered = double.tryParse(value) ?? 0;

  if (entered > diffDays) {
    _showNoDaysDialog();

    _isProgrammaticUpdate = true;
    _daysControllers[id]?.text = diffDays.toString();

    Future.delayed(Duration(milliseconds: 50), () {
      _isProgrammaticUpdate = false;
    });
  }
},





                ),
              )
            : const SizedBox.shrink(),
      ),
    ],
  );
}).toList(),

        ],
      ),
const SizedBox(height: 10),

//             // Remaining Leave
            _buildRow(
              'Remaining Leave:',
              

              SizedBox(
  //width: 55, // match Days width
  width: 50,
  child: TextFormField(
    controller: _remainingController,
    style: TextStyle(fontSize: 12),
    decoration: const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4), // smaller height
      border: OutlineInputBorder(),
    ),
  ),
),

              spacing: 2,
            ),

            const SizedBox(height: 10),
           

            _buildRow(
  'Attachments:',
  Row(
    children: [
     




ElevatedButton(
  onPressed: _pickFile,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF346CB0), // button background
    foregroundColor: Colors.white,             // text color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4), // small radius
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  ),
  child: const Text('Choose File', style: TextStyle(fontSize: 12)),
),


      const SizedBox(width: 8),
      if (_pickedFileName != null)
        Expanded(
          child: Text(
            _pickedFileName!,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ],
  ),
  spacing: 2,
),


            const SizedBox(height: 10),
            



_buildRow(
  'Substitute Employee:',
  SizedBox(
    // remove fixed width
    child: DropdownButtonFormField<String>(
      value: _selectedSubstitute,
      hint: const Text('--Select--'),
      isExpanded: true, // allow field to take remaining space
      items: substitutes
          .map((e) => DropdownMenuItem(
                value: e['id'].toString(),
                child: Text(
                  '${e['empcode']} - ${e['full_name']}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedSubstitute = value),
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 6, // same vertical padding as Start Date
          horizontal: 6, // same horizontal padding
        ),
      ),
    ),
  ),
  spacing: 2,
),



            const SizedBox(height: 10),
            _buildRow(
              'Leave Reason:',
              TextFormField(
                maxLines: 2,
                decoration: const InputDecoration(
                  isDense: true,
                 border: OutlineInputBorder(),
                  
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                ),
              ),
              spacing: 2,
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final selected = leaveQuota.where((item) {
                      final id = item['id'].toString();
                      return _selectedLeaveIds.contains(id) &&
                             (_daysControllers[id]?.text.isNotEmpty ?? false) &&
                             double.tryParse(_daysControllers[id]!.text)! > 0;
                    }).map((item) {
                      final id = item['id'].toString();
                      return {
                        'leave_category_id': id,
                        'days': _daysControllers[id]!.text,
                      };
                    }).toList();
                    print('Selected Leaves: $selected');
                    // TODO: Send to API
                  },
                  icon: const Icon(Icons.save, color: Colors.white, size: 18),
                  label: const Text('Save & Continue', style: TextStyle(color: Colors.white, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                   // fixedSize: const Size(150, 40), 
                    fixedSize: const Size(145, 38), 
                   
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Same logic as above
                  },
                  icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 18),
                  label: const Text('Save & Close', style: TextStyle(color: Colors.white, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  
                    fixedSize: const Size(145, 38), 
                   
                  ),
                ),],
            ),
          ],
        ),
      ),
    );
  }
}