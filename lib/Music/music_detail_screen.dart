import 'dart:convert';
import 'package:fitness_admin/Music/edit_music_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';

import 'music_management_screen.dart';

class MusicDetailScreen extends StatefulWidget {
  final int musicId;

  const MusicDetailScreen({super.key, required this.musicId});

  @override
  State<MusicDetailScreen> createState() => _MusicDetailScreenState();
}

class _MusicDetailScreenState extends State<MusicDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? music;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isOpeningSpotify = false;
  final String apiUrl = "https://prakrutitech.xyz/vani/view_music.php";

  @override
  void initState() {
    super.initState();
    fetchMusicDetail();
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> fetchMusicDetail() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          final selected = data.firstWhere(
            (item) => item['id'].toString() == widget.musicId.toString(),
            orElse: () => {},
          );
          if (selected.isNotEmpty) {
            setState(() {
              music = selected;
              isLoading = false;
            });
            return;
          }
        }
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Music not found")));
        }
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load music details")),
          );
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while loading music")),
      );
    }
  }

  bool get isSpotifyTrack =>
      music?['music_url']?.contains("spotify.com") ?? false;

  Future<void> togglePlay() async {
    if (music == null) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final musicUrl = music!['music_url'];

      if (isSpotifyTrack) {
        setState(() => isOpeningSpotify = true);

        final spotifyUri = await _convertToSpotifyDeepLink(musicUrl);

        try {
          final launched = await launchUrl(
            spotifyUri,
            mode: LaunchMode.externalNonBrowserApplication,
          );

          if (launched) {
            setState(() => isOpeningSpotify = false);
            return;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to open Spotify app: $e');
          }
        }

        try {
          final launched = await launchUrl(
            Uri.parse(musicUrl),
            mode: LaunchMode.externalApplication,
          );

          if (!launched) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text("Could not open Spotify link")),
            );
          }
        } catch (e) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text("Failed to open music link")),
          );
        } finally {
          if (mounted) {
            setState(() => isOpeningSpotify = false);
          }
        }
      } else {
        if (isPlaying) {
          await _audioPlayer.pause();
          setState(() => isPlaying = false);
        } else {
          await _audioPlayer.play(UrlSource(musicUrl));
          setState(() => isPlaying = true);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in togglePlay: $e');
      }
      if (mounted) {
        setState(() => isOpeningSpotify = false);
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Failed to play music")),
      );
    }
  }

  Future<Uri> _convertToSpotifyDeepLink(String webUrl) async {
    try {
      final uri = Uri.parse(webUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.contains('track') && pathSegments.length > 1) {
        final trackIndex = pathSegments.indexOf('track');
        if (trackIndex < pathSegments.length - 1) {
          final trackId = pathSegments[trackIndex + 1];
          final cleanTrackId = trackId.split('?').first;
          return Uri.parse('spotify:track:$cleanTrackId');
        }
      }

      final trackIdMatch = RegExp(r'track/([a-zA-Z0-9]+)').firstMatch(webUrl);
      if (trackIdMatch != null) {
        return Uri.parse('spotify:track:${trackIdMatch.group(1)}');
      }

      return Uri.parse(webUrl);
    } catch (_) {
      return Uri.parse(webUrl);
    }
  }

  Future<bool> get isSpotifyInstalled async {
    try {
      final result = await launchUrl(
        Uri.parse('spotify:'),
        mode: LaunchMode.externalNonBrowserApplication,
      );
      return result;
    } catch (e) {
      return false;
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
            : music == null
            ? Center(child: Text("No music found"))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Music Track Details",
                              style: TextStyle(
                                fontSize: 22 * scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              "View music track information",
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

                    Container(
                      padding: EdgeInsets.all(16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withValues(alpha: 0.06),
                            blurRadius: 10 * scale,
                            offset: Offset(0, 5 * scale),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 54 * scale,
                                width: 54 * scale,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF7B2FFF),
                                      Color(0xFFB84DFF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    16 * scale,
                                  ),
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 26 * scale,
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      music!['title'],
                                      style: TextStyle(
                                        fontSize: 18 * scale,
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
                                        color: Colors.purple.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        music!['genre'],
                                        style: TextStyle(
                                          fontSize: 13 * scale,
                                          color: Color(0xFFA353FF),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16 * scale),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isOpeningSpotify ? null : togglePlay,
                              icon: Icon(Icons.play_arrow, size: 20 * scale),
                              label: Text(
                                isSpotifyTrack
                                    ? "Play Preview"
                                    : (isPlaying
                                          ? "Pause Preview"
                                          : "Play Preview"),
                                style: TextStyle(fontSize: 15 * scale),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: 14 * scale,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    14 * scale,
                                  ),
                                ),
                                backgroundColor: Color(0xFFA353FF),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Track Information",
                            style: TextStyle(
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 14 * scale),

                          _workoutStyleInfo(
                            Icons.music_note,
                            "Song Title",
                            music!['title'],
                            scale,
                          ),
                          _workoutStyleInfo(
                            Icons.person_outline,
                            "Artist",
                            music!['artist'],
                            scale,
                          ),
                          _workoutStyleInfo(
                            Icons.local_offer_outlined,
                            "Genre",
                            music!['genre'],
                            scale,
                          ),
                          _workoutStyleInfo(
                            Icons.schedule,
                            "Duration",
                            "${music!['duration']} minutes",
                            scale,
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
                                Icons.link,
                                size: 22 * scale,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 12 * scale),
                              Text(
                                "Music File URL",
                                style: TextStyle(
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12 * scale),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(14 * scale),
                            decoration: BoxDecoration(
                              color: Color(0xFFEFF5FF),
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                            child: Text(
                              music!['music_url'],
                              style: TextStyle(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20 * scale),

                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditMusicScreen(music: Music.fromJson(music!)),
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
                            "Edit Music Track",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _workoutStyleInfo(
    IconData icon,
    String label,
    String value,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.all(14 * scale),
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14 * scale),
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
}
