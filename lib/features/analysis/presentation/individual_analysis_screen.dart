import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/auth_api_service.dart';

class IndividualAnalysisScreen extends StatefulWidget {
  const IndividualAnalysisScreen({super.key});

  @override
  State<IndividualAnalysisScreen> createState() =>
      _IndividualAnalysisScreenState();
}

class _IndividualAnalysisScreenState extends State<IndividualAnalysisScreen> {
  String? _selectedDatasetId;
  String _selectedDatasetName = '';
  String? _selectedEmployee;
  Map<String, dynamic>? _employeeData;
  Map<String, dynamic>? _stressAnalysis;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _availableDatasets = [];
  List<Map<String, dynamic>> _employeeList = [];
  String? _error;
  String _renameFactor(String factor) {
    switch (factor) {
      case 'Work-Life Balance':
        return 'Ketegangan dan Kesimbangan Kerja';
      default:
        return factor;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeApiAndLoadDatasets();
  }

  Future<void> _initializeApiAndLoadDatasets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Initialize API with mock token for development
      await AuthApiService.mockLogin();

      // Load datasets
      await _loadDatasets();
    } catch (e) {
      setState(() {
        _error = 'Gagal menginisialisasi aplikasi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDatasets() async {
    try {
      final response = await AuthApiService.getDatasets();

      if (response['success'] == true && response['datasets'] != null) {
        setState(() {
          _availableDatasets =
              List<Map<String, dynamic>>.from(response['datasets']);
          // Auto-select first dataset if available
          if (_availableDatasets.isNotEmpty) {
            final firstDataset = _availableDatasets.first;
            _selectedDatasetId = firstDataset['id'].toString();
            _selectedDatasetName = firstDataset['name'];
            // Load employees for the first dataset
            _loadEmployeeList();
          }
        });
      } else {
        throw Exception('Failed to load datasets from API');
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat daftar dataset: $e';
      });
      print('Error loading datasets: $e');
    }
  }

  Future<void> _loadEmployeeList() async {
    if (_selectedDatasetId == null) return;

    setState(() {
      _isLoading = true;
      _employeeList = [];
      _selectedEmployee = null;
      _employeeData = null;
      _stressAnalysis = null;
      _error = null;
    });

    try {
      final datasetId = int.parse(_selectedDatasetId!);
      final response = await AuthApiService.getDatasetEmployees(datasetId);

      if (response['success'] == true && response['employees'] != null) {
        setState(() {
          _employeeList =
              List<Map<String, dynamic>>.from(response['employees']);
        });
        print(
            'Loaded ${_employeeList.length} employees from dataset $datasetId');
      } else {
        throw Exception('Failed to load employees from API');
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat daftar karyawan: $e';
      });
      print('Error loading employee list: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeEmployee(String employeeId) async {
    if (_selectedDatasetId == null) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final datasetId = int.parse(_selectedDatasetId!);
      final response =
          await AuthApiService.analyzeEmployee(datasetId, employeeId);

      print('=== ANALYSIS RESPONSE DEBUG ===');
      print('Response: $response');
      print('Success: ${response['success']}');
      print('Employee Info: ${response['employee_info']}');
      print('Stress Analysis: ${response['stress_analysis']}');
      print('Risk Factors: ${response['risk_factors']}');
      print('===============================');

      if (response['success'] == true) {
        setState(() {
          _employeeData = response['employee_info'];
          _stressAnalysis = response;
        });
        print('✅ Analysis completed for employee $employeeId');
        print('✅ Employee data set: ${_employeeData != null}');
        print('✅ Stress analysis set: ${_stressAnalysis != null}');
        print('✅ Stress analysis keys: ${_stressAnalysis?.keys}');
      } else {
        throw Exception(
            'Failed to analyze employee: ${response['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ Error analyzing employee: $e');
      setState(() {
        _error = 'Gagal menganalisis karyawan: $e';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: AppTheme.primaryColor,
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: const Center(
        //       child: Text(
        //         'WORK',
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontSize: 10,
        //           fontWeight: FontWeight.bold,
        //           letterSpacing: 0.5,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: Image.asset(
              'asset/images/LWS.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: const Text(AppConstants.analisisPerOrang),
        centerTitle: true,
      ),
      body: _error != null
          ? _buildErrorState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dataset Selection
                  _buildDatasetSelection(),

                  const SizedBox(height: 16),

                  // Employee Selection
                  _buildEmployeeSelection(),

                  if (_selectedEmployee != null) ...[
                    const SizedBox(height: 16),

                    // Employee Info Card
                    if (_employeeData != null) _buildEmployeeInfoCard(),

                    const SizedBox(height: 16),

                    // Stress Analysis Results
                    if (_stressAnalysis != null) _buildStressAnalysisCard(),

                    const SizedBox(height: 16),

                    // Risk Factors
                    if (_stressAnalysis != null) _buildRiskFactorsCard(),

                    const SizedBox(height: 16),

                    // Recommendations
                    if (_stressAnalysis != null) _buildRecommendationsCard(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeApiAndLoadDatasets,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatasetSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dataset,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pilih Dataset',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_availableDatasets.isEmpty && _isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_availableDatasets.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Center(
                  child: Text(
                    'Tidak ada dataset tersedia.\nSilakan upload dataset terlebih dahulu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDatasetId,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppTheme.textSecondary),
                    isExpanded: true,
                    items: _availableDatasets.map((dataset) {
                      return DropdownMenuItem<String>(
                        value: dataset['id'].toString(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dataset['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (dataset['description'] != null)
                              Text(
                                dataset['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != _selectedDatasetId) {
                        final selectedDataset = _availableDatasets.firstWhere(
                          (dataset) => dataset['id'].toString() == newValue,
                        );
                        setState(() {
                          _selectedDatasetId = newValue;
                          _selectedDatasetName = selectedDataset['name'];
                          _selectedEmployee = null;
                          _employeeData = null;
                          _stressAnalysis = null;
                        });
                        _loadEmployeeList();
                      }
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_search,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pilih Karyawan untuk Analisis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_employeeList.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Center(
                  child: Text(
                    'Tidak ada data karyawan.\nPilih dataset yang valid.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedEmployee,
                    hint: Text(
                        'Pilih karyawan... (${_employeeList.length} tersedia)'),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppTheme.textSecondary),
                    isExpanded: true,
                    items: _employeeList.map((employee) {
                      return DropdownMenuItem<String>(
                        value: employee['employee_id'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              employee['name'] ??
                                  'Employee ${employee['employee_id']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${employee['employee_id']} • ${employee['department']} • ${employee['position'] ?? 'Staff'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedEmployee = newValue;
                        });
                        _analyzeEmployee(newValue);
                      }
                    },
                  ),
                ),
              ),
              if (_selectedEmployee != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _isAnalyzing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryColor,
                              size: 16,
                            ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isAnalyzing
                              ? 'Menganalisis data karyawan...'
                              : 'Analisis untuk karyawan terpilih telah selesai.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeInfoCard() {
    if (_employeeData == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.badge,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Informasi Karyawan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                'Nama',
                _employeeData!['name'] ??
                    'Employee ${_employeeData!['employee_id']}'),
            _buildInfoRow('ID Karyawan', _employeeData!['employee_id']),
            _buildInfoRow('Departemen', _employeeData!['department']),
            _buildInfoRow('Posisi', _employeeData!['position'] ?? 'Staff'),
            _buildInfoRow('Usia', '${_employeeData!['age']} tahun'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Data Faktor Stres:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildFactorRow(
                'Beban Kerja', _employeeData!['workload']?.toDouble() ?? 0.0),
            _buildFactorRow('Ketegangan dan Kesimbangan Kerja',
                _employeeData!['work_life_balance']?.toDouble() ?? 0.0),
            _buildFactorRow('Konflik Tim',
                _employeeData!['team_conflict']?.toDouble() ?? 0.0),
            _buildFactorRow('Dukungan Manajemen',
                _employeeData!['management_support']?.toDouble() ?? 0.0),
            _buildFactorRow('Lingkungan Kerja',
                _employeeData!['work_environment']?.toDouble() ?? 0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const Text(': '),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 10,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                value >= 7
                    ? Colors.red
                    : value >= 5
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressAnalysisCard() {
    if (_stressAnalysis == null) {
      return const SizedBox.shrink();
    }

    // Check if stress_analysis is nested or directly available
    final stressData = _stressAnalysis!['stress_analysis'] ?? _stressAnalysis!;
    final stressLevel = stressData['stress_level']?.toDouble() ?? 0.0;
    final category = stressData['stress_category'] ?? 'Unknown';
    final confidence = stressData['prediction_confidence']?.toDouble() ?? 0.0;
    final deptAverage = stressData['department_average']?.toDouble() ?? 0.0;
    final comparison = stressData['compared_to_department'] ?? '';

    // If no stress level data, don't show the card
    if (stressLevel == 0.0 && category == 'Unknown') {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Hasil Analisis Stres',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stress Level Circle
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: stressLevel / 100,
                              strokeWidth: 8,
                              backgroundColor: AppTheme.borderColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getStressColor(stressLevel),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${stressLevel.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getStressColor(stressLevel),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tingkat Kepercayaan: ${confidence.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Vs Departemen (${deptAverage.toStringAsFixed(1)}%): $comparison',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskFactorsCard() {
    if (_stressAnalysis == null || _stressAnalysis!['risk_factors'] == null) {
      return const SizedBox.shrink();
    }

    final riskFactors =
        List<Map<String, dynamic>>.from(_stressAnalysis!['risk_factors']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Faktor Risiko',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...riskFactors.map((factor) => _buildRiskFactorItem(factor)),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskFactorItem(Map<String, dynamic> factor) {
    final value = factor['value']?.toDouble() ?? 0.0;
    final impact = factor['impact'] ?? 'Unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(
              //   factor['factor'] ?? 'Unknown Factor',
              //   style: const TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              Text(
                _renameFactor(factor['factor'] ?? 'Unknown Factor'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getImpactColor(impact).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  impact,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getImpactColor(impact),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value / 10,
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(_getImpactColor(impact)),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '10',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    if (_stressAnalysis == null || _stressAnalysis!['risk_factors'] == null) {
      return const SizedBox.shrink();
    }

    final riskFactors =
        List<Map<String, dynamic>>.from(_stressAnalysis!['risk_factors']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rekomendasi Intervensi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_stressAnalysis!['recommendations_summary'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  _stressAnalysis!['recommendations_summary'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade800,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ...riskFactors.asMap().entries.map((entry) {
              final index = entry.key;
              final factor = entry.value;
              return _buildRecommendationItem(index + 1, factor);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(int number, Map<String, dynamic> factor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   factor['factor'] ?? 'Unknown Factor',
                //   style: const TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
                Text(
                  _renameFactor(factor['factor'] ?? 'Unknown Factor'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  factor['recommendation'] ?? 'No recommendation available',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStressColor(double stressLevel) {
    if (stressLevel <= 30) {
      return Colors.green;
    } else if (stressLevel <= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getImpactColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'rendah':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'tinggi':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }
}
