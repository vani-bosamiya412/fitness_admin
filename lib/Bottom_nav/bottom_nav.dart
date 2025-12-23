import 'package:flutter/material.dart';
import '../Dashboard/dashboard.dart';
import '../User_details/user_details.dart';
import '../Trainers/trainer_management_screen.dart';
import '../Workout/workout.dart';
import '../Nutrition/nutrition_management_screen.dart';
import '../Music/music_management_screen.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({super.key, required this.currentIndex});

  void _onNavTap(int index, BuildContext context) {
    if (index == currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = AdminDashboard();
        break;
      case 1:
        screen = UserDetailsScreen();
        break;
      case 2:
        screen = TrainerManagementScreen();
        break;
      case 3:
        screen = WorkoutManagementScreen();
        break;
      case 4:
        screen = NutritionManagementScreen();
        break;
      case 5:
        screen = MusicManagementScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onNavTap(index, context),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFFA353FF),
      unselectedItemColor: Colors.black54,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_search),
          label: 'Trainers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Workouts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Nutrition',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music),
          label: 'Music',
        ),
      ],
    );
  }
}
