import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/admin_state_provider.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/chart_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _dashboardStats;
  List<Map<String, dynamic>> _recentUsers = [];
  List<Map<String, dynamic>> _recentDatasets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final adminState = Provider.of<AdminStateProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        adminState.apiService.getDashboardStats(),
        adminState.apiService.getUsers(limit: 5),
        adminState.apiService.getDatasets(limit: 5),
      ]);

      if (mounted) {
        setState(() {
          if (results[0]['success']) {
            _dashboardStats = results[0]['data']['stats'];
          }
          if (results[1]['success']) {
            _recentUsers = List<Map<String, dynamic>>.from(results[1]['data']['users'] ?? []);
          }
          if (results[2]['success']) {
            _recentDatasets = List<Map<String, dynamic>>.from(results[2]['data']['datasets'] ?? []);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(
        title: 'Dashboard Admin',
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Consumer<AdminStateProvider>(
                      builder: (context, adminState, child) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: Text(
                                    adminState.userInitials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selamat datang, ${adminState.userDisplayName}',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Kelola sistem analisis stres karyawan Anda',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Metrics Overview
                    Text(
                      'Ringkasan Sistem',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        MetricCard(
                          title: 'Total Users',
                          value: _dashboardStats?['users']?['total']?.toString() ?? '0',
                          subtitle: '${_dashboardStats?['users']?['active'] ?? 0} active',
                          icon: Icons.people,
                          color: Colors.blue,
                          trend: null,
                          trendUp: true,
                        ),
                        MetricCard(
                          title: 'Total Datasets',
                          value: _dashboardStats?['datasets']?['total']?.toString() ?? '0',
                          subtitle: '${_dashboardStats?['datasets']?['processed'] ?? 0} processed',
                          icon: Icons.storage,
                          color: Colors.green,
                          trend: null,
                          trendUp: true,
                        ),
                        MetricCard(
                          title: 'Success Rate',
                          value: '${_dashboardStats?['datasets']?['success_rate']?.toStringAsFixed(1) ?? '0.0'}%',
                          subtitle: 'Dataset processing',
                          icon: Icons.trending_up,
                          color: Colors.orange,
                          trend: null,
                          trendUp: true,
                        ),
                        MetricCard(
                          title: 'Admin Users',
                          value: _dashboardStats?['users']?['admins']?.toString() ?? '0',
                          subtitle: '${_dashboardStats?['users']?['employees'] ?? 0} employees',
                          icon: Icons.admin_panel_settings,
                          color: Colors.purple,
                          trend: null,
                          trendUp: true,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Recent Activity
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Recent Users Section
                    if (_recentUsers.isNotEmpty) ...[
                      Text(
                        'Recent Users',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: _recentUsers
                              .take(3)
                              .map((user) => Column(
                                    children: [
                                      _buildActivityItem(
                                        context,
                                        icon: Icons.person_add,
                                        title: '${user['full_name']} (${user['role']})',
                                        subtitle: 'Joined ${_formatRelativeTime(user['created_at'])} • ${user['dataset_count']} datasets',
                                        iconColor: user['role'] == 'admin' ? Colors.purple : Colors.blue,
                                      ),
                                      if (_recentUsers.indexOf(user) < _recentUsers.take(3).length - 1)
                                        const Divider(height: 1),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Recent Datasets Section
                    if (_recentDatasets.isNotEmpty) ...[
                      Text(
                        'Recent Datasets',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: _recentDatasets
                              .take(3)
                              .map((dataset) => Column(
                                    children: [
                                      _buildActivityItem(
                                        context,
                                        icon: Icons.upload_file,
                                        title: dataset['name'] ?? 'Unknown Dataset',
                                        subtitle: 'Uploaded ${_formatRelativeTime(dataset['upload_date'])} • ${dataset['record_count']} records • ${dataset['status']}',
                                        iconColor: _getStatusColor(dataset['status']),
                                      ),
                                      if (_recentDatasets.indexOf(dataset) < _recentDatasets.take(3).length - 1)
                                        const Divider(height: 1),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ] else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              'No recent activity',
                              style: Theme.of(context).textTheme.bodyMedium,
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

  String _getStressCategory(double stressLevel) {
    if (stressLevel < 30) return 'Rendah';
    if (stressLevel < 60) return 'Sedang';
    return 'Tinggi';
  }

  IconData _getActivityIcon(String action) {
    switch (action) {
      case 'dataset_upload':
        return Icons.upload_file;
      case 'analysis_complete':
        return Icons.analytics;
      case 'employee_add':
        return Icons.person_add;
      case 'alert':
        return Icons.warning;
      case 'user_login':
        return Icons.login;
      case 'system_update':
        return Icons.system_update;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String action) {
    switch (action) {
      case 'dataset_upload':
        return Colors.blue;
      case 'analysis_complete':
        return Colors.green;
      case 'employee_add':
        return Colors.orange;
      case 'alert':
        return Colors.red;
      case 'user_login':
        return Colors.purple;
      case 'system_update':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'processed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'uploaded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatRelativeTime(String? timestamp) {
    if (timestamp == null) return 'Unknown time';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Baru saja';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} menit lalu';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else {
        return '${(difference.inDays / 7).floor()} minggu lalu';
      }
    } catch (e) {
      return timestamp;
    }
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Handle tap
      },
    );
  }


} 