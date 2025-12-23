import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_workout_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final int workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  Map<String, dynamic>? workout;
  bool isLoading = true;
  VideoPlayerController? _videoController;
  final String detailApiUrl = "https://prakrutitech.xyz/vani/view_workout.php";

  @override
  void initState() {
    super.initState();
    fetchWorkoutDetail();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> fetchWorkoutDetail() async {
    try {
      final response = await http.get(
        Uri.parse("$detailApiUrl?id=${widget.workoutId}"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        workout = data is List ? data[0] : data;
        isLoading = false;
        setState(() {});
        final url = workout?['video_url'] ?? '';
        if (_isDirectVideo(url)) {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
            ..initialize().then((_) {
              setState(() {});
            });
        }
      } else {
        isLoading = false;
        setState(() {});
      }
    } catch (_) {
      isLoading = false;
      setState(() {});
    }
  }

  bool _isImage(String url) {
    return url.endsWith(".jpg") ||
        url.endsWith(".jpeg") ||
        url.endsWith(".png") ||
        url.endsWith(".gif");
  }

  bool _isDirectVideo(String url) {
    return url.endsWith(".mp4") || url.endsWith(".mov") || url.endsWith(".avi");
  }

  bool _isYouTubeLink(String url) {
    return url.contains("youtube") || url.contains("youtu.be");
  }

  Widget _media(String url, double scale) {
    if (url.isEmpty) return SizedBox.shrink();

    if (_isImage(url)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          height: 250 * scale,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_isDirectVideo(url)) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    }

    if (_isYouTubeLink(url)) {
      return InkWell(
        onTap: () async {
          if (await canLaunchUrl(Uri.parse(url))) {
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
        },
        child: Container(
          padding: EdgeInsets.all(14 * scale),
          decoration: BoxDecoration(
            color: Color(0xffeef4ff),
            borderRadius: BorderRadius.circular(14 * scale),
          ),
          child: Row(
            children: [
              Icon(Icons.link, color: Colors.blue, size: 22 * scale),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  url,
                  style: TextStyle(fontSize: 14 * scale, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget badge(String text, Color bg, Color fg, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 5 * scale,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 13 * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget infoTile(IconData icon, String label, String value, double scale) {
    return Container(
      padding: EdgeInsets.all(14 * scale),
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22 * scale, color: Colors.grey[700]),
          SizedBox(width: 12 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13 * scale, color: Colors.grey[600]),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      backgroundColor: Color(0xfff5f7fa),

      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : workout == null
            ? Center(child: Text("Workout Not Found"))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Workout Details",
                      style: TextStyle(
                        fontSize: 22 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4 * scale),

                    Text(
                      "View workout information",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14 * scale,
                      ),
                    ),

                    SizedBox(height: 20 * scale),

                    Container(
                      padding: EdgeInsets.all(16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(14 * scale),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF1283FF), Color(0xFF9B00F2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28 * scale,
                            ),
                          ),
                          SizedBox(width: 14 * scale),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout!['title'],
                                  style: TextStyle(
                                    fontSize: 20 * scale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                Wrap(
                                  spacing: 10 * scale,
                                  runSpacing: 6 * scale,
                                  children: [
                                    badge(
                                      workout!['category'],
                                      Colors.blue.shade50,
                                      Colors.blue,
                                      scale,
                                    ),
                                    badge(
                                      workout!['difficulty'],
                                      workout!['difficulty'] == "Beginner"
                                          ? Colors.green.shade50
                                          : workout!['difficulty'] ==
                                                "Intermediate"
                                          ? Colors.orange.shade50
                                          : Colors.red.shade50,
                                      workout!['difficulty'] == "Beginner"
                                          ? Colors.green
                                          : workout!['difficulty'] ==
                                                "Intermediate"
                                          ? Colors.orange
                                          : Colors.red,
                                      scale,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16 * scale),

                    Container(
                      padding: EdgeInsets.all(16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: Colors.grey[700],
                                size: 22 * scale,
                              ),
                              SizedBox(width: 10 * scale),
                              Text(
                                "Description",
                                style: TextStyle(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10 * scale),
                          Text(
                            workout!['description'],
                            style: TextStyle(
                              fontSize: 14.5 * scale,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16 * scale),

                    Container(
                      padding: EdgeInsets.all(16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Workout Information",
                            style: TextStyle(
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 14 * scale),

                          infoTile(
                            Icons.dashboard,
                            "Category",
                            workout!['category'],
                            scale,
                          ),
                          infoTile(
                            Icons.timeline,
                            "Difficulty Level",
                            workout!['difficulty'],
                            scale,
                          ),
                          infoTile(
                            Icons.timer,
                            "Duration",
                            "${workout!['duration']} minutes",
                            scale,
                          ),

                          Container(
                            padding: EdgeInsets.all(14 * scale),
                            margin: EdgeInsets.only(bottom: 12 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14 * scale),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.video_collection,
                                      size: 22 * scale,
                                      color: Colors.grey[700],
                                    ),
                                    SizedBox(width: 12 * scale),
                                    Text(
                                      "Video/Image URL",
                                      style: TextStyle(
                                        fontSize: 13 * scale,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8 * scale),
                                Text(
                                  workout!['video_url'],
                                  style: TextStyle(
                                    fontSize: 15 * scale,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12 * scale),

                          _media(workout!['video_url'], scale),
                        ],
                      ),
                    ),

                    SizedBox(height: 20 * scale),

                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditWorkoutScreen(workout: workout!),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1283FF), Color(0xFF9B00F2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14 * scale),
                        ),
                        child: Center(
                          child: Text(
                            "Edit Workout",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
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