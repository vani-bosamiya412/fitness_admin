import 'package:fitness_admin/Bottom_nav/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late Future<List<User>> futureUsers;

  final String viewApi = "https://prakrutitech.xyz/vani/view_user.php";
  final String deleteApi = "https://prakrutitech.xyz/vani/delete_user.php";

  List<User> users = [];
  TextEditingController searchCtrl = TextEditingController();

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(viewApi));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> deleteUser(int userId) async {
    final response = await http.post(
      Uri.parse(deleteApi),
      body: {"id": userId.toString()},
    );

    final res = json.decode(response.body);

    if (res["status"] == "success") {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User deleted successfully")),
      );

      setState(() {
        users.removeWhere((u) => u.id == userId);
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete user")));
    }
  }

  Future<void> _confirmDeleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Delete User?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete ${user.name}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      deleteUser(user.id);
    }
  }

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
  }

  Future<void> _refresh() async {
    final refreshedUsers = await fetchUsers();
    setState(() {
      users = refreshedUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 375;

    return Scaffold(
      backgroundColor: Color(0xfff4f5f7),
      body: SafeArea(
        child: FutureBuilder<List<User>>(
          future: futureUsers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFFA353FF)),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Failed to load users. Please try again.'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No users found"));
            }

            users = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: EdgeInsets.all(16 * scale),
                children: [
                  Text(
                    "User Management",
                    style: TextStyle(
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4 * scale),

                  Text(
                    "Manage app users",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14 * scale,
                    ),
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
                        Icon(
                          Icons.search,
                          color: Colors.black54,
                          size: 22 * scale,
                        ),
                        SizedBox(width: 10 * scale),
                        Expanded(
                          child: TextField(
                            controller: searchCtrl,
                            style: TextStyle(fontSize: 15 * scale),
                            decoration: InputDecoration(
                              hintText: "Search users...",
                              hintStyle: TextStyle(fontSize: 15 * scale),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20 * scale),

                  ...users
                      .where((user) {
                        final q = searchCtrl.text.toLowerCase();
                        return user.name.toLowerCase().contains(q) ||
                            user.email.toLowerCase().contains(q);
                      })
                      .map((user) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16 * scale),
                          padding: EdgeInsets.all(16 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16 * scale),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withValues(alpha: 0.05),
                                blurRadius: 10 * scale,
                                offset: Offset(0, 5 * scale),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 24 * scale,
                                    backgroundColor: Color(0xFFA353FF),
                                    child: Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 18 * scale,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 14 * scale),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16 * scale,
                                          ),
                                        ),
                                        SizedBox(height: 2 * scale),
                                        Text(
                                          user.email,
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14 * scale,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  PopupMenuButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        14 * scale,
                                      ),
                                    ),
                                    iconSize: 22 * scale,
                                    onSelected: (value) {
                                      if (value == "delete") {
                                        _confirmDeleteUser(user);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: "delete",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20 * scale,
                                            ),
                                            SizedBox(width: 8 * scale),
                                            Text(
                                              "Delete User",
                                              style: TextStyle(
                                                fontSize: 14 * scale,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AdminBottomNav(currentIndex: 1),
    );
  }
}