import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/providers/admin_state_provider.dart';

class AdminEmployeesScreen extends StatefulWidget {
  const AdminEmployeesScreen({super.key});

  @override
  State<AdminEmployeesScreen> createState() => _AdminEmployeesScreenState();
}

class _AdminEmployeesScreenState extends State<AdminEmployeesScreen> {
  String _searchQuery = '';
  String _selectedDepartment = 'Semua';
  String _selectedStressLevel = 'Semua';
  bool _isLoading = true;
  List<dynamic> _employees = [];
  Map<String, dynamic>? _employeeStats;

  final List<String> _departments = [
    'Semua', 'IT', 'HR', 'Marketing', 'Finance', 'Operations'
  ];

  final List<String> _stressLevels = [
    'Semua', 'Admin', 'Employee'
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final adminState = Provider.of<AdminStateProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Load users (employees) instead of just employee records
      final result = await adminState.apiService.getUsers(
        search: _searchQuery,
        department: _selectedDepartment == 'Semua' ? '' : _selectedDepartment,
        role: _selectedStressLevel == 'Semua' ? '' : (_selectedStressLevel == 'Admin' ? 'admin' : 'employee'),
      );

      if (mounted) {
        setState(() {
          if (result['success']) {
            _employees = result['data']['users'] ?? [];
            _employeeStats = {
              'total_employees': result['data']['summary']['total_users'],
              'active_employees': result['data']['summary']['active_users'],
              'admin_users': result['data']['summary']['admin_users'],
              'employee_users': result['data']['summary']['employee_users'],
            };
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
          SnackBar(content: Text('Error loading users: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Manajemen Karyawan'),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari karyawan...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _debounceSearch();
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Departemen',
                          isDense: true,
                        ),
                        items: _departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value!;
                          });
                          _loadEmployeeData();
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStressLevel,
                        decoration: const InputDecoration(
                          labelText: 'User Role',
                          isDense: true,
                        ),
                        items: _stressLevels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStressLevel = value!;
                          });
                          _loadEmployeeData();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Statistics Summary
          Container(
            padding: const EdgeInsets.all(16.0),
            child:             Row(
              children: [
                Expanded(child: _buildStatCard(
                  'Total Users', 
                  _employeeStats?['total_employees']?.toString() ?? '0', 
                  Icons.people, 
                  Colors.blue
                )),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard(
                  'Active Users', 
                  _employeeStats?['active_employees']?.toString() ?? '0', 
                  Icons.check_circle, 
                  Colors.green
                )),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard(
                  'Admins', 
                  _employeeStats?['admin_users']?.toString() ?? '0', 
                  Icons.admin_panel_settings, 
                  Colors.purple
                )),
              ],
            ),
          ),
          
          // Employee List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildEmployeeList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEmployeeDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    if (_employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data karyawan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba ubah filter atau tambah data karyawan baru',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployeeData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
                          leading: CircleAvatar(
                backgroundColor: _getRoleColor(employee['role']),
                child: Text(
                  _getInitials(employee['full_name'] ?? 'U'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                employee['full_name'] ?? 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${employee['email'] ?? 'No email'}'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(employee['role']),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (employee['role'] ?? 'user').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!employee['is_active'])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'INACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${employee['department'] ?? 'No Dept'} • ${employee['position'] ?? 'No Position'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    'Datasets: ${employee['dataset_count'] ?? 0} • Joined: ${_formatRelativeTime(employee['created_at'])}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _showEmployeeDetails(employee);
                    break;
                  case 'edit':
                    _showEditEmployeeDialog(employee);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(employee);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('Lihat Detail'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Hapus', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
        },
      ),
    );
  }

  Timer? _debounceTimer;

  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadEmployeeData();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  String _getInitials(String fullName) {
    final words = fullName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'U';
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'employee':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStressCategory(double stressLevel) {
    if (stressLevel < 30) return 'Rendah';
    if (stressLevel < 60) return 'Sedang';
    return 'Tinggi';
  }

  Color _getStressColor(double stressLevel) {
    if (stressLevel < 30) return Colors.green;
    if (stressLevel < 60) return Colors.orange;
    return Colors.red;
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

  void _showEmployeeDetails(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Karyawan: ${employee['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${employee['id']}'),
            Text('Departemen: ${employee['department']}'),
            Text('Posisi: ${employee['position']}'),
            Text('Tingkat Stres: ${employee['stressLevel']}%'),
            Text('Kategori: ${employee['stressCategory']}'),
            Text('Update Terakhir: ${employee['lastUpdate']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Karyawan'),
        content: const Text('Fitur tambah karyawan akan diimplementasikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Karyawan: ${employee['name']}'),
        content: const Text('Fitur edit karyawan akan diimplementasikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus karyawan ${employee['employee_id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEmployee(employee['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEmployee(int employeeId) async {
    final adminState = Provider.of<AdminStateProvider>(context, listen: false);
    
    try {
      final result = await adminState.apiService.deleteEmployee(employeeId);
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karyawan berhasil dihapus')),
        );
        _loadEmployeeData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
} 