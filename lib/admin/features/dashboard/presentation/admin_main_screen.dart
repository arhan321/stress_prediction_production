import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/admin_state_provider.dart';
import 'admin_dashboard_screen.dart';
import '../../users/presentation/admin_users_screen.dart';
import '../../datasets/presentation/admin_datasets_screen.dart';
import '../../settings/presentation/admin_settings_screen.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStateProvider>(
      builder: (context, adminState, child) {
        final List<Widget> pages = [
          const AdminDashboardScreen(),
          const AdminUsersScreen(),
          const AdminDatasetsScreen(),
          const AdminSettingsScreen(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: adminState.currentPageIndex,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: adminState.currentPageIndex,
            onTap: (index) => adminState.setCurrentPageIndex(index),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Users',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.storage),
                label: 'Datasets',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.logout),
                label: 'Logout',
              ),
            ],
          ),
        );
      },
    );
  }
} 