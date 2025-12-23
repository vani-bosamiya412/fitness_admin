import 'package:flutter/material.dart';
import 'edit_trainer_screen.dart';
import 'trainer_management_screen.dart';

class TrainerDetailScreen extends StatelessWidget {
  final Trainer trainer;

  const TrainerDetailScreen({super.key, required this.trainer});

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 375;
    final canEdit = trainer.status == 'approved';

    return Scaffold(
      backgroundColor: Color(0xfff4f5f7),
      body: SafeArea(
        child: SingleChildScrollView(
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
                        "Trainer Details",
                        style: TextStyle(
                          fontSize: 22 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        "View trainer information",
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

              Center(
                child: Container(
                  width: width * 0.9,
                  padding: EdgeInsets.symmetric(vertical: 24 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22 * scale),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 38 * scale,
                        backgroundColor: Colors.green,
                        child: Text(
                          trainer.name.isNotEmpty
                              ? trainer.name[0].toUpperCase()
                              : "",
                          style: TextStyle(
                            fontSize: 22 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      Text(
                        trainer.name,
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 18 * scale),

              Container(
                width: width * 0.9,
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18 * scale),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status",
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * scale,
                        vertical: 6 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(
                          trainer.status,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20 * scale),
                      ),
                      child: Text(
                        trainer.status.capitalize(),
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(trainer.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18 * scale),

              _infoSection(
                scale,
                title: "Contact Information",
                children: [
                  _infoTile(scale, Icons.email, "Email", trainer.email),
                  _infoTile(scale, Icons.phone, "Phone", trainer.phone),
                ],
              ),

              SizedBox(height: 18 * scale),

              _infoSection(
                scale,
                title: "Professional Information",
                children: [
                  _infoTile(scale, Icons.badge, "Specialty", trainer.specialty),
                  _infoTile(
                    scale,
                    Icons.work,
                    "Experience",
                    "${trainer.experience} years",
                  ),
                ],
              ),

              SizedBox(height: 26 * scale),

              Container(
                width: double.infinity,
                height: 50 * scale,
                decoration: BoxDecoration(
                  color: canEdit ? null : Colors.grey.shade300,
                  gradient: canEdit
                      ? LinearGradient(
                          colors: [Color(0xFF3B5BFF), Color(0xFF8F2CFF)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16 * scale),
                ),
                child: ElevatedButton.icon(
                  onPressed: canEdit
                      ? () async {
                          final res = await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditTrainerScreen(trainer: trainer),
                            ),
                          );
                          if (res == true && context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  label: Text(
                    "Edit Trainer",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15 * scale,
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

  Widget _infoTile(double scale, IconData icon, String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(icon, size: 18 * scale),
          ),
          SizedBox(width: 12 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12 * scale, color: Colors.black),
              ),
              SizedBox(height: 4 * scale),
              Text(
                value.isEmpty ? "-" : value,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoSection(
    double scale, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 14 * scale),
          ...children,
        ],
      ),
    );
  }
}

extension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}