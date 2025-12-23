import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTrainerScreen extends StatefulWidget {
  const AddTrainerScreen({super.key});

  @override
  State<AddTrainerScreen> createState() => _AddTrainerScreenState();
}

class _AddTrainerScreenState extends State<AddTrainerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  String _selectedStatus = 'pending';
  bool _isLoading = false;
  final List<String> _specialties = [
    'Yoga Instructor',
    'Personal Trainer',
    'Strength Coach',
    'HIIT Coach',
    'Pilates Instructor',
    'CrossFit Coach',
    'Nutritionist',
    'Cardio Specialist',
  ];

  Future<void> _addTrainer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse(
        'https://prakrutitech.xyz/vani/insert_trainers.php',
      );
      final response = await http.post(
        url,
        body: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'specialty': _specialtyController.text.trim(),
          'experience': _experienceController.text.trim(),
          'status': _selectedStatus,
        },
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      final result = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Operation completed')),
      );
      if (result['status'] == 'success') {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add trainer')));
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
            textCapitalization: TextCapitalization.words,
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
                "Add Trainer",
                style: TextStyle(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 4 * scale),

              Text(
                "Create a new trainer profile",
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
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),

                      _field(
                        label: "Email",
                        controller: _emailController,
                        hint: "trainer@example.com",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),

                      _field(
                        label: "Phone Number",
                        controller: _phoneController,
                        hint: "9999999999",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 16 * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Specialty",
                              style: TextStyle(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 6 * scale),
                            DropdownButtonFormField<String>(
                              value: _specialtyController.text.isEmpty
                                  ? null
                                  : _specialtyController.text,
                              decoration: _cleanDecoration(
                                "Select specialty",
                                Icons.local_offer_outlined,
                              ),
                              items: _specialties
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _specialtyController.text = value!;
                                });
                              },
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),

                      _field(
                        label: "Experience (years)",
                        controller: _experienceController,
                        hint: "5",
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        suffixText: "years",
                        validator: (v) => v!.isEmpty ? 'Required' : null,
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
                                  value: 'pending',
                                  child: Text('Pending'),
                                ),
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
                          onPressed: _addTrainer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14 * scale),
                            ),
                          ),
                          child: Text(
                            "Add Trainer",
                            style: TextStyle(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
