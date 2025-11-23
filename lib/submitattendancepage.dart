
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class SubmitAttendancePage extends StatefulWidget {
  const SubmitAttendancePage({super.key});

  @override
  State<SubmitAttendancePage> createState() => _SubmitAttendancePageState();
}

class _SubmitAttendancePageState extends State<SubmitAttendancePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String _attendanceType = 'check_in';
  bool _obscurePassword = true;

  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  bool _hasInternetConnection = true;
  bool _locationServiceDisabled = false;
  bool _locationPermissionDenied = false;

  Position? _currentPosition;
  String _currentAddress = "Fetching location...";
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _initializeConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      if (mounted) _handleConnectivityChange(result);
      _connectivitySubscription =
          Connectivity().onConnectivityChanged.listen((res) {
        if (mounted) _handleConnectivityChange(res);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasInternetConnection = false;
        });
      }
    }
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    setState(() {
      _hasInternetConnection = result != ConnectivityResult.none;
      if (_hasInternetConnection) _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationServiceDisabled = false;
      _locationPermissionDenied = false;
    });

    if (!_hasInternetConnection) {
      setState(() {
        _isLoadingLocation = false;
        _currentAddress = "Waiting for internet connection...";
      });
      return;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationServiceDisabled = true;
          _currentAddress = "Location services disabled.";
          _isLoadingLocation = false;
        });
        return;
      }

      final status = await Permission.location.request();
      if (!status.isGranted) {
        setState(() {
          _locationPermissionDenied = true;
          _currentAddress = "Location permission denied.";
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(const Duration(seconds: 15));

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _currentAddress = address;
          _currentPosition = position;
          _isLoadingLocation = false;
        });
      }
    } on TimeoutException {
      setState(() {
        _currentAddress = "Location request timed out.";
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Error: ${e.toString()}";
        _isLoadingLocation = false;
      });
    }
  }

  
Future<void> _submitAttendance() async {
  if (!_formKey.currentState!.validate()) return;

  if (_currentPosition == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location not available. Please refresh location'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  final url = Uri.parse('$baseUrl/api/authenticate_user_for_attendance');

  final payload = {
    "email": _emailController.text.trim(),
    "password": _passwordController.text,
    "att_type": _attendanceType == 'check_in' ? "CHECKIN" : "CHECKOUT",
    "remarks": _remarksController.text,
    "gps_latitude": _currentPosition!.latitude.toString(),
    "gps_longitude": _currentPosition!.longitude.toString(),
    "address": _currentAddress,
  };

  try {
    final response = await http
        .post(url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload))
        .timeout(const Duration(seconds: 20));

    setState(() {
      _isSubmitting = false;
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance submitted successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // ✅ Fix for: List<dynamic> is not a subtype of String
      String errorMsg = "Attendance failed.";
      final message = data["message"];

      if (message != null) {
        if (message is String) {
          errorMsg = message;
        } else if (message is List) {
          errorMsg = message.map((e) => e.toString()).join(', ');
        } else {
          errorMsg = message.toString();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    setState(() {
      _isSubmitting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error submitting attendance: ${e.toString()}"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Widget _buildWarningBanner(String message) {
    return Container(
      width: double.infinity,
      color: Colors.red,
      padding: const EdgeInsets.all(10),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF346CB0);
    const borderColor = Color(0xFFCCCCCC);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mobile Attendance',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        

                        // Location Field
                        TextFormField(
                          readOnly: true,
                          controller:
                              TextEditingController(text: _currentAddress),
                              maxLines: 2, // <-- Allow up to 2 lines
                             minLines: 1,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.location_on,
                                color: primaryColor),
                            suffixIcon: _isLoadingLocation
                                ? const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.refresh,
                                        color: primaryColor),
                                    onPressed: _getCurrentLocation,
                                  ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 9),
                                isDense: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: primaryColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        
 //Email
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon:
                            const Icon(Icons.email, color: primaryColor),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 9),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(fontSize: 13),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon:
                            const Icon(Icons.lock, color: primaryColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 9),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Attendance Type:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: RadioListTile<String>(
                            title: const Text('Check In',
                                style: TextStyle(fontSize: 13)),
                            value: 'check_in',
                            groupValue: _attendanceType,
                            onChanged: (value) {
                              setState(() {
                                _attendanceType = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            activeColor: primaryColor,
                          ),
                        ),
                        Flexible(
                          child: RadioListTile<String>(
                            title: const Text('Check Out',
                                style: TextStyle(fontSize: 13)),
                            value: 'check_out',
                            groupValue: _attendanceType,
                            onChanged: (value) {
                              setState(() {
                                _attendanceType = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            activeColor: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                     // Remarks
                    TextFormField(
                      controller: _remarksController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        labelText: 'Remarks',
                        labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                        floatingLabelStyle: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        contentPadding:
                            const EdgeInsets.fromLTRB(12, 18, 12, 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                        // Submit Button
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 180,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitAttendance,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2)
                                  : const Text(
                                      'Submit Attendance',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!_hasInternetConnection)
                _buildWarningBanner(
                    "No internet connection. Please check your connection."),
              if (_locationServiceDisabled)
                _buildWarningBanner(
                    "Location services are disabled. Please enable them."),
              if (_locationPermissionDenied)
                _buildWarningBanner(
                    "Location permission denied. Please grant from settings."),
            ],
          ),
        ],
      ),
    );
  }
}
