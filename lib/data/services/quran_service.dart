import '../models/surah_model.dart';
import 'api_service.dart';

class QuranService {
  final ApiService _apiService;

  QuranService(this._apiService);

  Future<List<SurahModel>> getSuratList() async {
    final data = await _apiService.getQuran('/surat');
    final list = data['data'] as List<dynamic>? ?? [];
    return list.map((e) => SurahModel.fromJson(e)).toList();
  }

  Future<SurahDetailModel> getSurahDetail(int nomor) async {
    final data = await _apiService.getQuran('/surat/$nomor');
    return SurahDetailModel.fromJson(data['data'] ?? data);
  }

  Future<List<TafsirAyahModel>> getTafsir(int nomor) async {
    final data = await _apiService.getQuran('/tafsir/$nomor');
    final tafsirData = data['data'];
    if (tafsirData == null) return [];
    final tafsirList = tafsirData['tafsir'] as List<dynamic>? ?? [];
    return tafsirList.map((e) => TafsirAyahModel.fromJson(e)).toList();
  }

  Future<List<SemanticResultModel>> semanticSearch(String query) async {
    final response = await _apiService.postVector(query);
    final results = response['hasil'] as List<dynamic>? ?? [];
    return results.map((e) => SemanticResultModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
