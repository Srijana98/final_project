import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'dashboardpage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xelwel HR System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
      '/dashboard': (context) =>  DashboardPage(),
      },
    );
  }
}


// demogwt.smarthajiri.com
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Xelwel HR System',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.blue[50],
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         fontFamily: 'Roboto',
//       ),
//       // App will open directly with Smart Hajiri login page
//       home: const SmartHajiriWebView(),
//     );
//   }
// }

// class SmartHajiriWebView extends StatefulWidget {
//   const SmartHajiriWebView({super.key});

//   @override
//   State<SmartHajiriWebView> createState() => _SmartHajiriWebViewState();
// }

// class _SmartHajiriWebViewState extends State<SmartHajiriWebView> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(
//         Uri.parse("https://demogwt.smarthajiri.com"), // Your login page
//       );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Xelwel HR System"),
//         backgroundColor: Colors.blue,
//       ),
//       body: WebViewWidget(controller: _controller),
//     );
//   }
// }



// demo.smarthajiri.com
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Xelwel HR System',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.blue[50],
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         fontFamily: 'Roboto',
//       ),
//       // App will open directly with Smart Hajiri login page
//       home: const SmartHajiriWebView(),
//     );
//   }
// }

// class SmartHajiriWebView extends StatefulWidget {
//   const SmartHajiriWebView({super.key});

//   @override
//   State<SmartHajiriWebView> createState() => _SmartHajiriWebViewState();
// }

// class _SmartHajiriWebViewState extends State<SmartHajiriWebView> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(
//         Uri.parse("https://demo.smarthajiri.com"), // ✅ Correct URL
//       );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Xelwel HR System"),
//         backgroundColor: Colors.blue,
//       ),
//       body: WebViewWidget(controller: _controller),
//     );
//   }
// }
