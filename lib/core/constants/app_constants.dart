class AppConstants {
  // App Information
  static const String appName = 'Workplaze Stylizer';
  static const String companyName = 'Workplace Stress Analyzer';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://backend.djncloud.my.id';
  static const String apiVersion = 'v1';

  // Database Configuration
  static const String databaseName = 'stress_analysis.db';
  static const int databaseVersion = 1;

  // Navigation
  static const String homeRoute = '/home';
  static const String uploadRoute = '/upload';
  static const String analysisRoute = '/analysis';
  static const String profileRoute = '/profile';

  // Indonesian Text Strings
  static const String beranda = 'Beranda';
  static const String analisisPerOrang = 'Analisis Individu';
  static const String profil = 'Profil';
  static const String analisStres = 'Analisis Stres Karyawan';
  static const String tingkatStres = 'Tingkat Stres';
  static const String faktorPenyebab = 'Faktor Penyebab Stres';
  static const String uploadDataset = 'Upload Dataset';
  static const String refreshAnalisis = 'Refresh Analisis';
  static const String interpretasiData = 'Interpretasi Data';
  static const String rekomendasi = 'Rekomendasi';

  // Stress Level Categories
  static const String stressRendah = 'Rendah';
  static const String stressMedium = 'Medium';
  static const String stressTinggi = 'Tinggi';

  // Factor Names (Indonesian)
  static const String bebanKerja = 'Beban Kerja';
  static const String keseimbanganHidupKerja = 'Keseimbangan Hidup-Kerja';
  static const String konflikTim = 'Konflik Tim';
  static const String dukunganManajemen = 'Dukungan Manajemen';
  static const String lingkunganKerja = 'Lingkungan Kerja';

  // Department Names
  static const String departmentHR = 'HR';
  static const String departmentFinance = 'Finance';
  static const String departmentMarketing = 'Marketing';
  static const String departmentIT = 'IT';
  static const String departmentOperations = 'Operations';

  // ML Model Configuration
  static const int minDatasetSize = 50;
  static const int maxDatasetSize = 5000;
  static const double defaultStressThreshold = 70.0;
  static const int neuralNetworkLayers = 3;
  static const int ncfEmbeddingDim = 32;

  // File Processing
  static const List<String> allowedFileTypes = ['csv', 'xlsx', 'xls'];
  static const int maxFileSizeMB = 10;

  // Required Dataset Columns
  static const List<String> requiredColumns = [
    'employee_id',
    'department',
    'workload',
    'work_life_balance',
    'team_conflict',
    'management_support',
    'work_environment',
    'stress_level'
  ];

  // Error Messages (Indonesian)
  static const String errorFileNotSupported = 'Format file tidak didukung';
  static const String errorFileTooLarge = 'Ukuran file terlalu besar';
  static const String errorInvalidData = 'Data tidak valid';
  static const String errorNetworkConnection = 'Koneksi jaringan bermasalah';
  static const String errorDataProcessing = 'Gagal memproses data';

  // Success Messages (Indonesian)
  static const String successDataUploaded = 'Data berhasil diunggah';
  static const String successAnalysisComplete =
      'Analisis berhasil diselesaikan';
  static const String successDataSaved = 'Data berhasil disimpan';
}
