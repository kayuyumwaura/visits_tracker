import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer.dart';
import '../models/activity.dart';
import '../services/api_service.dart';
import 'visit_list_provider.dart';

final customerListProvider = FutureProvider<List<Customer>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchCustomers();
});

final activityListProvider = FutureProvider<List<Activity>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchActivities();
});
