// import 'package:flutter/material.dart';

// class ChangePasswordDialog extends StatefulWidget {
//   const ChangePasswordDialog({super.key});

//   @override
//   State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
// }

// class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController oldPasswordController = TextEditingController();
//   final TextEditingController newPasswordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();

//   bool isLoading = false;

//   Future<void> _updatePassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     // 👇 Here you can call your API logic
//     await Future.delayed(const Duration(seconds: 2)); // simulate delay

//     setState(() => isLoading = false);

//     if (mounted) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Password updated successfully!")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Center(
//         child: Text(
//           "Change Password",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       content: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Old password
//               TextFormField(
//                 controller: oldPasswordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: "Old Password *",
//                   hintText: "Enter your old password",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => value!.isEmpty ? "Enter old password" : null,
//               ),
//               const SizedBox(height: 12),

//               // New password
//               TextFormField(
//                 controller: newPasswordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: "New Password *",
//                   hintText: "Enter new password",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => value!.isEmpty ? "Enter new password" : null,
//               ),
//               const SizedBox(height: 12),

//               // Confirm password
//               TextFormField(
//                 controller: confirmPasswordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: "Confirm Password *",
//                   hintText: "Retype password",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) return "Confirm your password";
//                   if (value != newPasswordController.text) return "Passwords do not match";
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),

//               // Update button
//               SizedBox(
//                 width: double.infinity,
//                 height: 40,
//                 child: ElevatedButton.icon(
//                   onPressed: isLoading ? null : _updatePassword,
//                   icon: const Icon(Icons.update),
//                   label: isLoading
//                       ? const SizedBox(
//                           height: 16,
//                           width: 16,
//                           child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                         )
//                       : const Text("Update"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF346CB0),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  final Color _customBlue = const Color(0xFF346CB0);

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate API delay
    setState(() => isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully!")),
      );
    }
  }

  // 🔹 Text Field builder (same style as LateInEntry)
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 0.6,
              )),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            obscureText: true,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFCCCCCC)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFCCCCCC)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 2),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.only(top: 16, bottom: 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Center(
        child: Text(
          "Change Password",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _customBlue,
          ),
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                label: "Old Password *",
                controller: oldPasswordController,
                hint: "Enter your old password",
                validator: (value) =>
                    value!.isEmpty ? "Enter old password" : null,
              ),
              _buildTextField(
                label: "New Password *",
                controller: newPasswordController,
                hint: "Enter new password",
                validator: (value) =>
                    value!.isEmpty ? "Enter new password" : null,
              ),
              _buildTextField(
                label: "Confirm Password *",
                controller: confirmPasswordController,
                hint: "Retype password",
                validator: (value) {
                  if (value!.isEmpty) return "Confirm your password";
                  if (value != newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

           
        Center(
  child: ElevatedButton.icon(
    onPressed: isLoading ? null : _updatePassword,
    icon: isLoading
        ? const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Icon(
            Icons.update,
            size: 16, // slightly smaller
            color: Colors.white, // ✅ icon is now white
          ),
    label: Text(
      isLoading ? "Updating..." : "Update",
      style: const TextStyle(fontSize: 12.5, color: Colors.white), // slightly smaller text
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: _customBlue,
      padding:
          const EdgeInsets.symmetric(horizontal: 28, vertical: 10), // ✅ smaller button
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}