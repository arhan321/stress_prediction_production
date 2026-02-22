import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../features/dashboard/presentation/dashboard_screen.dart';
import '../../../features/analysis/presentation/individual_analysis_screen.dart';
import '../../../features/profile/presentation/profile_screen.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          body: IndexedStack(
            index: appState.currentIndex,
            children: const [
              DashboardScreen(),
              IndividualAnalysisScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              // Explicit icon theme for bottom navigation
              iconTheme: const IconThemeData(
                color: Color(0xFF374151),
                size: 24,
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: appState.currentIndex,
              onTap: (index) => appState.setCurrentIndex(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF2563EB),
              unselectedItemColor: const Color(0xFF6B7280),
              iconSize: 24,
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      appState.currentIndex == 0 ? Icons.home : Icons.home_outlined,
                      size: 24,
                      color: appState.currentIndex == 0 
                          ? const Color(0xFF2563EB) 
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  label: AppConstants.beranda,
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      appState.currentIndex == 1 ? Icons.person_search : Icons.person_search_outlined,
                      size: 24,
                      color: appState.currentIndex == 1 
                          ? const Color(0xFF2563EB) 
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  label: AppConstants.analisisPerOrang,
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      appState.currentIndex == 2 ? Icons.person : Icons.person_outline,
                      size: 24,
                      color: appState.currentIndex == 2 
                          ? const Color(0xFF2563EB) 
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  label: AppConstants.profil,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
