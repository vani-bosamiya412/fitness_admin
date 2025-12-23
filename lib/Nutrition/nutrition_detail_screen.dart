import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'edit_nutrition_screen.dart';
import 'nutrition_management_screen.dart';

class NutritionDetailScreen extends StatefulWidget {
  final int nutritionId;

  const NutritionDetailScreen({super.key, required this.nutritionId});

  @override
  State<NutritionDetailScreen> createState() => _NutritionDetailScreenState();
}

class _NutritionDetailScreenState extends State<NutritionDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? nutrition;
  final String apiUrl = "https://prakrutitech.xyz/vani/view_nutrition.php";

  @override
  void initState() {
    super.initState();
    fetchNutritionDetail();
  }

  Future<void> fetchNutritionDetail() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          final selected = data.firstWhere(
                (item) => item['id'].toString() == widget.nutritionId.toString(),
            orElse: () => {},
          );
          if (selected.isNotEmpty) {
            setState(() {
              nutrition = selected;
              isLoading = false;
            });
          } else {
            setState(() => isLoading = false);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Nutrition plan not found")),
            );
          }
        } else {
          setState(() => isLoading = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid response format")),
          );
        }
      } else {
        setState(() => isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load nutrition details")),
        );
      }
    } catch (_) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load nutrition details")),
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
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(color: Color(0xFFA353FF)),
        )
            : nutrition == null
            ? Center(child: Text("No data found"))
            : SingleChildScrollView(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 4 * scale),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nutrition Plan Details",
                        style: TextStyle(
                          fontSize: 22 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        "View nutrition plan information",
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

              _titleCard(scale),

              SizedBox(height: 16 * scale),

              _sectionCard(
                title: "Description",
                icon: Icons.description_outlined,
                child: Text(
                  nutrition!['description'] ??
                      "No description available",
                  style: TextStyle(
                    fontSize: 14 * scale,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                scale: scale,
              ),

              SizedBox(height: 20 * scale),

              Container(
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16 * scale),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily Macronutrients",
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 14 * scale),

                    _macroTile(
                      "Total Calories",
                      "${nutrition!['calories']} kcal",
                      Icons.local_fire_department,
                      Color(0xfffff3e0),
                      Colors.orange,
                      scale,
                    ),
                    _macroTile(
                      "Protein",
                      "${nutrition!['protein']}g",
                      Icons.fitness_center,
                      Color(0xffffebee),
                      Colors.red,
                      scale,
                    ),
                    _macroTile(
                      "Carbohydrates",
                      "${nutrition!['carbs']}g",
                      Icons.grain,
                      Color(0xfffffde7),
                      Colors.amber,
                      scale,
                    ),
                    _macroTile(
                      "Fat",
                      "${nutrition!['fat']}g",
                      Icons.opacity,
                      Color(0xffe3f2fd),
                      Colors.blue,
                      scale,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20 * scale),

              _sectionCard(
                title: "Plan Information",
                icon: Icons.info_outline,
                scale: scale,
                child: Column(
                  children: [
                    _infoRow(
                      Icons.calendar_today,
                      "Duration",
                      "${nutrition!['duration_days']} days",
                      scale,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24 * scale),

              Container(
                width: double.infinity,
                height: 50 * scale,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3B5BFF),
                      Color(0xFF8F2CFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16 * scale),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditNutritionScreen(
                          plan: Nutrition.fromJson(nutrition!),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  label: Text(
                    "Edit Nutrition Plan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15 * scale,
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

  Widget _titleCard(double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Row(
        children: [
          Container(
            height: 46 * scale,
            width: 46 * scale,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Icon(Icons.apple, color: Colors.white),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nutrition!['title'],
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 4 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Weight Loss",
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20 * scale),
              SizedBox(width: 8 * scale),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          child,
        ],
      ),
    );
  }

  Widget _macroTile(
      String label,
      String value,
      IconData icon,
      Color bg,
      Color iconColor,
      double scale,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 10 * scale),
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Row(
        children: [
          Container(
            height: 36 * scale,
            width: 36 * scale,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(icon, color: Colors.white, size: 18 * scale),
          ),
          SizedBox(width: 12 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13 * scale, color: Colors.black54),
              ),
              SizedBox(height: 2 * scale),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      IconData icon,
      String label,
      String value,
      double scale,
      ) {
    return Row(
      children: [
        Icon(icon, size: 18 * scale, color: Colors.grey),
        SizedBox(width: 10 * scale),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14 * scale, color: Colors.grey),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}