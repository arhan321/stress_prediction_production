import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/services/auth_api_service.dart';

class UploadDatasetScreen extends StatefulWidget {
  const UploadDatasetScreen({super.key});

  @override
  State<UploadDatasetScreen> createState() => _UploadDatasetScreenState();
}

class _UploadDatasetScreenState extends State<UploadDatasetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedFileName;
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Dataset'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // Dataset Name Field
                _buildDatasetNameField(),
                
                const SizedBox(height: 24),
                
                // Description Field
                _buildDescriptionField(),
                
                const SizedBox(height: 24),
                
                // File Upload Section
                _buildFileUploadSection(),
                
                const SizedBox(height: 32),
                
                // Upload Button
                _buildUploadButton(),
                
                const SizedBox(height: 16),
                
                // Download Template Button
                _buildDownloadTemplateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Dataset',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Unggah dataset karyawan Anda untuk dianalisis tingkat stresnya',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDatasetNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nama Dataset',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Contoh: Data Karyawan Q2 2024',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama dataset tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi (Opsional)',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Deskripsikan dataset ini',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Dataset (Excel atau CSV)',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        
        // File Selection Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: _pickFile,
            child: Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFileName ?? 'Pilih File',
                        style: TextStyle(
                          color: _selectedFileName != null 
                              ? AppTheme.textPrimary 
                              : AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: _selectedFileName != null 
                              ? FontWeight.w500 
                              : FontWeight.w400,
                        ),
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${_formatFileSize(_selectedFile!.size)} • ${_selectedFile!.extension?.toUpperCase() ?? 'Unknown'} file',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_selectedFileName != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _clearFile,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Format Information
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Text(
            'Format data harus memiliki kolom: employee_id, department, workload, work_life_balance, team_conflict, management_support, work_environment, stress_level',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isUploading || _selectedFile == null ? null : _uploadDataset,
        child: _isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Upload Dataset'),
      ),
    );
  }

  Widget _buildDownloadTemplateButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _downloadTemplate,
        icon: const Icon(Icons.download_outlined),
        label: const Text('Download Template Dataset'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.primaryColor),
          foregroundColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  void _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _selectedFileName = result.files.first.name;
        });
      }
    } catch (e) {
      _showErrorMessage('Gagal memilih file: ${e.toString()}');
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
    });
  }

  void _uploadDataset() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get user token
      final user = context.read<AppStateProvider>().currentUser;
      final token = user?['token'];

      if (token == null) {
        _showErrorMessage('Authentication required. Please login again.');
        return;
      }

      // Handle file upload for both web and mobile/desktop platforms
      String? filePath;
      List<int>? fileBytes;
      
      // Use proper platform detection
      if (kIsWeb) {
        // On web, always use bytes
        fileBytes = _selectedFile!.bytes;
        if (fileBytes == null) {
          _showErrorMessage('Unable to read file content. Please try selecting the file again.');
          return;
        }
      } else {
        // On mobile/desktop, use file path
        filePath = _selectedFile!.path;
        if (filePath == null || filePath.isEmpty) {
          _showErrorMessage('Unable to access file path. Please try selecting the file again.');
          return;
        }
      }

      print('📤 Starting dataset upload...');
      print('📊 File: ${_selectedFile!.name}');
      print('💾 Size: ${_formatFileSize(_selectedFile!.size)}');

      // Upload the dataset using the API
      final result = await AuthApiService.uploadDataset(
        token: token,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: _selectedFile!.name,
        datasetName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      print('📋 Upload result: ${result}');

      if (mounted) {
        if (result['success'] == true) {
          // Show success message with details
          final dataset = result['dataset'];
          
          final successMessage = dataset != null 
              ? 'Dataset "${_nameController.text}" uploaded successfully!\nRecords: ${dataset['record_count']} • Added: ${dataset['employees_added']} • Updated: ${dataset['employees_updated']}'
              : 'Dataset "${_nameController.text}" uploaded successfully!';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: AppTheme.secondaryColor,
              duration: const Duration(seconds: 4),
            ),
          );

          print('✅ Upload successful - returning to dashboard with refresh flag');
          
          // Navigate back to dashboard with success flag to trigger refresh
          Navigator.of(context).pop(true); // Return true to indicate successful upload
        } else {
          final errorMessage = result['message'] ?? 'Upload failed';
          print('❌ Upload failed: $errorMessage');
          _showErrorMessage(errorMessage);
        }
      }

    } catch (e) {
      print('❌ Upload exception: ${e.toString()}');
      _showErrorMessage('Upload error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _downloadTemplate() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mengunduh template dataset...'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );

      // Call the API to get template
      final result = await AuthApiService.downloadTemplate();

      if (result['success'] == true) {
        final Uint8List fileBytes = result['data'];
        final String filename = result['filename'];

        if (kIsWeb) {
          // For web platform - use blob download
          _downloadFileWeb(fileBytes, filename);
        } else {
          // For mobile/desktop - save to downloads folder
          await _downloadFileMobile(fileBytes, filename);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template "$filename" berhasil diunduh!'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
        }
      } else {
        _showErrorMessage('Gagal mengunduh template: ${result['message']}');
      }
    } catch (e) {
      _showErrorMessage('Error mengunduh template: ${e.toString()}');
    }
  }

  void _downloadFileWeb(Uint8List bytes, String filename) {
    if (kIsWeb) {
      // Show template content in dialog for web compatibility
      _showTemplateDialog(bytes, filename);
    }
  }

  Future<void> _downloadFileMobile(Uint8List bytes, String filename) async {
    try {
      // For mobile/desktop, show the content in a dialog
      _showTemplateDialog(bytes, filename);
    } catch (e) {
      _showErrorMessage('Error processing file: ${e.toString()}');
    }
  }

  void _showTemplateDialog(Uint8List bytes, String filename) {
    final content = String.fromCharCodes(bytes);
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.download, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Template Dataset',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Salin konten di bawah dan simpan sebagai file CSV dengan nama: $filename',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[50],
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          content,
                          style: const TextStyle(
                            fontFamily: 'monospace', 
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Template "$filename" siap disalin! Buat file CSV baru dan paste konten ini.'),
                      backgroundColor: AppTheme.secondaryColor,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Mengerti'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  String _formatFileSize(int size) {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
} 