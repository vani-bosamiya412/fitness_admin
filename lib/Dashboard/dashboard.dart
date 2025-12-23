import 'dart:convert';
import 'package:fitness_admin/Bottom_nav/bottom_nav.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Login/login.dart';
import '../Trainers/trainer_detail_screen.dart';
import '../Trainers/trainer_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalUsers = 0;
  int activeTrainers = 0;
  int totalWorkouts = 0;
  int totalNutrition = 0;

  bool loading = true;

  List pendingTrainers = [];

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    try {
      final userRes = await http.get(
        Uri.parse("https://prakrutitech.xyz/vani/view_user.php"),
      );
      List users = jsonDecode(userRes.body);
      totalUsers = users.length;

      final trainerRes = await http.get(
        Uri.parse("https://prakrutitech.xyz/vani/get_trainers.php"),
      );
      List trainers = jsonDecode(trainerRes.body);

      activeTrainers = trainers
          .where((e) => e['status'] == "approved")
          .toList()
          .length;

      pendingTrainers = trainers
          .where((e) => e['status'] == "pending")
          .toList();

      final workoutRes = await http.get(
        Uri.parse("https://prakrutitech.xyz/vani/view_workout.php"),
      );
      List workouts = jsonDecode(workoutRes.body);
      totalWorkouts = workouts.length;

      final nutriRes = await http.get(
        Uri.parse("https://prakrutitech.xyz/vani/view_nutrition.php"),
      );
      List nutrition = jsonDecode(nutriRes.body);
      totalNutrition = nutrition.length;

      setState(() => loading = false);
    } catch (e) {
      if (kDebugMode) {
        print("ERROR FETCHING COUNTS: $e");
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("isLoggedIn");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminLoginScreen()),
    );
  }

  String timeAgoFrom(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inSeconds < 60) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
      if (diff.inHours < 24) return "${diff.inHours} hours ago";
      return "${diff.inDays} days ago";
    } catch (e) {
      return "Just now";
    }
  }

  Future<void> updateTrainerStatus(String id, String newStatus) async {
    try {
      final url = Uri.parse(
        "https://prakrutitech.xyz/vani/update_trainer_status.php",
      );
      final res = await http.post(url, body: {"id": id, "status": newStatus});

      final result = jsonDecode(res.body);

      if (result["status"] == "success") {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Trainer $newStatus successfully")),
        );
        fetchCounts();
      } else {
        if(!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update trainer")));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 375;

    return Scaffold(
      backgroundColor: Color(0xFFF5F6F8),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1283FF), Color(0xFF9B00F2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: 20 * scale,
                      right: 20 * scale,
                      top: 40 * scale,
                      bottom: 24 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Dashboard",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26 * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 6 * scale),
                                Text(
                                  "Welcome back, Admin",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14 * scale,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => _logout(context),
                              child: Container(
                                padding: EdgeInsets.all(8 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(
                                    12 * scale,
                                  ),
                                ),
                                child: Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 22 * scale,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20 * scale),

                        Wrap(
                          spacing: 14 * scale,
                          runSpacing: 14 * scale,
                          children: [
                            _statCard(
                              icon: Icons.people_outline,
                              iconBg: Color(0xFF4CA6FF),
                              count: "$totalUsers",
                              label: "Total Users",
                              width: (width - (56 * scale)) / 2,
                              scale: scale,
                            ),
                            _statCard(
                              icon: Icons.person_outline,
                              iconBg: Color(0xFF2ED573),
                              count: "$activeTrainers",
                              label: "Active Trainers",
                              width: (width - (56 * scale)) / 2,
                              scale: scale,
                            ),
                            _statCard(
                              icon: Icons.fitness_center,
                              iconBg: Color(0xFFB86BFF),
                              count: "$totalWorkouts",
                              label: "Total Workouts",
                              width: (width - (56 * scale)) / 2,
                              scale: scale,
                            ),
                            _statCard(
                              icon: Icons.restaurant_menu,
                              iconBg: Color(0xFFFF7A5A),
                              count: "$totalNutrition",
                              label: "Nutrition Plans",
                              width: (width - (56 * scale)) / 2,
                              scale: scale,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20 * scale),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16 * scale),
                    margin: EdgeInsets.symmetric(horizontal: 16 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withValues(alpha: 0.05),
                          blurRadius: 8 * scale,
                          offset: Offset(0, 3 * scale),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Pending Approvals",
                              style: TextStyle(
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Spacer(),
                            Container(
                              height: 28 * scale,
                              width: 28 * scale,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(14 * scale),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                pendingTrainers.length.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13 * scale,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10 * scale),
                        Text(
                          "Trainer applications",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13 * scale,
                          ),
                        ),

                        SizedBox(height: 16 * scale),

                        if (pendingTrainers.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "No pending trainer applications",
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: pendingTrainers.map((trainer) {
                              return _pendingApprovalItem(
                                trainer: trainer,
                                id: trainer['id'],
                                name: trainer['name'],
                                role: trainer['specialty'],
                                initials: trainer['name'][0].toUpperCase(),
                                timeAgo: timeAgoFrom(trainer['created_at']),
                                scale: scale,
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20 * scale),
                ],
              ),
            ),

      bottomNavigationBar: AdminBottomNav(currentIndex: 0,)
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBg,
    required String count,
    required String label,
    required double width,
    required double scale,
  }) {
    return Container(
      width: width,
      height: 120 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(14 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(icon, color: Colors.white, size: 20 * scale),
          ),
          Spacer(),
          Text(
            count,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 13 * scale),
          ),
        ],
      ),
    );
  }

  Widget _pendingApprovalItem({
    required Map<String, dynamic> trainer,
    required String initials,
    required String name,
    required String role,
    required String timeAgo,
    required double scale, required id,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrainerDetailScreen(
              trainer: Trainer.fromJson(trainer),
            ),
          ),
        ).then((_) => fetchCounts());
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * scale),
        padding: EdgeInsets.all(14 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withValues(alpha: 0.06),
              blurRadius: 6 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20 * scale,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14 * scale,
                    ),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      role,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13 * scale,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16 * scale),
                    SizedBox(width: 6 * scale),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12 * scale,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => updateTrainerStatus(id, "approved"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                    ),
                    child: Text(
                      "Approve",
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => updateTrainerStatus(id, "rejected"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                    ),
                    child: Text(
                      "Reject",
                      style: TextStyle(fontSize: 14 * scale),
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
}