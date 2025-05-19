import '../models/visits.dart';
import '../services/api_service.dart';

class VisitRepository {
  final ApiService apiService;

  VisitRepository(this.apiService);

  Future<List<Visit>> getAllVisits() async {
    try {
       print('hello...');
      return await apiService.fetchVisits();
    } catch (e) {
      rethrow;
    }
  }
}