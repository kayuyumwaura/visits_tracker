import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visits_tracker/providers/visit_list_provider.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

final customerMapProvider = FutureProvider<Map<int, Customer>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final customers = await api.fetchCustomers();
  return {
    for (var c in customers)
      if (c.id != null) c.id!: c,
  };
});
