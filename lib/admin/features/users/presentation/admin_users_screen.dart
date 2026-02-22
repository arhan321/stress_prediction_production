import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/providers/admin_state_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchQuery = '';
  String _selectedDepartment = 'Semua';
  String _selectedRole = 'Semua';
  bool _activeOnly = true;
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _summary;
  int _currentPage = 1;
  int _totalPages = 1;
  
  final List<String> _departments = [
    'Semua',
    'IT',
    'Finance', 
    'HR',
    'Marketing',
    'Operations'
  ];
  
  final List<String> _roles = [
    'Semua',
    'admin',
    'employee'
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final adminState = Provider.of<AdminStateProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await adminState.apiService.getUsers(
        page: _currentPage,
        search: _searchQuery,
        role: _selectedRole == 'Semua' ? '' : _selectedRole,
        department: _selectedDepartment == 'Semua' ? '' : _selectedDepartment,
        activeOnly: _activeOnly,
      );

      if (result['success'] && mounted) {
        final data = result['data'];
        setState(() {
          _users = List<Map<String, dynamic>>.from(data['users'] ?? []);
          _summary = data['summary'];
          _totalPages = data['pagination']['pages'] ?? 1;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showError(result['error'] ?? 'Failed to load users');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Error loading users: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'User Management'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
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
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 1;
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
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role == 'Semua' ? 'All Roles' : role.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                            _currentPage = 1;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
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
                            _currentPage = 1;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Active/Inactive Users Filter
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _activeOnly ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _activeOnly ? Colors.green : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _activeOnly ? Icons.visibility : Icons.visibility_off,
                        color: _activeOnly ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _activeOnly ? 'Showing: Active Users Only' : 'Showing: All Users (Active + Inactive)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _activeOnly 
                                ? 'Deactivated users are hidden. Toggle to see all users.' 
                                : 'Including deactivated users. Toggle to show active only.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _activeOnly,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            _activeOnly = value;
                            _currentPage = 1;
                          });
                          _loadUsers();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Statistics Summary
          if (_summary != null)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard(
                    'Total Users', 
                    _summary!['total_users']?.toString() ?? '0', 
                    Icons.people, 
                    Colors.blue
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard(
                    'Active', 
                    _summary!['active_users']?.toString() ?? '0', 
                    Icons.check_circle, 
                    Colors.green
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard(
                    'Inactive', 
                    ((_summary!['total_users'] ?? 0) - (_summary!['active_users'] ?? 0)).toString(), 
                    Icons.block, 
                    Colors.orange
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard(
                    'Admins', 
                    _summary!['admin_users']?.toString() ?? '0', 
                    Icons.admin_panel_settings, 
                    Colors.purple
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard(
                    'Employees', 
                    _summary!['employee_users']?.toString() ?? '0', 
                    Icons.person, 
                    Colors.orange
                  )),
                ],
              ),
            ),
          
          // User List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildUserList(),
          ),
          
          // Pagination
          if (_totalPages > 1)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentPage > 1 ? () {
                      setState(() {
                        _currentPage--;
                      });
                      _loadUsers();
                    } : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                  ),
                  Text('Page $_currentPage of $_totalPages'),
                  TextButton.icon(
                    onPressed: _currentPage < _totalPages ? () {
                      setState(() {
                        _currentPage++;
                      });
                      _loadUsers();
                    } : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),
        ],
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

  Widget _buildUserList() {
    if (_users.isEmpty) {
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
              'No users found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: _getRoleColor(user['role']),
                child: Text(
                  _getInitials(user['full_name'] ?? 'U'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                user['full_name'] ?? 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email'] ?? ''),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user['role']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (user['role'] ?? '').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!user['is_active'])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'INACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (user['department'] != null)
                    Text(
                      '${user['department']} • ${user['position'] ?? 'No Position'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${user['dataset_count'] ?? 0} datasets',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.expand_more),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Username', user['username']),
                      _buildDetailRow('Phone', user['phone_number'] ?? 'Not provided'),
                      _buildDetailRow('Created', _formatDateTime(user['created_at'])),
                      _buildDetailRow('Last Login', _formatDateTime(user['last_login'])),
                      _buildDetailRow('Email Verified', user['email_verified'] ? 'Yes' : 'No'),
                      
                      const SizedBox(height: 16),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _viewUserDatasets(user),
                              icon: const Icon(Icons.dataset, size: 16),
                              label: const Text('View Datasets'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showUserActions(user),
                              icon: const Icon(Icons.more_horiz, size: 16),
                              label: const Text('More'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
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

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'U';
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'Never';
    
    try {
      final dt = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}d ago';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (e) {
      return dateTime;
    }
  }

  void _viewUserDatasets(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDatasetsScreen(user: user),
      ),
    );
  }

  void _showUserActions(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions for ${user['full_name']}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit User'),
              onTap: () {
                Navigator.pop(context);
                _editUser(user);
              },
            ),
            ListTile(
              leading: Icon(
                user['is_active'] ? Icons.block : Icons.check_circle,
                color: user['is_active'] ? Colors.orange : Colors.green,
              ),
              title: Text(user['is_active'] ? 'Deactivate User (Hide from Active List)' : 'Reactivate User'),
              subtitle: Text(
                user['is_active'] 
                  ? 'User data preserved, login disabled' 
                  : 'Restore user access and visibility',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleUserStatus(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Reset Password'),
              onTap: () {
                Navigator.pop(context);
                _resetUserPassword(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    final fullNameController = TextEditingController(text: user['full_name']);
    final emailController = TextEditingController(text: user['email']);
    final departmentController = TextEditingController(text: user['department'] ?? '');
    final positionController = TextEditingController(text: user['position'] ?? '');
    final phoneController = TextEditingController(text: user['phone_number'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          String selectedRole = user['role'] ?? 'employee';
          
          return AlertDialog(
            title: Text('Edit User: ${user['full_name']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: ['admin', 'employee'].map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: positionController,
                    decoration: const InputDecoration(
                      labelText: 'Position',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final adminState = Provider.of<AdminStateProvider>(context, listen: false);
                  
                  final userData = {
                    'full_name': fullNameController.text.trim(),
                    'email': emailController.text.trim(),
                    'role': selectedRole,
                    'department': departmentController.text.trim(),
                    'position': positionController.text.trim(),
                    'phone_number': phoneController.text.trim(),
                  };

                  Navigator.pop(context);

                  final result = await adminState.apiService.updateUser(user['id'], userData);

                  if (result['success'] && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadUsers();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['error'] ?? 'Failed to update user'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    final action = user['is_active'] ? 'deactivate' : 'activate';
    final isDeactivating = user['is_active'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isDeactivating ? Icons.block : Icons.check_circle,
              color: isDeactivating ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 8),
            Text('${action[0].toUpperCase()}${action.substring(1)} User'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to $action ${user['full_name']}?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (isDeactivating) ...[
              const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Text('What happens when deactivating:',
                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('• User data remains in database', style: TextStyle(fontSize: 12)),
              const Text('• User cannot login to the app', style: TextStyle(fontSize: 12)),
              const Text('• User disappears from active users list', style: TextStyle(fontSize: 12)),
              const Text('• Can be reactivated anytime', style: TextStyle(fontSize: 12)),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.info, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text('Reactivating user:',
                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('• User can login again', style: TextStyle(fontSize: 12)),
              const Text('• User appears in active users list', style: TextStyle(fontSize: 12)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final adminState = Provider.of<AdminStateProvider>(context, listen: false);
              
              Navigator.pop(context);

              final result = await adminState.apiService.toggleUserStatus(user['id']);

              if (result['success'] && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User ${action}d successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadUsers();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['error'] ?? 'Failed to $action user'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user['is_active'] ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('${action[0].toUpperCase()}${action.substring(1)}'),
          ),
        ],
      ),
    );
  }

  void _resetUserPassword(Map<String, dynamic> user) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password: ${user['full_name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 6 characters'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (passwordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final adminState = Provider.of<AdminStateProvider>(context, listen: false);
              
              Navigator.pop(context);

              final result = await adminState.apiService.resetUserPassword(
                user['id'], 
                passwordController.text
              );

              if (result['success'] && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['error'] ?? 'Failed to reset password'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final fullNameController = TextEditingController();
    final departmentController = TextEditingController();
    final positionController = TextEditingController();
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          String selectedRole = 'employee';
          
          return AlertDialog(
            title: const Text('Add New User'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username *',
                        border: OutlineInputBorder(),
                        hintText: 'Enter username (min 3 characters)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                        hintText: 'Enter email address',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password *',
                        border: OutlineInputBorder(),
                        hintText: 'Enter password (min 6 characters)',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password *',
                        border: OutlineInputBorder(),
                        hintText: 'Confirm password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        border: OutlineInputBorder(),
                        hintText: 'Enter full name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role *',
                        border: OutlineInputBorder(),
                      ),
                      items: ['admin', 'employee'].map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: departmentController,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                        hintText: 'Enter department (optional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: positionController,
                      decoration: const InputDecoration(
                        labelText: 'Position',
                        border: OutlineInputBorder(),
                        hintText: 'Enter position (optional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        hintText: 'Enter phone number (optional)',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '* Required fields',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validate required fields
                  if (usernameController.text.trim().isEmpty ||
                      emailController.text.trim().isEmpty ||
                      passwordController.text.isEmpty ||
                      fullNameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Validate username length
                  if (usernameController.text.trim().length < 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Username must be at least 3 characters'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Validate password length
                  if (passwordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password must be at least 6 characters'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Validate password confirmation
                  if (passwordController.text != confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Passwords do not match'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Validate email format
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(emailController.text.trim())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid email address'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final adminState = Provider.of<AdminStateProvider>(context, listen: false);
                  
                  final userData = {
                    'username': usernameController.text.trim(),
                    'email': emailController.text.trim(),
                    'password': passwordController.text,
                    'full_name': fullNameController.text.trim(),
                    'role': selectedRole,
                    'department': departmentController.text.trim().isEmpty ? null : departmentController.text.trim(),
                    'position': positionController.text.trim().isEmpty ? null : positionController.text.trim(),
                    'phone_number': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  };

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  final result = await adminState.apiService.createUser(userData);

                  // Close loading dialog
                  Navigator.pop(context);
                  
                  if (result['success'] && mounted) {
                    // Close the add user dialog
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ User "${fullNameController.text.trim()}" created successfully!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    _loadUsers(); // Refresh the user list
                  } else {
                    // Show detailed error message but keep dialog open
                    String errorMessage = result['error'] ?? 'Failed to create user';
                    
                    // Show error as an alert dialog with more details
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Error Creating User'),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Failed to create user. Please check the following:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('• $errorMessage'),
                            const SizedBox(height: 8),
                            const Text('Common issues:'),
                            const Text('• Username or email might already exist'),
                            const Text('• Make sure all required fields are filled'),
                            const Text('• Check your internet connection'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create User'),
              ),
            ],
          );
        },
      ),
    );
  }

  Timer? _debounceTimer;

  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// User Datasets Screen
class UserDatasetsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserDatasetsScreen({super.key, required this.user});

  @override
  State<UserDatasetsScreen> createState() => _UserDatasetsScreenState();
}

class _UserDatasetsScreenState extends State<UserDatasetsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _datasets = [];
  String _selectedStatus = 'Semua';
  
  final List<String> _statuses = [
    'Semua',
    'uploaded',
    'processing', 
    'processed',
    'failed'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserDatasets();
  }

  Future<void> _loadUserDatasets() async {
    final adminState = Provider.of<AdminStateProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await adminState.apiService.getUserDatasets(
        widget.user['id'],
        status: _selectedStatus == 'Semua' ? '' : _selectedStatus,
      );

      if (result['success'] && mounted) {
        final data = result['data'];
        setState(() {
          _datasets = List<Map<String, dynamic>>.from(data['datasets'] ?? []);
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to load datasets'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datasets by ${widget.user['full_name']}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter
          Container(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: _statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status == 'Semua' ? 'All Statuses' : status.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
                _loadUserDatasets();
              },
            ),
          ),
          
          // Dataset List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildDatasetList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDatasetList() {
    if (_datasets.isEmpty) {
      return const Center(
        child: Text('No datasets found for this user'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _datasets.length,
      itemBuilder: (context, index) {
        final dataset = _datasets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(dataset['status']),
              child: Text(
                dataset['status']?.substring(0, 1).toUpperCase() ?? 'D',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              dataset['name'] ?? 'Unknown Dataset',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dataset['description'] ?? 'No description'),
                const SizedBox(height: 4),
                Text('Records: ${dataset['record_count'] ?? 0}'),
                Text('Uploaded: ${_formatDateTime(dataset['upload_date'])}'),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(dataset['status']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (dataset['status'] ?? 'unknown').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to dataset details
            },
          ),
        );
      },
    );
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

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'Unknown';
    
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return dateTime;
    }
  }
} 