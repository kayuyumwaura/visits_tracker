import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/visits.dart';
import '../repositories/visit_repo.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final visitRepositoryProvider = Provider<VisitRepository>(
  (ref) => VisitRepository(ref.read(apiServiceProvider)),
);

final visitListProvider = FutureProvider<List<Visit>>((ref) async {
  print('Fetching visits from provider...');
  final repo = ref.read(visitRepositoryProvider);
  final visits = await repo.getAllVisits();
  print('Fetched ${visits.length} visits');
  return visits;

  // final repository = ref.read(visitRepositoryProvider);
  // return await repository.getAllVisits();
});