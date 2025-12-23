import 'dart:convert';
import 'package:fitness_admin/Bottom_nav/bottom_nav.dart';
import 'package:fitness_admin/Trainers/trainer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_trainer_screen.dart';
import 'edit_trainer_screen.dart';

class Trainer {
  final int id;
  String name;
  String email;
  String phone;
  String specialty;
  int experience;
  String status;

  Trainer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.experience,
    required this.status,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: int.parse(json['id']),
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      specialty: json['specialty'] ?? '',
      experience: int.tryParse(json['experience'].toString()) ?? 0,
      status: json['status'] ?? 'pending',
    );
  }
}

class TrainerManagementScreen extends StatefulWidget {
  const TrainerManagementScreen({super.key});

  @override
  State<TrainerManagementScreen> createState() =>
      _TrainerManagementScreenState();
}

class _TrainerManagementScreenState extends State<TrainerManagementScreen> {
  List<Trainer> trainers = [];
  bool isLoading = true;

  final String viewApiUrl = "https://prakrutitech.xyz/vani/get_trainers.php";
  final String deleteApiUrl =
      "https://prakrutitech.xyz/vani/delete_trainer.php";

  final List<String> statuses = ["All", "Pending", "Approved", "Rejected"];
  String selectedStatus = "All";

  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTrainers();
  }

  Future<void> fetchTrainers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(viewApiUrl));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        setState(() {
          trainers = data.map((t) => Trainer.fromJson(t)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load trainers")));
      }
    } catch (_) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load trainers")));
    }
  }

  List<Trainer> _filteredTrainers() {
    final q = searchCtrl.text.toLowerCase();

    final base = selectedStatus == "All"
        ? trainers
        : trainers
              .where(
                (t) => t.status.toLowerCase() == selectedStatus.toLowerCase(),
              )
              .toList();

    return base.where((t) {
      return t.name.toLowerCase().contains(q) ||
          t.email.toLowerCase().contains(q) ||
          t.specialty.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _editTrainer(Trainer trainer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTrainerScreen(trainer: trainer)),
    );
    if (result == true) fetchTrainers();
  }

  Future<void> _deleteTrainer(int id) async {
    try {
      final response = await http.post(
        Uri.parse(deleteApiUrl),
        body: {"id": id.toString()},
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        fetchTrainers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Trainer deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Delete failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error. Try again.")),
      );
    }
  }

  Future<void> _updateTrainerStatus(int id, String status) async {
    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/vani/update_trainer_status.php"),
        body: {"id": id.toString(), "status": status},
      );

      if (!mounted) return;

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        fetchTrainers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Status updated")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Update failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update trainer status")),
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _infoBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case 'approved':
        bg = Colors.green.shade50;
        fg = Colors.green;
        text = "Approved";
        break;
      case 'rejected':
        bg = Colors.red.shade50;
        fg = Colors.red;
        text = "Rejected";
        break;
      default:
        bg = Colors.orange.shade50;
        fg = Colors.orange;
        text = "Pending Approval";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _buildTrainerCard(BuildContext context, Trainer t, double scale) {
    final isPending = t.status == 'pending';
    final isApproved = t.status == 'approved';
    final isRejected = t.status == 'rejected';

    return InkWell(
      borderRadius: BorderRadius.circular(16 * scale),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TrainerDetailScreen(trainer: t)),
        ).then((_) => fetchTrainers());
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
                CircleAvatar(
                  radius: 22 * scale,
                  backgroundColor: Colors.green,
                  child: Text(
                    t.name.isNotEmpty ? t.name[0].toUpperCase() : '',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14 * scale,
                    ),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name,
                        style: TextStyle(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        t.email,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 14 * scale),

            Row(
              children: [
                _infoBox("Specialty", t.specialty),
                SizedBox(width: 12 * scale),
                _infoBox("Experience", "${t.experience} years"),
              ],
            ),

            SizedBox(height: 10 * scale),

            _statusChip(t.status),

            SizedBox(height: 14 * scale),

            if (isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _updateTrainerStatus(t.id, "approved");
                      },
                      icon: Icon(Icons.check, size: 18 * scale),
                      label: Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _updateTrainerStatus(t.id, "rejected");
                      },
                      icon: Icon(Icons.close, size: 18 * scale),
                      label: Text("Reject"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if(isApproved) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isApproved ? () => _editTrainer(t) : null,
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
                          Icon(
                            Icons.edit,
                            size: 18 * scale,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 6 * scale),
                          Text(
                            "Edit",
                            style: TextStyle(
                              fontSize: 14 * scale,
                              color: Colors.blue,
                            ),
                          ),
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
                                "Delete Trainer?",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                "Are you sure you want to delete this trainer?",
                              ),
                              actions: [
                                TextButton(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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

                        if (confirm == true) {
                          _deleteTrainer(t.id);
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
                          Text(
                            "Delete",
                            style: TextStyle(fontSize: 14 * scale),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (isRejected) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        title: Text(
                          "Re-Approve Trainer?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          "This trainer was previously rejected. Do you want to approve them again?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              "Re-Approve",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      _updateTrainerStatus(t.id, "approved");
                    }
                  },
                  icon: Icon(Icons.restore),
                  label: Text("Re-Approve"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12 * scale),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 375;

    final filtered = [
      ..._filteredTrainers().where((t) => t.status == 'pending'),
      ..._filteredTrainers().where((t) => t.status != 'pending'),
    ];

    return Scaffold(
      backgroundColor: Color(0xfff4f5f7),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFA353FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTrainerScreen()),
          );
          if (result == true) fetchTrainers();
        },
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchTrainers,
          child: ListView(
            padding: EdgeInsets.all(16 * scale),
            children: [
              Text(
                "Trainer Management",
                style: TextStyle(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 4 * scale),

              Text(
                "Approve & manage trainers",
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
                          hintText: "Search trainers...",
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
                  children: statuses.map((status) {
                    final isSelected = selectedStatus == status;

                    return Padding(
                      padding: EdgeInsets.only(right: 8 * scale),
                      child: ChoiceChip(
                        label: Text(
                          status,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Color(0xFFA353FF),
                        backgroundColor: Colors.grey.shade200,
                        onSelected: (_) =>
                            setState(() => selectedStatus = status),
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
                Center(child: Text("No trainers found")),

              if (!isLoading && filtered.isNotEmpty)
                ...filtered.map((t) => _buildTrainerCard(context, t, scale)),
            ],
          ),
        ),
      ),

      bottomNavigationBar: AdminBottomNav(currentIndex: 2),
    );
  }
}