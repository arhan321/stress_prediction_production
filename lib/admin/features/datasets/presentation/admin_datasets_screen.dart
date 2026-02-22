import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/providers/admin_state_provider.dart';

class AdminDatasetsScreen extends StatefulWidget {
  const AdminDatasetsScreen({super.key});

  @override
  State<AdminDatasetsScreen> createState() => _AdminDatasetsScreenState();
}

class _AdminDatasetsScreenState extends State<AdminDatasetsScreen> {
  String _selectedStatus = 'Semua';
  bool _isLoading = true;
  List<dynamic> _datasets = [];
  Map<String, dynamic>? _datasetStats;
  
  final List<String> _statuses = [
    'Semua', 'Uploaded', 'Processing', 'Processed', 'Failed'
  ];

  @override
  void initState() {
    super.initState();
    _loadDatasetData();
  }

  Future<void> _loadDatasetData() async {
    final adminState = Provider.of<AdminStateProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await adminState.apiService.getDatasets(
        status: _selectedStatus == 'Semua' ? '' : _selectedStatus.toLowerCase(),
      );

      if (mounted) {
        setState(() {
          if (result['success']) {
            _datasets = result['data']['datasets'] ?? [];
            _datasetStats = {
              'total_datasets': result['data']['summary']['total_datasets'],
              'processing_count': result['data']['summary']['by_status']['processing'] ?? 0,
              'processed_count': result['data']['summary']['by_status']['processed'] ?? 0,
              'uploaded_count': result['data']['summary']['by_status']['uploaded'] ?? 0,
              'failed_count': result['data']['summary']['by_status']['failed'] ?? 0,
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
          SnackBar(content: Text('Error loading datasets: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Manajemen Dataset'),
      body: Column(
        children: [
          // Header with stats and filter
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Stats Row
                Row(
                  children: [
                    Expanded(child: _buildStatCard(
                      'Total Dataset', 
                      _datasetStats?['total_datasets']?.toString() ?? '0', 
                      Icons.storage, 
                      Colors.blue
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard(
                      'Sedang Diproses', 
                      _datasetStats?['processing_count']?.toString() ?? '0', 
                      Icons.hourglass_empty, 
                      Colors.orange
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard(
                      'Siap Analisis', 
                      _datasetStats?['processed_count']?.toString() ?? '0', 
                      Icons.check_circle, 
                      Colors.green
                    )),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Filter
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Filter Status',
                    isDense: true,
                  ),
                  items: _statuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _loadDatasetData();
                  },
                ),
              ],
            ),
          ),
          
          // Dataset List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadDatasetData,
                  child: _buildDatasetList(),
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

  Widget _buildDatasetList() {
    if (_datasets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada dataset',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada dataset yang tersedia untuk dianalisis',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _datasets.length,
      itemBuilder: (context, index) {
        final dataset = _datasets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dataset['name'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusChip(dataset['status'] as String),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Description and Uploader
                Text(
                  dataset['description'] ?? 'No description',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                
                const SizedBox(height: 8),
                
                // Uploader Information
                if (dataset['uploader'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Uploaded by: ${dataset['uploader']['full_name']} (${dataset['uploader']['role']})',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Details Row
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${dataset['record_count'] ?? 0} records'),
                    const SizedBox(width: 16),
                    Icon(Icons.storage, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(_formatFileSize(dataset['file_size'])),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(_formatDate(dataset['upload_date'])),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Action Buttons Row
                Row(
                  children: [
                    if (dataset['status'] == 'processed') ...[
                      ElevatedButton.icon(
                        onPressed: () => _runAnalysis(dataset),
                        icon: const Icon(Icons.analytics, size: 16),
                        label: const Text('Analisis'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ] else if (dataset['status'] == 'processing') ...[
                      OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.hourglass_empty, size: 16),
                        label: const Text('Memproses...'),
                      ),
                    ] else if (dataset['status'] == 'failed') ...[
                      ElevatedButton.icon(
                        onPressed: () => _retryProcessing(dataset),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                    
                    const Spacer(),
                    
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'download':
                            _downloadDataset(dataset);
                            break;
                          case 'delete':
                            _deleteDataset(dataset);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'download',
                          child: ListTile(
                            leading: Icon(Icons.download),
                            title: Text('Download'),
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
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'Processed':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case 'Processing':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.hourglass_empty;
        break;
      case 'Failed':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.error;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.storage;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _runAnalysis(Map<String, dynamic> dataset) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jalankan Analisis'),
        content: Text('Menjalankan analisis untuk dataset "${dataset['name']}"?\n\nProses ini membutuhkan waktu beberapa menit.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Jalankan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final adminState = Provider.of<AdminStateProvider>(context, listen: false);
      
      try {
        final result = await adminState.apiService.runAnalysis(dataset['id']);
        
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Analisis dimulai. Anda akan mendapat notifikasi saat selesai.')),
          );
          _loadDatasetData(); // Refresh data
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

  void _retryProcessing(Map<String, dynamic> dataset) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mencoba ulang pemrosesan ${dataset['name']}')),
    );
  }

  void _downloadDataset(Map<String, dynamic> dataset) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mengunduh ${dataset['name']}')),
    );
  }

  Future<void> _deleteDataset(Map<String, dynamic> dataset) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus dataset "${dataset['name']}"?\n\nTindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final adminState = Provider.of<AdminStateProvider>(context, listen: false);
      
      try {
        final result = await adminState.apiService.deleteDataset(dataset['id']);
        
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dataset berhasil dihapus')),
          );
          _loadDatasetData(); // Refresh data
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


} 