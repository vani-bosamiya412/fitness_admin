import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'nutrition_management_screen.dart';

class EditNutritionScreen extends StatefulWidget {
  final Nutrition plan;

  const EditNutritionScreen({super.key, required this.plan});

  @override
  State<EditNutritionScreen> createState() => _EditNutritionScreenState();
}

class _EditNutritionScreenState extends State<EditNutritionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _description;
  late TextEditingController _calories;
  late TextEditingController _protein;
  late TextEditingController _carbs;
  late TextEditingController _fat;
  late TextEditingController _duration;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.plan.title);
    _description = TextEditingController(text: widget.plan.description);
    _calories = TextEditingController(text: widget.plan.calories.toString());
    _protein = TextEditingController(text: widget.plan.protein.toString());
    _carbs = TextEditingController(text: widget.plan.carbs.toString());
    _fat = TextEditingController(text: widget.plan.fat.toString());
    _duration = TextEditingController(
      text: widget.plan.durationDays.toString(),
    );
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/vani/update_nutrition.php"),
        body: {
          "id": widget.plan.id.toString(),
          "title": _title.text,
          "description": _description.text,
          "calories": _calories.text,
          "protein": _protein.text,
          "carbs": _carbs.text,
          "fat": _fat.text,
          "duration_days": _duration.text,
        },
      );
      if (!mounted) return;
      final data = json.decode(response.body);
      if (data["status"] == "success") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Nutrition plan updated!')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update plan")));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update plan")));
    }
  }

  Widget _label(String text, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * scale),
      child: Text(
        text,
        style: TextStyle(fontSize: 13 * scale, fontWeight: FontWeight.w600),
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Delete Nutrition Plan?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete this nutrition plan?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await _deleteNutrition();
    }
  }

  Future<void> _deleteNutrition() async {
    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/vani/delete_nutrition.php"),
        body: {"id": widget.plan.id.toString()},
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nutrition deleted successfully")),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Delete failed")),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error. Try again.")),
      );
    }
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
                        "Edit Nutrition Plan",
                        style: TextStyle(
                          fontSize: 22 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        "Update nutrition plan details",
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
                      _field(
                        _title,
                        "e.g., High Protein Diet",
                        Icons.text_fields,
                        scale,
                      ),

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

                      _unitField(_fat, "Fat", "g", Icons.opacity, scale),

                      SizedBox(height: 20 * scale),

                      _label("Duration in Days", scale),
                      _unitField(
                        _duration,
                        "30",
                        "days",
                        Icons.calendar_today,
                        scale,
                      ),
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
                    colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _update,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12 * scale),

              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: Icon(Icons.delete_outline, size: 18 * scale),
                label: Text(
                  "Delete Plan",
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 48 * scale),
                  side: BorderSide(color: Colors.red.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16 * scale),
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
