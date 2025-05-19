import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visits_tracker/models/visits.dart';
import 'package:visits_tracker/providers/visit_list_provider.dart';

final combinedVisitListProvider = FutureProvider<List<Visit>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final online = await api.fetchVisits();
  final offline = await api.fetchOfflineVisits();
  return [...offline, ...online]; // offline visits shown first
});
