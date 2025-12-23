import 'dart:convert';
import 'package:fitness_admin/Bottom_nav/bottom_nav.dart';
import 'package:fitness_admin/Workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_workout_screen.dart';
import 'edit_workout_screen.dart';

class Workout {
  final int id;
  String title;
  String description;
  String category;
  String difficulty;
  String duration;
  String videoUrl;
  String trainerId;

  Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.videoUrl,
    required this.trainerId,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? '',
      duration: json['duration']?.toString() ?? '',
      videoUrl: json['video_url'] ?? '',
      trainerId: json['trainer_id']?.toString() ?? '',
    );
  }
}

class WorkoutManagementScreen extends StatefulWidget {
  const WorkoutManagementScreen({super.key});

  @override
  State<WorkoutManagementScreen> createState() =>
      _WorkoutManagementScreenState();
}

class _WorkoutManagementScreenState extends State<WorkoutManagementScreen> {
  List<Workout> workouts = [];
  bool isLoading = true;

  final String viewApiUrl = "https://prakrutitech.xyz/vani/view_workout.php";
  final String deleteApiUrl =
      "https://prakrutitech.xyz/vani/delete_workout.php";

  final List<String> categories = [
    "All",
    "Beginner",
    "Intermediate",
    "Advanced",
  ];

  String selectedCategory = "All";
  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(viewApiUrl));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        setState(() {
          workouts = data.map((w) => Workout.fromJson(w)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<Workout> _filteredWorkouts() {
    final q = searchCtrl.text.toLowerCase();

    return workouts.where((w) {
      final matchesCategory =
          (selectedCategory == "All") || (w.difficulty == selectedCategory);

      final matchesSearch =
          w.title.toLowerCase().contains(q) ||
          w.category.toLowerCase().contains(q);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _editWorkout(Workout workout) async {
    final workoutData = {
      "id": workout.id,
      "title": workout.title,
      "description": workout.description,
      "category": workout.category,
      "difficulty": workout.difficulty,
      "duration": workout.duration,
      "trainer_id": workout.trainerId,
      "video_url": workout.videoUrl,
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditWorkoutScreen(workout: workoutData),
      ),
    );

    if (result == true) fetchWorkouts();
  }

  Future<void> _deleteWorkout(int id) async {
    try {
      final response = await http.post(
        Uri.parse(deleteApiUrl),
        body: {"id": id.toString()},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        fetchWorkouts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Workout deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete workout")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete workout")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 375;

    final filtered = _filteredWorkouts();

    return Scaffold(
      backgroundColor: Color(0xfff4f5f7),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFA353FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddWorkoutScreen()),
          );
          if (res == true) fetchWorkouts();
        },
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchWorkouts,
          child: ListView(
            padding: EdgeInsets.all(16 * scale),
            children: [
              Text(
                "Workout Management",
                style: TextStyle(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4 * scale),

              Text(
                "Manage workout library",
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
                        style: TextStyle(fontSize: 15 * scale),
                        decoration: InputDecoration(
                          hintText: "Search workouts...",
                          hintStyle: TextStyle(fontSize: 15 * scale),
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20 * scale),

              SizedBox(
                height: 45 * scale,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories.map((cat) {
                    final isSelected = selectedCategory == cat;

                    return Padding(
                      padding: EdgeInsets.only(right: 8 * scale),
                      child: ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Color(0xFFA353FF),
                        backgroundColor: Colors.grey.shade200,
                        onSelected: (_) =>
                            setState(() => selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 20 * scale),

              if (isLoading)
                Center(
                  child: CircularProgressIndicator(color: Color(0xFFA353FF)),
                ),

              if (!isLoading && filtered.isEmpty)
                Center(child: Text("No workouts found")),

              if (!isLoading && filtered.isNotEmpty)
                ...filtered.map((w) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(workoutId: w.id),
                        ),
                      );
                    },
                    child: _buildWorkoutCard(context, w, scale),
                  );
                }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminBottomNav(currentIndex: 3),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout w, double scale) {
    return Container(
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
          Text(
            w.title,
            style: TextStyle(fontSize: 17 * scale, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: w.difficulty == "Beginner"
                      ? Colors.green.shade50
                      : w.difficulty == "Intermediate"
                      ? Colors.orange.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Text(
                  w.difficulty,
                  style: TextStyle(
                    fontSize: 13 * scale,
                    color: w.difficulty == "Beginner"
                        ? Colors.green
                        : w.difficulty == "Intermediate"
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ),
              SizedBox(width: 10 * scale),
              Text("•", style: TextStyle(fontSize: 16 * scale)),
              SizedBox(width: 10 * scale),
              Text(
                "${w.duration} min",
                style: TextStyle(fontSize: 14 * scale, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Category",
                  style: TextStyle(fontSize: 12 * scale, color: Colors.grey),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  w.category,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14 * scale),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _editWorkout(w),
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
                      Icon(Icons.edit, size: 18 * scale, color: Colors.blue),
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
                    final confirm = await showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          title: Text(
                            "Delete Workout?",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            "Are you sure you want to delete this workout?",
                          ),
                          actions: [
                            TextButton(
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.grey),
                              ),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            TextButton(
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) _deleteWorkout(w.id);
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
    );
  }
}