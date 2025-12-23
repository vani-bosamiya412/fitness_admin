import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'trainer_management_screen.dart';

class EditTrainerScreen extends StatefulWidget {
  final Trainer trainer;

  const EditTrainerScreen({super.key, required this.trainer});

  @override
  State<EditTrainerScreen> createState() => _EditTrainerScreenState();
}

class _EditTrainerScreenState extends State<EditTrainerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specialtyController;
  late TextEditingController _experienceController;
  late String _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final t = widget.trainer;
    _nameController = TextEditingController(text: t.name);
    _emailController = TextEditingController(text: t.email);
    _phoneController = TextEditingController(text: t.phone);
    _specialtyController = TextEditingController(text: t.specialty);
    _experienceController = TextEditingController(
      text: t.experience.toString(),
    );
    _selectedStatus = t.status;
  }

  Future<void> _updateTrainer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final infoUrl = Uri.parse(
        'https://prakrutitech.xyz/vani/update_trainers.php',
      );
      final statusUrl = Uri.parse(
        'https://prakrutitech.xyz/vani/update_trainer_status.php',
      );

      final infoResponse = await http.post(
        infoUrl,
        body: {
          'id': widget.trainer.id.toString(),
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'specialty': _specialtyController.text.trim(),
          'experience': _experienceController.text.trim(),
        },
      );
      final statusResponse = await http.post(
        statusUrl,
        body: {'id': widget.trainer.id.toString(), 'status': _selectedStatus},
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final infoResult = json.decode(infoResponse.body);
      final statusResult = json.decode(statusResponse.body);

      if (infoResult['status'] == 'success' ||
          statusResult['status'] == 'success') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Trainer updated successfully")));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update trainer")));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update trainer")));
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: _cleanDecoration(hint, icon, suffixText: suffixText),
          ),
        ],
      ),
    );
  }

  InputDecoration _cleanDecoration(
    String hint,
    IconData icon, {
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey),
      suffixText: suffixText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFA353FF)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 375;

    return Scaffold(
      backgroundColor: Color(0xfff4f5f7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Trainer",
                style: TextStyle(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 4 * scale),

              Text(
                "Update trainer profile",
                style: TextStyle(fontSize: 14 * scale, color: Colors.black54),
              ),

              SizedBox(height: 18 * scale),

              Container(
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withValues(alpha: 0.06),
                      blurRadius: 10 * scale,
                      offset: Offset(0, 5 * scale),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trainer Details",
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 16 * scale),

                      _field(
                        label: "Trainer Name",
                        controller: _nameController,
                        hint: "e.g., John Smith",
                        icon: Icons.person_outline,
                        validator: (v) =>
                            v!.isEmpty ? 'Please enter the trainer name' : null,
                      ),

                      _field(
                        label: "Email",
                        controller: _emailController,
                        hint: "trainer@example.com",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      _field(
                        label: "Phone Number",
                        controller: _phoneController,
                        hint: "9999999999",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      _field(
                        label: "Specialty",
                        controller: _specialtyController,
                        hint: "e.g., Personal Trainer",
                        icon: Icons.local_offer_outlined,
                      ),

                      _field(
                        label: "Experience (years)",
                        controller: _experienceController,
                        hint: "5",
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        suffixText: "years",
                      ),

                      SizedBox(height: 6 * scale),

                      Padding(
                        padding: EdgeInsets.only(bottom: 16 * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Status",
                              style: TextStyle(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 6 * scale),
                            DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: _cleanDecoration(
                                "Select status",
                                Icons.verified_outlined,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'approved',
                                  child: Text('Approved'),
                                ),
                                DropdownMenuItem(
                                  value: 'rejected',
                                  child: Text('Rejected'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedStatus = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24 * scale),

              SizedBox(
                width: double.infinity,
                height: 52 * scale,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff4a6cf7), Color(0xff9333ea)],
                          ),
                          borderRadius: BorderRadius.circular(14 * scale),
                        ),
                        child: ElevatedButton(
                          onPressed: _updateTrainer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14 * scale),
                            ),
                          ),
                          child: Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),

              SizedBox(height: 14 * scale),

              SizedBox(
                width: double.infinity,
                height: 50 * scale,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                    "Delete Trainer",
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
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
