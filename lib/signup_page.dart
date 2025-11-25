// import 'package:flutter/material.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final _formKey = GlobalKey<FormState>();

//   String? _fullName;
//   String? _phoneNumber;
//   String? _email;
//   String? _password;
//   String? _confirmPassword;

//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue[50],
//       body: Stack(
//         children: [
//           // Blue Curved Background
//           CustomPaint(
//             size: Size(MediaQuery.of(context).size.width, 180),
//             painter: CurvedPainter(),
//           ),
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 const SizedBox(height: 40),
//                 // Logo
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white,
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(50),
//                     child: Image.asset(
//                       'assets/logo1.png',
//                       height: 80,
//                       width: 80,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 40), // adjust as needed
//                   child: const Text(
//                     'Sign Up',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF346CB0),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // White Form Box
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Container(
//                     padding: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.2),
//                           blurRadius: 4,
//                           spreadRadius: 1,
//                         ),
//                       ],
//                     ),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           // Full Name
//                           TextFormField(
//                             keyboardType: TextInputType.name,
//                             decoration: const InputDecoration(
//                               prefixIcon: Icon(Icons.person),
//                               hintText: 'Full Name',
//                               border: OutlineInputBorder(),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter full name';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) => _fullName = value,
//                           ),
//                           const SizedBox(height: 15),

//                           // Phone Number
//                           TextFormField(
//                             keyboardType: TextInputType.phone,
//                             decoration: const InputDecoration(
//                               prefixIcon: Icon(Icons.phone),
//                               hintText: 'Phone Number',
//                               border: OutlineInputBorder(),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter phone number';
//                               }
//                               if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
//                                 return 'Enter a valid phone number';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) => _phoneNumber = value,
//                           ),
//                           const SizedBox(height: 15),

//                           // Email
//                           TextFormField(
//                             keyboardType: TextInputType.emailAddress,
//                             decoration: const InputDecoration(
//                               prefixIcon: Icon(Icons.email),
//                               hintText: 'Email',
//                               border: OutlineInputBorder(),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter email';
//                               }
//                               if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
//                                 return 'Enter a valid email';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) => _email = value,
//                           ),
//                           const SizedBox(height: 15),

//                           // Password
//                           TextFormField(
//                             obscureText: !_isPasswordVisible,
//                             decoration: InputDecoration(
//                               prefixIcon: const Icon(Icons.lock),
//                               hintText: 'Password',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _isPasswordVisible
//                                       ? Icons.visibility
//                                       : Icons.visibility_off,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _isPasswordVisible = !_isPasswordVisible;
//                                   });
//                                 },
//                               ),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter password';
//                               }
//                               if (value.length < 6) {
//                                 return 'Password must be at least 6 characters';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) => _password = value,
//                           ),
//                           const SizedBox(height: 15),

//                           // Confirm Password
//                           TextFormField(
//                             obscureText: !_isConfirmPasswordVisible,
//                             decoration: InputDecoration(
//                               prefixIcon: const Icon(Icons.lock),
//                               hintText: 'Confirm Password',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _isConfirmPasswordVisible
//                                       ? Icons.visibility
//                                       : Icons.visibility_off,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _isConfirmPasswordVisible =
//                                         !_isConfirmPasswordVisible;
//                                   });
//                                 },
//                               ),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please confirm password';
//                               }
//                               if (value != _password) {
//                                 return 'Passwords do not match';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) => _confirmPassword = value,
//                           ),
//                           const SizedBox(height: 30),

//                           // Sign Up Button
//                           ElevatedButton(
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 _formKey.currentState!.save();
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Signing up...'),
//                                   ),
//                                 );
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF346CB0),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 100,
//                                 vertical: 15,
//                               ),
//                             ),
//                             child: const Text(
//                               'Sign Up',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),

//                           // Login Redirect
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.pushNamed(context, '/login');
//                             },
//                             child: const Text(
//                               "Already have an account? Log in",
//                               style: TextStyle(color: Colors.blue),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Blue Curved Background
// class CurvedPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint =
//         Paint()
//           ..color = const Color(0xFF346CB0)
//           ..style = PaintingStyle.fill;

//     Path path =
//         Path()
//           ..lineTo(0, size.height)
//           ..quadraticBezierTo(
//             size.width / 2,
//             size.height - 30,
//             size.width,
//             size.height,
//           )
//           ..lineTo(size.width, 0)
//           ..close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  String? _fullName;
  String? _phoneNumber;
  String? _email;
  String? _password;
  String? _confirmPassword;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Stack(
        children: [
          // Blue Curved Background
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 180),
            painter: CurvedPainter(),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60), // increased top margin
                // Logo
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      'assets/logo1.png',
                      height: 120, // increased size
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Sign Up Text
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF346CB0),
                  ),
                ),
                const SizedBox(height: 20),

                // White Form Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Full Name
                          TextFormField(
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: 'Full Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter full name';
                              }
                              return null;
                            },
                            onSaved: (value) => _fullName = value,
                          ),
                          const SizedBox(height: 15),

                          // Phone Number
                          TextFormField(
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phone),
                              hintText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                            onSaved: (value) => _phoneNumber = value,
                          ),
                          const SizedBox(height: 15),

                          // Email
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            onSaved: (value) => _email = value,
                          ),
                          const SizedBox(height: 15),

                          // Password
                          TextFormField(
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onSaved: (value) => _password = value,
                          ),
                          const SizedBox(height: 15),

                          // Confirm Password
                          TextFormField(
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              hintText: 'Confirm Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm password';
                              }
                              if (value != _password) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            onSaved: (value) => _confirmPassword = value,
                          ),
                          const SizedBox(height: 30),

                          // Sign Up Button
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Signing up...'),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF346CB0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 100,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Login Redirect
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              "Already have an account? Log in",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Blue Curved Background
class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = const Color(0xFF346CB0)
          ..style = PaintingStyle.fill;

    Path path =
        Path()
          ..lineTo(0, size.height)
          ..quadraticBezierTo(
            size.width / 2,
            size.height - 30,
            size.width,
            size.height,
          )
          ..lineTo(size.width, 0)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
