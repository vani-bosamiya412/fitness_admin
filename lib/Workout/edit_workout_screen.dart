import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic> workout;

  const EditWorkoutScreen({super.key, required this.workout});

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _durationController;
  late TextEditingController _urlController;

  String _selectedCategory = 'Cardio';
  String _selectedDifficulty = 'Beginner';
  bool _isLoading = false;

  YoutubePlayerController? _youtubeController;

  final String updateApiUrl =
      "https://prakrutitech.xyz/vani/update_workout.php";
  final String deleteApiUrl =
      "https://prakrutitech.xyz/vani/delete_workout.php";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.workout['title'] ?? '',
    );
    _descController = TextEditingController(
      text: widget.workout['description'] ?? '',
    );
    _durationController = TextEditingController(
      text: widget.workout['duration']?.toString() ?? '',
    );
    _urlController = TextEditingController(
      text: widget.workout['video_url'] ?? '',
    );
    _selectedCategory = widget.workout['category'] ?? 'Cardio';
    _selectedDifficulty = widget.workout['difficulty'] ?? 'Beginner';

    _initializeYoutubeController(_urlController.text);
  }

  void _initializeYoutubeController(String url) {
    if (url.contains("youtube.com") || url.contains("youtu.be")) {
      final videoId = YoutubePlayer.convertUrlToId(url.trim());
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(autoPlay: false, mute: false),
        );
      }
    } else {
      _youtubeController = null;
    }
  }

  Future<void> _updateWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(updateApiUrl),
        body: {
          "id": widget.workout['id'].toString(),
          "title": _titleController.text.trim(),
          "description": _descController.text.trim(),
          "category": _selectedCategory,
          "difficulty": _selectedDifficulty,
          "duration": _durationController.text.trim(),
          "trainer_id": widget.workout['trainer_id'].toString(),
          "video_url": _urlController.text.trim(),
        },
      );

      final data = json.decode(response.body);
      setState(() => _isLoading = false);

      if (data["success"] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Workout updated successfully!")),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update workout")),
        );
      }
    } catch (_) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update workout")));
    }
  }

  Widget _softField(
      double scale, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
        Function(String)? onChanged,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13 * scale,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            contentPadding: EdgeInsets.symmetric(
              vertical: 14 * scale,
              horizontal: 12 * scale,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
        ),
      ],
    );
  }

  Widget _categoryDropdown(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: TextStyle(
            fontSize: 13 * scale,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          icon: Icon(Icons.keyboard_arrow_down),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: 14 * scale,
              horizontal: 12 * scale,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: [
            DropdownMenuItem(value: "Cardio", child: Text("Cardio")),
            DropdownMenuItem(value: "Strength", child: Text("Strength")),
            DropdownMenuItem(value: "Yoga", child: Text("Yoga")),
            DropdownMenuItem(value: "Pilates", child: Text("Pilates")),
            DropdownMenuItem(value: "HIIT", child: Text("HIIT")),
            DropdownMenuItem(value: "Other", child: Text("Other")),
          ],
          onChanged: (v) {
            if (v != null) {
              setState(() => _selectedCategory = v);
            }
          },
          validator: (v) => v == null ? "Required" : null,
        ),
      ],
    );
  }

  Widget _difficultyDropdown(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Difficulty",
          style: TextStyle(
            fontSize: 13 * scale,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedDifficulty,
          icon: Icon(Icons.keyboard_arrow_down),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: 14 * scale,
              horizontal: 12 * scale,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: [
            DropdownMenuItem(value: "Beginner", child: Text("Beginner")),
            DropdownMenuItem(value: "Intermediate", child: Text("Intermediate")),
            DropdownMenuItem(value: "Advanced", child: Text("Advanced")),
          ],
          onChanged: (v) {
            if (v != null) {
              setState(() => _selectedDifficulty = v);
            }
          },
          validator: (v) => v == null ? "Required" : null,
        ),
      ],
    );
  }

  void _showDeleteConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text("Delete Workout?"),
          content: Text(
            "Are you sure you want to delete this workout?",
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

    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse(deleteApiUrl),
        body: {
          "id": widget.workout['id'].toString(),
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Workout deleted successfully")),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete workout")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete workout")),
      );
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
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final scale = w / 375;

    return Scaffold(
      backgroundColor: Color(0xfff5f7fa),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 12 * scale,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit Workout",
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  "Update workout details",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14 * scale,
                  ),
                ),

                SizedBox(height: 20 * scale),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Workout Details",
                        style: TextStyle(
                          fontSize: 17 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16 * scale),

                      _softField(
                        scale,
                        controller: _titleController,
                        label: "Workout Title",
                        icon: Icons.text_fields,
                      ),

                      SizedBox(height: 14 * scale),

                      _softField(
                        scale,
                        controller: _descController,
                        label: "Description",
                        icon: Icons.description,
                        maxLines: 3,
                      ),

                      SizedBox(height: 18 * scale),

                      Row(
                        children: [
                          Expanded(child: _categoryDropdown(scale)),
                          SizedBox(width: 12 * scale),
                          Expanded(child: _difficultyDropdown(scale)),
                        ],
                      ),

                      SizedBox(height: 18 * scale),

                      _softField(
                        scale,
                        controller: _durationController,
                        label: "Duration (minutes)",
                        icon: Icons.timer,
                        keyboard: TextInputType.number,
                      ),

                      SizedBox(height: 18 * scale),

                      _softField(
                        scale,
                        controller: _urlController,
                        label: "Video URL",
                        icon: Icons.videocam_outlined,
                        keyboard: TextInputType.url,
                        onChanged: (v) {
                          setState(() => _initializeYoutubeController(v));
                        },
                      ),
                    ],
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
                          Color(0xFF3B5BFF),
                          Color(0xFF8F00FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: _updateWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
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
                  height: 52 * scale,
                  child: OutlinedButton.icon(
                    onPressed: _showDeleteConfirmation,
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    label: Text(
                      "Delete Workout",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}