import 'package:dio/dio.dart';

class ApiService {
  late final Dio _quranDio;
  late final Dio _doaDio;
  late final Dio _prayerDio;
  late final Dio _vectorDio;
  late final Dio _hadisDio;

  ApiService() {
    _quranDio = Dio(BaseOptions(
      baseUrl: 'https://equran.id/api/v2',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));
    _doaDio = Dio(BaseOptions(
      baseUrl: 'https://equran.id/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));
    _prayerDio = Dio(BaseOptions(
      baseUrl: 'https://api.myquran.com/v2',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));
    _vectorDio = Dio(BaseOptions(
      baseUrl: 'https://equran.id/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ));
    _hadisDio = Dio(BaseOptions(
      baseUrl: 'https://api.myquran.com/v3',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));
  }

  Future<Map<String, dynamic>> postVector(String query) async {
    try {
      final response = await _vectorDio.post(
        '/vector',
        data: {
          'cari': query,
          'batas': 10,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getQuran(String path) async {
    try {
      final response = await _quranDio.get(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> postQuran(
      String path, Map<String, dynamic> data) async {
    try {
      final response = await _quranDio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> getDoa(String path) async {
    try {
      final response = await _doaDio.get(path);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPrayer(String path) async {
    try {
      final response = await _prayerDio.get(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getHadis(String path) async {
    try {
      final response = await _hadisDio.get(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> getRaw(String url) async {
    try {
      final response = await _quranDio.get(url);
      return response.data;
    } catch (_) {
      return null;
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi terlalu lama. Silakan periksa jaringan internet Anda.';
    }
    
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak ada koneksi internet. Aktifkan data atau Wi-Fi untuk memuat data.';
    }

    final statusCode = e.response?.statusCode;
    switch (statusCode) {
      case 400:
        return 'Permintaan data tidak valid. Silakan coba pilih lokasi lain secara manual.';
      case 404:
        return 'Data jadwal shalat untuk lokasi ini belum tersedia di server.';
      case 429:
        return 'Terlalu banyak permintaan. Silakan tunggu sebentar dan coba lagi.';
      case 500:
        return 'Terjadi gangguan pada server pusat. Silakan coba lagi nanti.';
      default:
        return 'Gagal memuat data. Mohon pastikan koneksi internet stabil lalu tekan Coba Lagi.';
    }
  }
}
