import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddNutritionScreen extends StatefulWidget {
  const AddNutritionScreen({super.key});

  @override
  State<AddNutritionScreen> createState() => _AddNutritionScreenState();
}

class _AddNutritionScreenState extends State<AddNutritionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  final _duration = TextEditingController();

  List<Map<String, dynamic>> users = [];
  int? selectedNutritionistId;
  bool loadingUsers = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/vani/insert_nutrition.php"),
        body: {
          "title": _title.text,
          "description": _description.text,
          "calories": _calories.text,
          "protein": _protein.text,
          "carbs": _carbs.text,
          "fat": _fat.text,
          "duration_days": _duration.text,
        },
      );
      final data = json.decode(response.body);
      if (!mounted) return;
      if (data["status"] == "success") {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Nutrition plan added successfully!')),
        );
        navigator.pop(true);
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Failed to add plan")),
        );
      }
    } catch (_) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Failed to add plan")),
      );
    }
  }

  Widget _label(String text, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * scale),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13 * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController controller,
      String hint,
      IconData icon,
      double scale, {
        int maxLines = 1,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18 * scale),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFA353FF)),
          borderRadius: BorderRadius.circular(14 * scale),
        ),
      ),
    );
  }

  Widget _unitField(
      TextEditingController controller,
      String hint,
      String unit,
      IconData icon,
      double scale,
      ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18 * scale),
        suffixText: unit,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFA353FF)),
          borderRadius: BorderRadius.circular(14 * scale),
        ),
      ),
    );
  }

  Future<void> fetchUsers() async {
    try {
      final res = await http.get(
        Uri.parse("https://prakrutitech.xyz/vani/view_user.php"),
      );

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);

        users = data.map<Map<String, dynamic>>((u) {
          return {
            "id": int.parse(u['id'].toString()),
            "name": u['name'] ?? 'User',
            "email": u['email'] ?? '',
          };
        }).toList();
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => loadingUsers = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
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
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add Nutrition Plan",
                        style: TextStyle(
                          fontSize: 22 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        "Create a new nutrition program",
                        style: TextStyle(
                          fontSize: 14 * scale,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20 * scale),

              Container(
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16 * scale),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nutrition Plan Details",
                        style: TextStyle(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 16 * scale),

                      _label("Plan Title", scale),
                      _field(_title, "e.g., High Protein Diet",
                          Icons.text_fields, scale),

                      SizedBox(height: 16 * scale),

                      _label("Description", scale),
                      _field(
                        _description,
                        "Describe the nutrition plan and its benefits...",
                        Icons.description_outlined,
                        scale,
                        maxLines: 3,
                      ),

                      SizedBox(height: 20 * scale),

                      _label("Daily Macronutrients", scale),

                      SizedBox(height: 12 * scale),

                      _unitField(
                        _calories,
                        "Total Calories",
                        "kcal",
                        Icons.local_fire_department,
                        scale,
                      ),

                      SizedBox(height: 12 * scale),

                      Row(
                        children: [
                          Expanded(
                            child: _unitField(
                              _protein,
                              "Protein",
                              "g",
                              Icons.fitness_center,
                              scale,
                            ),
                          ),
                          SizedBox(width: 12 * scale),
                          Expanded(
                            child: _unitField(
                              _carbs,
                              "Carbs",
                              "g",
                              Icons.grain,
                              scale,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12 * scale),

                      _unitField(
                        _fat,
                        "Fat",
                        "g",
                        Icons.opacity,
                        scale,
                      ),

                      SizedBox(height: 20 * scale),

                      _label("Meals Per Day", scale),
                      _unitField(
                        _duration,
                        "30",
                        "meals per day",
                        Icons.calendar_today,
                        scale,
                      ),

                      SizedBox(height: 20 * scale),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24 * scale),

              Container(
                width: double.infinity,
                height: 52 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14 * scale),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF9333EA),
                    ],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    "Add Nutrition Plan",
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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