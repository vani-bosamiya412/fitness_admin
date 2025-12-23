import 'dart:convert';
import 'package:fitness_admin/Bottom_nav/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_nutrition_screen.dart';
import 'edit_nutrition_screen.dart';
import 'nutrition_detail_screen.dart';

class Nutrition {
  final int id;
  String title;
  String description;
  int calories;
  int protein;
  int carbs;
  int fat;
  int durationDays;

  Nutrition({
    required this.id,
    required this.title,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.durationDays,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      calories: int.tryParse(json['calories'].toString()) ?? 0,
      protein: int.tryParse(json['protein'].toString()) ?? 0,
      carbs: int.tryParse(json['carbs'].toString()) ?? 0,
      fat: int.tryParse(json['fat'].toString()) ?? 0,
      durationDays: int.tryParse(json['duration_days'].toString()) ?? 0,
    );
  }
}

class NutritionManagementScreen extends StatefulWidget {
  const NutritionManagementScreen({super.key});

  @override
  State<NutritionManagementScreen> createState() =>
      _NutritionManagementScreenState();
}

class _NutritionManagementScreenState extends State<NutritionManagementScreen> {
  List<Nutrition> nutritionList = [];
  bool isLoading = true;

  final String viewApiUrl = "https://prakrutitech.xyz/vani/view_nutrition.php";
  final String deleteApiUrl =
      "https://prakrutitech.xyz/vani/delete_nutrition.php";

  TextEditingController searchCtrl = TextEditingController();

  List<Nutrition> _filteredNutrition() {
    final query = searchCtrl.text.toLowerCase();

    if (query.isEmpty) return nutritionList;

    return nutritionList.where((n) {
      return n.title.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchNutritionPlans();
  }

  Future<void> fetchNutritionPlans() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(viewApiUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          nutritionList = data.map((item) => Nutrition.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load nutrition plans")),
        );
      }
    } catch (_) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load nutrition plans")));
    }
  }

  Future<void> _editNutrition(Nutrition plan) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditNutritionScreen(plan: plan)),
    );

    if (result == true) {
      fetchNutritionPlans();
    }
  }

  Future<void> _deleteNutrition(int id) async {
    try {
      final response = await http.post(
        Uri.parse(deleteApiUrl),
        body: {"id": id.toString()},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Nutrition deleted')),
        );
        fetchNutritionPlans();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete nutrition plan")),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete nutrition plan")),
      );
    }
  }

  Widget _macro(String label, String value, var scale) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildNutritionCard(
    BuildContext context,
    Nutrition plan,
    double scale,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16 * scale),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NutritionDetailScreen(nutritionId: plan.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16 * scale),
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withValues(alpha: 0.07),
              blurRadius: 10 * scale,
              offset: Offset(0, 5 * scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.title,
                    style: TextStyle(
                      fontSize: 17 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  height: 38 * scale,
                  width: 38 * scale,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 18 * scale,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12 * scale),

            Container(
              padding: EdgeInsets.symmetric(
                vertical: 12 * scale,
                horizontal: 10 * scale,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _macro("Calories", "${plan.calories}", scale),
                  _macro("Protein", "${plan.protein}g", scale),
                  _macro("Carbs", "${plan.carbs}g", scale),
                  _macro("Fats", "${plan.fat}g", scale),
                ],
              ),
            ),

            SizedBox(height: 12 * scale),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8 * scale),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              alignment: Alignment.center,
              child: Text(
                "${plan.durationDays} Meals per Day",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 14 * scale),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _editNutrition(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, size: 18 * scale),
                        SizedBox(width: 6 * scale),
                        Text("Edit", style: TextStyle(fontSize: 14 * scale)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          title: Text(
                            "Delete Nutrition?",
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
                        ),
                      );

                      if (confirm == true) _deleteNutrition(plan.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, size: 18 * scale),
                        SizedBox(width: 6 * scale),
                        Text("Delete", style: TextStyle(fontSize: 14 * scale)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 375;
    final filtered = _filteredNutrition();

    return Scaffold(
      backgroundColor: Color(0xfff4f5f7),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFA353FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddNutritionScreen()),
          );
          if (res == true) fetchNutritionPlans();
        },
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchNutritionPlans,
          child: ListView(
            padding: EdgeInsets.all(16 * scale),
            children: [
              Text(
                "Nutrition Plans",
                style: TextStyle(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4 * scale),

              Text(
                "Manage nutrition library",
                style: TextStyle(color: Colors.black54, fontSize: 14 * scale),
              ),
              SizedBox(height: 18 * scale),

              Container(
                height: 50 * scale,
                padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14 * scale),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.black54, size: 22 * scale),
                    SizedBox(width: 10 * scale),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Search nutrition plans...",
                          hintStyle: TextStyle(fontSize: 15 * scale),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20 * scale),

              if (isLoading)
                Center(
                  child: CircularProgressIndicator(color: Color(0xFFA353FF)),
                ),

              if (!isLoading && nutritionList.isEmpty)
                Center(child: Text("No nutrition plans found")),

              if (!isLoading && nutritionList.isNotEmpty)
                ...filtered.map(
                  (plan) => _buildNutritionCard(context, plan, scale),
                ),

              if (!isLoading && filtered.isEmpty)
                Center(child: Text("No nutrition plans found")),
            ],
          ),
        ),
      ),

      bottomNavigationBar: AdminBottomNav(currentIndex: 4),
    );
  }
}