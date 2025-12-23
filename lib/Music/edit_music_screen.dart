import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'music_management_screen.dart';

class EditMusicScreen extends StatefulWidget {
  final Music music;

  const EditMusicScreen({super.key, required this.music});

  @override
  State<EditMusicScreen> createState() => _EditMusicScreenState();
}

class _EditMusicScreenState extends State<EditMusicScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _title;
  late TextEditingController _artist;
  late TextEditingController _genre;
  late TextEditingController _duration;
  late TextEditingController _musicUrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.music.title);
    _artist = TextEditingController(text: widget.music.artist);
    _genre = TextEditingController(text: widget.music.genre);
    _duration = TextEditingController(text: widget.music.duration.toString());
    _musicUrl = TextEditingController(text: widget.music.musicUrl);
  }

  Future<void> updateMusic() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/vani/update_music.php"),
        body: {
          'id': widget.music.id.toString(),
          'title': _title.text,
          'artist': _artist.text,
          'genre': _genre.text,
          'duration': _duration.text,
          'music_url': _musicUrl.text,
        },
      );

      if (!mounted) return;

      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "Operation completed")),
      );

      if (data['status'] == 'success') {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update music track")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _softField(
      double scale, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13 * scale),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
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

  void _showDeleteConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text("Delete Music Track?"),
        content: Text(
          "Are you sure you want to delete this music track?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/vani/delete_music.php"),
        body: {'id': widget.music.id.toString()},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Music deleted successfully")),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete music")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      backgroundColor: Color(0xfff5f7fa),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16 * scale),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit Music Track",
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  "Update music track details",
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
                        "Music Details",
                        style: TextStyle(
                          fontSize: 17 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16 * scale),

                      _softField(
                        scale,
                        controller: _title,
                        label: "Song Title",
                        icon: Icons.music_note,
                      ),
                      SizedBox(height: 14 * scale),

                      _softField(
                        scale,
                        controller: _artist,
                        label: "Artist Name",
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: 14 * scale),

                      _softField(
                        scale,
                        controller: _genre,
                        label: "Genre",
                        icon: Icons.sell_outlined,
                      ),
                      SizedBox(height: 14 * scale),

                      _softField(
                        scale,
                        controller: _duration,
                        label: "Duration (seconds)",
                        icon: Icons.timer,
                        keyboard: TextInputType.number,
                      ),
                      SizedBox(height: 14 * scale),

                      _softField(
                        scale,
                        controller: _musicUrl,
                        label: "Music URL",
                        icon: Icons.link,
                        keyboard: TextInputType.url,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20 * scale),

                SizedBox(
                  width: double.infinity,
                  height: 52 * scale,
                  child: _isSubmitting
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
                      onPressed: updateMusic,
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
                    icon:
                    Icon(Icons.delete_outline, color: Colors.red),
                    label: Text(
                      "Delete Track",
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