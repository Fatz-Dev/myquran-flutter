import '../models/doa_model.dart';
import 'api_service.dart';

class DoaService {
  final ApiService _apiService;

  DoaService(this._apiService);

  Future<List<DoaModel>> getDoaList() async {
    final data = await _apiService.getDoa('/doa');
    if (data is List) {
      return data.map((e) => DoaModel.fromJson(e)).toList();
    }
    if (data is Map && data['data'] != null) {
      final list = data['data'] as List<dynamic>;
      return list.map((e) => DoaModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<DoaModel> getDoaDetail(int id) async {
    final data = await _apiService.getDoa('/doa/$id');
    if (data is Map) {
      if (data['data'] != null) {
        return DoaModel.fromJson(data['data']);
      }
      return DoaModel.fromJson(data as Map<String, dynamic>);
    }
    throw 'Format data tidak sesuai';
  }
}
