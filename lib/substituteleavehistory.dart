import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dashboardpage.dart';
import 'substituteleaveentry.dart';

class SubstituteHistoryPage extends StatefulWidget {
  @override
  State<SubstituteHistoryPage> createState() => _SubstituteHistoryPageState();
}

class _SubstituteHistoryPageState extends State<SubstituteHistoryPage> {
  final List<String> tabs = ['All', 'Pending', 'Review', 'Approved', 'Rejected'];
  DateTime? _fromDate;
  DateTime? _toDate;

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
    return date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
  }

  Widget buildDateField(DateTime? date, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.black87, size: 18),
          const SizedBox(width: 8),
          Text(date != null ? _formatDate(date) : hint, style: const TextStyle(fontSize: 14)),
        ],
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
            "Substitute Leave Deposit History",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DashboardPage()),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            Container(height: 130, color: const Color(0xFF346CB0)),
            Column(
              children: [
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                                  child: buildDateField(_fromDate, 'From'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(false),
                                  child: buildDateField(_toDate, 'To'),
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                // Filtering logic placeholder
                                setState(() {});
                              },
                              child: const Text(
                                'Filter',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: tabs.map((tab) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        itemCount: 2, // you can increase or decrease as needed
                        itemBuilder: (context, index) {
                          
                        },
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
            
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubstituteLeavePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Request Substitute Leave Entry", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF346CB0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
