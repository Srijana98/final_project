import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'workonholiday.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'dart:convert';



class WorkOnHolidayHistoryModel {
  final String? refNo;
  final String? purpose;
  final String? fromDateBs;
  final String? toDateBs;
  

  WorkOnHolidayHistoryModel({
    this.refNo,
    this.purpose,
    this.fromDateBs,
    this.toDateBs,
   
  });

  factory WorkOnHolidayHistoryModel.fromJson(Map<String, dynamic> json) {
    return WorkOnHolidayHistoryModel(
      refNo: json['refno'],
      purpose: json['purpose'],
      fromDateBs: json['from_datebs'],
      toDateBs: json['to_datebs'],
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refno': refNo,
      'purpose': purpose,
      'from_datebs': fromDateBs,
      'to_datebs': toDateBs,
      
    };
  }
}

class WorkonHolidayHistoryPage extends StatefulWidget {
  @override
  State<WorkonHolidayHistoryPage> createState() => _WorkonHolidayHistoryPageState();
}

class _WorkonHolidayHistoryPageState extends State<WorkonHolidayHistoryPage> {
  final List<String> tabs = [ 'Pending', 'Approved', 'Review', 'Cancel'];
  DateTime? _fromDate;
  DateTime? _toDate;

  Map<String, List<WorkOnHolidayHistoryModel>> statusWiseHistory = {
  'Pending': [],
  'Approved': [],
  'Review': [],
  'Cancel': [],
};

bool isLoading = true;




Future<void> fetchWorkOnHolidayHistory() async {
  setState(() {
    isLoading = true;
  });

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? empid = prefs.getString('empid');
    // String? orgid = prefs.getString('orgid');
    // String? locationid = prefs.getString('locationid');

   String? empid = prefs.getString('employee_id');
   String? orgid = prefs.getString('org_id');
   String? locationid = prefs.getString('location_id');


    if (empid == null || orgid == null || locationid == null) {
      throw Exception("Missing employee information. Please log in again.");
    }

    final url = Uri.parse('$baseUrl/api/v1/work_from_home?entry_type=WORKFROMHOLI');

    final headers = {
      'empid': empid,
      'orgid': orgid,
      'locationid': locationid,
    };

    debugPrint('Request URL: $url');
    debugPrint('Request Headers: $headers');

    final response = await http.get(url, headers: headers);

    debugPrint('Response Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        

        if (data['status'] == 'success') {
          final Map<String, dynamic> rawHistory = data['data']['statusWiseHistory']['Pending'];

          final Map<String, List<WorkOnHolidayHistoryModel>> parsedHistory = {};

          rawHistory.forEach((key, value) {
            parsedHistory[key] = List<WorkOnHolidayHistoryModel>.from(
              value.map((item) => WorkOnHolidayHistoryModel.fromJson(item)),
            );
          });

          setState(() {
            statusWiseHistory = parsedHistory;
          });
        } else {
          debugPrint('API returned failure: ${data['message']}');
        }
      } catch (e) {
        debugPrint('JSON decode error: $e');
        debugPrint('Response body: ${response.body}');
      }
    } else {
      debugPrint('Request failed with status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
    }
  } catch (e) {
    debugPrint("Error fetching data: $e");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}



  @override
  void initState() {
    super.initState();
    fetchWorkOnHolidayHistory();
  }


  Future<void> _selectDate(bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('yyyy/MM/dd').format(date) : '';
  }
///Widget buildCardItem(Map<String, dynamic> item, String tab, int index) {
  Widget buildCardItem(WorkOnHolidayHistoryModel item, String tab, int index) {

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFF346CB0)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Text(
  'Ref. No: ${item.refNo ?? 'N/A'}',
  style: const TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(height: 4),
Text('Purpose: ${item.purpose ?? 'N/A'}'),
Text('Duration: ${item.fromDateBs ?? ''} - ${item.toDateBs ?? ''}'),

          const SizedBox(height: 8),

          // Show buttons only in Pending tab
          if (tab == 'Pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 30,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      // Navigate to update form
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkonHolidayEntryPage(
                            // if your WorkFromHomeEntryPage supports editing, pass item
                          ),
                        ),
                      );
                      fetchWorkOnHolidayHistory();
                    },

                    

                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Update', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 30,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              "HRMS says,",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            content: const Text("Are you sure you want to cancel the record?"),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel",
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF346CB0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  // Call your cancel API function here
                                  // e.g., await cancelWorkFromHome(item['id'], index);
                                },
                                child: const Text(
                                  "OK",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete, size: 14),
                    label: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF346CB0),
          elevation: 0,
          title: const Text(
            "Work On Holiday History",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: 130,
              color: const Color(0xFF346CB0),
            ),
            Column(
              children: [
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, color: Color(0xFF346CB0)),
                                        const SizedBox(width: 8),
                                        Text(
                                          _fromDate != null ? _formatDate(_fromDate) : 'From',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, color: Color(0xFF346CB0)),
                                        const SizedBox(width: 8),
                                        Text(
                                          _toDate != null ? _formatDate(_toDate) : 'To',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF346CB0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // Add filter logic if needed
                              },
                              child: const Text(
                                'Filter',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  isScrollable: true,
                  indicatorColor: const Color(0xFF346CB0),
                  labelColor: const Color(0xFF346CB0),
                  unselectedLabelColor: Colors.grey,labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: tabs.map((tab) {
                      return Center(
                        child: Text(
                          'No $tab records',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => WorkonHolidayEntryPage()),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Request Work on Holiday", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF346CB0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}