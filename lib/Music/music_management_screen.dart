import 'dart:convert';
import 'package:fitness_admin/Bottom_nav/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_music_screen.dart';
import 'edit_music_screen.dart';
import 'music_detail_screen.dart';

class Music {
  final int id;
  final String title;
  final String artist;
  final String genre;
  final int duration;
  final String musicUrl;

  Music({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.duration,
    required this.musicUrl,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      genre: json['genre'] ?? '',
      duration: int.tryParse(json['duration'].toString()) ?? 0,
      musicUrl: json['music_url'] ?? '',
    );
  }
}

class MusicManagementScreen extends StatefulWidget {
  const MusicManagementScreen({super.key});

  @override
  State<MusicManagementScreen> createState() => _MusicManagementScreenState();
}

class _MusicManagementScreenState extends State<MusicManagementScreen> {
  List<Music> _musicList = [];
  bool _loading = true;

  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMusic();
  }

  Future<void> fetchMusic() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse("https://prakrutitech.xyz/vani/view_music.php"),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _musicList = data.map((e) => Music.fromJson(e)).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<Music> _filteredMusic() {
    final q = searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _musicList;
    return _musicList.where((m) => m.title.toLowerCase().contains(q)).toList();
  }

  Future<void> deleteMusic(int id) async {
    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/vani/delete_music.php"),
        body: {"id": id.toString()},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Music deleted"),
          ),
        );

        if (result['status'] == 'success') {
          fetchMusic();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete music")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting music")),
      );
    }
  }

  Widget _buildMusicCard(Music music, double scale) {
    return InkWell(
      borderRadius: BorderRadius.circular(16 * scale),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MusicDetailScreen(musicId: music.id),
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
                Container(
                  height: 46 * scale,
                  width: 46 * scale,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7B2FFF), Color(0xFFB84DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 22 * scale,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        music.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        music.artist,
                        style: TextStyle(
                          fontSize: 13 * scale,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 36 * scale,
                  width: 36 * scale,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.blue,
                    size: 22 * scale,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14 * scale),

            Row(
              children: [
                Expanded(
                  child: _infoBox(
                    label: "Duration",
                    value: "${music.duration}:00",
                    scale: scale,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _genreBox(music.genre, scale),
                ),
              ],
            ),

            SizedBox(height: 12 * scale),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "URL",
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: Colors.black,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    music.musicUrl,
                    style: TextStyle(
                      fontSize: 13 * scale,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(height: 14 * scale),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditMusicScreen(music: music),
                        ),
                      ).then((_) => fetchMusic());
                    },
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
                            "Delete Music?",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            "Are you sure you want to delete this music track?",
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

                      if (confirm == true) {
                        deleteMusic(music.id);
                      }
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

  Widget _infoBox({
    required String label,
    required String value,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * scale,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            value,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _genreBox(String genre, double scale) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Genre",
            style: TextStyle(
              fontSize: 12 * scale,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4 * scale),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10 * scale,
              vertical: 4 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              genre,
              style: TextStyle(
                fontSize: 13 * scale,
                color: Color(0xFFA353FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 375;
    final filtered = _filteredMusic();

    return Scaffold(
      backgroundColor: Color(0xfff4f5f7),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFA353FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddMusicScreen()),
          ).then((_) => fetchMusic());
        },
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchMusic,
          child: ListView(
            padding: EdgeInsets.all(16 * scale),
            children: [
              Text(
                "Music Library",
                style: TextStyle(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                "Manage workout music",
                style: TextStyle(fontSize: 14 * scale, color: Colors.black54),
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
                          hintText: "Search music tracks...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20 * scale),

              if (_loading)
                Center(
                  child: CircularProgressIndicator(color: Color(0xFFA353FF)),
                ),

              if (!_loading && filtered.isEmpty)
                Center(child: Text("No music found")),

              if (!_loading)
                ...filtered.map((m) => _buildMusicCard(m, scale)),
            ],
          ),
        ),
      ),

      bottomNavigationBar: AdminBottomNav(currentIndex: 5),
    );
  }
}