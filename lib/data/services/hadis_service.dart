import '../models/hadis_model.dart';
import '../models/perawi_model.dart';
import 'api_service.dart';

class HadisService {
  final ApiService _apiService;

  HadisService(this._apiService);

  Future<HadisModel?> getRandomHadis() async {
    final response = await _apiService.getHadis('/hadis/enc/random');
    if (response['status'] == true && response['data'] != null) {
      return HadisModel.fromJson(response['data']);
    }
    return null;
  }

  Future<List<HadisModel>> getHadisExplore() async {
    final response = await _apiService.getHadis('/hadis/enc/explore?page=1&limit=20');
    final dataObj = response['data'] as Map<String, dynamic>? ?? {};
    final list = dataObj['hadis'] as List<dynamic>? ?? [];
    return list.map((e) => HadisModel.fromJson(e)).toList();
  }

  Future<HadisModel?> getHadisDetail(int id) async {
    final response = await _apiService.getHadis('/hadis/enc/show/$id');
    if (response['status'] == true && response['data'] != null) {
      return HadisModel.fromJson(response['data']);
    }
    return null;
  }

  Future<List<HadisModel>> searchHadis(String keyword) async {
    final response = await _apiService.getHadis('/hadis/enc/cari/$keyword');
    final dataObj = response['data'] as Map<String, dynamic>? ?? {};
    final list = dataObj['hadis'] as List<dynamic>? ?? [];
    return list.map((e) => HadisModel.fromJson(e)).toList();
  }

  Future<List<PerawiModel>> getPerawiBrowse({int page = 1, int limit = 20}) async {
    final response = await _apiService.getHadis('/hadist/perawi/browse?page=$page&limit=$limit');
    final dataObj = response['data'] as Map<String, dynamic>? ?? {};
    final list = dataObj['rawi'] as List<dynamic>? ?? [];
    return list.map((e) => PerawiModel.fromJson(e)).toList();
  }

  Future<PerawiModel?> getPerawiDetail(int id) async {
    final response = await _apiService.getHadis('/hadist/perawi/id/$id');
    if (response['status'] == true && response['data'] != null) {
      return PerawiModel.fromJson(response['data']);
    }
    return null;
  }
}
