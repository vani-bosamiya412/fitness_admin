import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _urlController = TextEditingController();

  String _selectedCategory = 'Cardio';
  String _selectedDifficulty = 'Beginner';
  bool _isLoading = false;

  YoutubePlayerController? _youtubeController;

  final String insertApiUrl =
      "https://prakrutitech.xyz/vani/insert_workout.php";

  Future<void> _submitWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(insertApiUrl),
        body: {
          "title": _titleController.text.trim(),
          "description": _descController.text.trim(),
          "category": _selectedCategory,
          "difficulty": _selectedDifficulty,
          "duration": _durationController.text.trim(),
          "trainer_id": "1",
          "video_url": _urlController.text.trim(),
        },
      );

      final data = json.decode(response.body);
      setState(() => _isLoading = false);

      if (data["status"] == "success") {
        if(!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Workout added successfully!")));
        Navigator.pop(context, true);
      } else {
        if(!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to add workout")));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add workout")));
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      backgroundColor: Color(0xfff4f5f7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Workout",
                style: TextStyle(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                "Create a new workout program",
                style: TextStyle(color: Colors.black54, fontSize: 14 * scale),
              ),

              SizedBox(height: 20 * scale),

              Container(
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Workout Details",
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 14 * scale),

                      Text(
                        "Workout Title",
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      TextFormField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: "e.g., Morning Cardio Blast",
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * scale),
                          ),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? "Please enter a workout title" : null,
                      ),

                      SizedBox(height: 20 * scale),

                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      TextFormField(
                        controller: _descController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              "Describe the workout program and its benefits...",
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * scale),
                          ),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? "Please enter a description" : null,
                      ),

                      SizedBox(height: 20 * scale),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Category",
                                  style: TextStyle(
                                    fontSize: 13 * scale,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6 * scale),
                                DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.sell_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        14 * scale,
                                      ),
                                    ),
                                  ),
                                  items:
                                      [
                                            "Cardio",
                                            "Strength",
                                            "Yoga",
                                            "Pilates",
                                            "HIIT",
                                            "Other",
                                          ]
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(c),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedCategory = v!),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 12 * scale),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Difficulty",
                                  style: TextStyle(
                                    fontSize: 13 * scale,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6 * scale),
                                DropdownButtonFormField<String>(
                                  value: _selectedDifficulty,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.leaderboard),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        14 * scale,
                                      ),
                                    ),
                                  ),
                                  items: ["Beginner", "Intermediate", "Advanced"]
                                      .map(
                                        (d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(d),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedDifficulty = v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20 * scale),

                      Text(
                        "Duration (minutes)",
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.timer),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * scale),
                          ),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? "Please enter duration" : null,
                      ),

                      SizedBox(height: 20 * scale),

                      Text(
                        "Video/Image URL",
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      TextFormField(
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * scale),
                          ),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? "Please enter a media URL" : null,
                        onChanged: (value) {
                          setState(() {
                            if (value.contains("youtube.com") ||
                                value.contains("youtu.be")) {
                              final videoId = YoutubePlayer.convertUrlToId(
                                value.trim(),
                              );
                              if (videoId != null) {
                                _youtubeController = YoutubePlayerController(
                                  initialVideoId: videoId,
                                  flags: YoutubePlayerFlags(
                                    autoPlay: false,
                                    mute: false,
                                  ),
                                );
                              }
                            } else {
                              _youtubeController = null;
                            }
                          });
                        },
                      ),

                      SizedBox(height: 12 * scale),

                      if (_urlController.text.isNotEmpty)
                        Column(
                          children: [
                            if (_youtubeController != null)
                              YoutubePlayer(
                                controller: _youtubeController!,
                                showVideoProgressIndicator: true,
                              )
                            else
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _urlController.text,
                                  height: 180 * scale,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Text("Invalid or blocked URL"),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20 * scale),

              SizedBox(
                width: double.infinity,
                height: 52 * scale,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff4a6cf7),
                        Color(0xff9333ea),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  child: ElevatedButton(
                    onPressed: _submitWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14 * scale),
                      ),
                    ),
                    child: Text(
                      "Add Workout",
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),


              SizedBox(height: 30 * scale),
            ],
          ),
        ),
      ),
    );
  }
}
