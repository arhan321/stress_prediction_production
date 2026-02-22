import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/chart_card.dart';
import '../../../shared/providers/admin_state_provider.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  String _selectedPeriod = '30 Hari';
  String _selectedDepartment = 'Semua Departemen';
  bool _isLoading = true;
  Map<String, dynamic>? _analyticsData;
  List<dynamic>? _insights;
  List<dynamic>? _recommendations;

  final List<String> _periods = ['7 Hari', '30 Hari', '90 Hari', '1 Tahun'];
  final List<String> _departments = [
    'Semua Departemen',
    'IT',
    'HR',
    'Marketing',
    'Finance',
    'Operations'
  ];

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    final adminState = Provider.of<AdminStateProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        adminState.apiService.getDashboardStats(),
        adminState.apiService.getUsers(limit: 50),
        adminState.apiService.getDatasets(limit: 50),
      ]);

      if (mounted) {
        setState(() {
          if (results[0]['success']) {
            _analyticsData = results[0]['data']['stats'];
          }

          // Generate insights from real data
          _insights = _generateInsights(results[0]['data']['stats']);

          // Generate recommendations from real data
          _recommendations =
              _generateRecommendations(results[0]['data']['stats']);

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: ${e.toString()}')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _generateInsights(Map<String, dynamic> stats) {
    final userStats = stats['users'];
    final datasetStats = stats['datasets'];

    return [
      {
        'title': 'Total System Users',
        'value': '${userStats['total']}',
        'description':
            '${userStats['active']} active users currently in system',
        'type': 'users',
        'is_positive': userStats['active'] > 0,
      },
      {
        'title': 'Dataset Processing Rate',
        'value':
            '${datasetStats['success_rate']?.toStringAsFixed(1) ?? '0.0'}%',
        'description':
            '${datasetStats['processed']} of ${datasetStats['total']} datasets processed successfully',
        'type': 'processing',
        'is_positive': (datasetStats['success_rate'] ?? 0) > 80,
      },
      {
        'title': 'Admin Coverage',
        'value': '${userStats['admins']}',
        'description':
            'System administrators managing ${userStats['employees']} employees',
        'type': 'admin',
        'is_positive': userStats['admins'] > 0,
      },
      {
        'title': 'Data Availability',
        'value': '${datasetStats['total']}',
        'description': 'Total datasets available for analysis',
        'type': 'data',
        'is_positive': datasetStats['total'] > 0,
      },
    ];
  }

  List<Map<String, dynamic>> _generateRecommendations(
      Map<String, dynamic> stats) {
    final recommendations = <Map<String, dynamic>>[];
    final userStats = stats['users'];
    final datasetStats = stats['datasets'];

    // Check if we need more admins
    if (userStats['admins'] < (userStats['total'] / 10)) {
      recommendations.add({
        'priority': 'High',
        'title': 'Consider Adding More Administrators',
        'description':
            'Current admin-to-user ratio is low. Consider promoting qualified users to admin role.',
        'timeline': 'This week',
        'impact': 'Improved system management efficiency',
      });
    }

    // Check dataset processing efficiency
    if (datasetStats['failed'] > 0) {
      recommendations.add({
        'priority': 'Medium',
        'title': 'Address Failed Dataset Processing',
        'description':
            '${datasetStats['failed']} datasets failed processing. Review data quality guidelines.',
        'timeline': 'Next week',
        'impact': 'Better data quality and processing success rate',
      });
    }

    // Check for inactive users
    if (userStats['inactive'] > 0) {
      recommendations.add({
        'priority': 'Low',
        'title': 'Review Inactive User Accounts',
        'description':
            '${userStats['inactive']} inactive users found. Consider account cleanup.',
        'timeline': 'This month',
        'impact': 'Improved system security and maintenance',
      });
    }

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Analytics & Insights'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalyticsData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedPeriod,
                                decoration: const InputDecoration(
                                  labelText: 'Periode',
                                  isDense: true,
                                ),
                                items: _periods.map((period) {
                                  return DropdownMenuItem(
                                    value: period,
                                    child: Text(period),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPeriod = value!;
                                  });
                                  _loadAnalyticsData();
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
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
                                  _loadAnalyticsData();
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _exportReport,
                              icon: const Icon(Icons.download),
                              label: const Text('Export'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Key Insights
                    Text(
                      'Key Insights',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 16),

                    if (_insights != null && _insights!.isNotEmpty)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: _insights!.take(4).map((insight) {
                          return _buildInsightCard(
                            insight['title'] ?? 'No Title',
                            insight['value'] ?? 'No Value',
                            insight['description'] ?? 'No Description',
                            _getInsightIcon(insight['type']),
                            _getInsightColor(insight['type']),
                            insight['is_positive'] ?? false,
                          );
                        }).toList(),
                      )
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Tidak ada insights tersedia',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Charts Section
                    Text(
                      'Visualisasi Data',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 16),

                    const Row(
                      children: [
                        Expanded(
                          child: ChartCard(
                            title: 'Distribusi Stres per Departemen',
                            chartType: 'pie',
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ChartCard(
                            title: 'Tren Stres 30 Hari Terakhir',
                            chartType: 'line',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Row(
                      children: [
                        Expanded(
                          child: ChartCard(
                            title: 'Faktor Penyebab Stres',
                            chartType: 'bar',
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ChartCard(
                            title: 'Perbandingan Antar Departemen',
                            chartType: 'bar',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Recommendations
                    Text(
                      'Rekomendasi Berdasarkan Data',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 16),

                    if (_recommendations != null &&
                        _recommendations!.isNotEmpty)
                      _buildRecommendationsList()
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              'Tidak ada rekomendasi tersedia',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Detailed Analysis
                    Text(
                      'Analisis Mendalam',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 16),

                    _buildDetailedAnalysis(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
    bool isPositive,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                if (isPositive)
                  Icon(Icons.trending_up, color: Colors.green, size: 16)
                else
                  Icon(Icons.info_outline, color: Colors.grey, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getInsightIcon(String? type) {
    switch (type) {
      case 'stress_level':
        return Icons.trending_down;
      case 'department_risk':
        return Icons.warning;
      case 'factor_analysis':
        return Icons.work;
      case 'prediction':
        return Icons.trending_up;
      default:
        return Icons.info;
    }
  }

  Color _getInsightColor(String? type) {
    switch (type) {
      case 'stress_level':
        return Colors.green;
      case 'department_risk':
        return Colors.red;
      case 'factor_analysis':
        return Colors.orange;
      case 'prediction':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRecommendationsList() {
    return Column(
      children: _recommendations!.map((rec) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(rec['priority'] as String)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        rec['priority'] as String,
                        style: TextStyle(
                          color: _getPriorityColor(rec['priority'] as String),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      rec['timeline'] as String? ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  rec['title'] as String? ?? 'No Title',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  rec['description'] as String? ?? 'No Description',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                if (rec['impact'] != null)
                  Row(
                    children: [
                      Icon(Icons.trending_up, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        rec['impact'] as String,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailedAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Korelasi Faktor Stres',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildCorrelationMatrix(),
            const SizedBox(height: 24),
            Text(
              'Prediksi Trend 3 Bulan Ke Depan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildPredictionChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationMatrix() {
    // final factors = ['Workload', 'Work-Life Balance', 'Team Conflict', 'Mgmt Support', 'Environment'];
    final factors = [
      'Workload',
      'Ketegangan dan Kesimbangan Kerja',
      'Team Conflict',
      'Mgmt Support',
      'Environment'
    ];

    return Table(
      children: [
        TableRow(
          children: [
            const Text(''),
            ...factors.map((f) => Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(f,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 10)),
                )),
          ],
        ),
        ...factors.map((rowFactor) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(rowFactor,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 10)),
              ),
              ...factors.map((colFactor) {
                final correlation = _getCorrelation(rowFactor, colFactor);
                return Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getCorrelationColor(correlation),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    correlation.toStringAsFixed(1),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPredictionChart() {
    return Container(
      height: 100,
      child: const ChartCard(
        title: '',
        chartType: 'line',
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double _getCorrelation(String factor1, String factor2) {
    // Mock correlation data
    if (factor1 == factor2) return 1.0;
    if ((factor1 == 'Workload' &&
            factor2 == 'Ketegangan dan Kesimbangan Kerja') ||
        (factor1 == 'Ketegangan dan Kesimbangan Kerja' &&
            factor2 == 'Workload')) return 0.8;
    if ((factor1 == 'Team Conflict' && factor2 == 'Mgmt Support') ||
        (factor1 == 'Mgmt Support' && factor2 == 'Team Conflict')) return -0.6;
    return 0.3; // Default correlation
  }

  Color _getCorrelationColor(double correlation) {
    if (correlation.abs() > 0.7) return Colors.red.shade200;
    if (correlation.abs() > 0.4) return Colors.orange.shade200;
    return Colors.green.shade200;
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Laporan'),
        content: const Text('Pilih format export:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Export as PDF
            },
            child: const Text('PDF'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Export as Excel
            },
            child: const Text('Excel'),
          ),
        ],
      ),
    );
  }
}
