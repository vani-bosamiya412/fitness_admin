import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddMusicScreen extends StatefulWidget {
  const AddMusicScreen({super.key});

  @override
  State<AddMusicScreen> createState() => _AddMusicScreenState();
}

class _AddMusicScreenState extends State<AddMusicScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _durationController = TextEditingController();
  final _urlController = TextEditingController();

  String _selectedGenre = 'Electronic';
  bool _isLoading = false;

  final String insertMusicApi =
      "https://prakrutitech.xyz/vani/insert_music.php";

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse(insertMusicApi),
        body: {
          "title": _titleController.text.trim(),
          "artist": _artistController.text.trim(),
          "genre": _selectedGenre,
          "duration": _durationController.text.trim(),
          "music_url": _urlController.text.trim(),
        },
      );

      final data = json.decode(res.body);
      setState(() => _isLoading = false);

      if (data["status"] == "success") {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Music track added successfully")),
        );
        Navigator.pop(context, true);
      } else {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add music")),
        );
      }
    } catch (_) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add music")),
      );
    }
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
                "Add Music Track",
                style: TextStyle(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                "Upload a new workout music",
                style: TextStyle(
                  fontSize: 14 * scale,
                  color: Colors.black54,
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
                        "Music Details",
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 14 * scale),

                      Text(
                        "Song Title",
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: "e.g., Energetic Workout Mix",
                          prefixIcon: Icon(Icons.music_note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * scale),
                          ),
                        ),
                        validator: (v) =>
                        v!.isEmpty ? "Please enter song title" : null,
                      ),

                      SizedBox(height: 20 * scale),

                      Text(
                        "Artist Name",
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      TextFormField(
                        controller: _artistController,
                        decoration: InputDecoration(
                          hintText: "e.g., DJ Fitness Pro",
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * scale),
                          ),
                        ),
                        validator: (v) =>
                        v!.isEmpty ? "Please enter artist name" : null,
                      ),

                      SizedBox(height: 20 * scale),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Genre",
                                  style: TextStyle(
                                    fontSize: 13 * scale,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6 * scale),
                                DropdownButtonFormField<String>(
                                  value: _selectedGenre,
                                  decoration: InputDecoration(
                                    prefixIcon:
                                    Icon(Icons.sell_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(14 * scale),
                                    ),
                                  ),
                                  items: [
                                    "Electronic",
                                    "Ambient",
                                    "Hip Hop",
                                    "Pop",
                                    "Rock",
                                    "Classical"
                                  ]
                                      .map(
                                        (g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(g),
                                    ),
                                  )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedGenre = v!),
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
                                  "Duration (sec)",
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
                                      borderRadius:
                                      BorderRadius.circular(14 * scale),
                                    ),
                                  ),
                                  validator: (v) =>
                                  v!.isEmpty ? "Enter duration" : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20 * scale),

                      Text(
                        "Spotify Music URL",
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
                          hintText:
                          "https://open.spotify.com/track/...",
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * scale),
                          ),
                        ),
                        validator: (v) =>
                        v!.isEmpty ? "Please enter Spotify URL" : null,
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
                      colors: [
                        Color(0xff4a6cf7),
                        Color(0xff9333ea),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14 * scale),
                      ),
                    ),
                    child: Text(
                      "Add Music Track",
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
