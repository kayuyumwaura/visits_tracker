
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visits_tracker/models/activity.dart';
import 'package:visits_tracker/models/customer.dart';
import '../models/visits.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://kqgbftwsodpttpqgqnbh.supabase.co/rest/v1',
      headers: {
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxZ2JmdHdzb2RwdHRwcWdxbmJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5ODk5OTksImV4cCI6MjA2MTU2NTk5OX0.rwJSY4bJaNdB8jDn3YJJu_gKtznzm-dUKQb4OvRtP6c',
        'Authorization': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxZ2JmdHdzb2RwdHRwcWdxbmJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5ODk5OTksImV4cCI6MjA2MTU2NTk5OX0.rwJSY4bJaNdB8jDn3YJJu_gKtznzm-dUKQb4OvRtP6c',
      },
    ),
  );


//get visits list
  Future<List<Visit>> fetchVisits() async {
    final response = await _dio.get('/visits');
     print('print: ${response.data}');
    final data = response.data as List<dynamic>;
    //return data.map((json) => Visit.fromJson(json)).toList();
    return data.map((json) {
  final visit = Visit.fromJson(json);
  print('print service: $visit');
  return visit;
}).toList();
  } 

//get customers
Future<List<Customer>> fetchCustomers() async {
  try {
    final response = await _dio.get('/customers');
    final data = response.data as List;
    return data.map((json) => Customer.fromJson(json)).toList();
  } catch (e) {
    print('Error fetching customers: $e');
    rethrow;
  }
}

//get activities
Future<List<Activity>> fetchActivities() async {
  try {
    final response = await _dio.get('/activities');
    final data = response.data as List;
    return data.map((json) => Activity.fromJson(json)).toList();
  } catch (e) {
    print('Error fetching activities: $e');
    rethrow;
  }
}

//get offline visits
Future<List<Visit>> fetchOfflineVisits() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getStringList('offline_visits') ?? [];

  return stored.map((item) {
    final Map<String, dynamic> data = jsonDecode(item);
    return Visit.fromJson(data);
  }).toList();
}


//submit visit incl offline
Future<void> submitVisit({
    required int customerId,
    required DateTime visitDate,
    required String status,
    required String location,
    required String notes,
    required List<int> activityIds,
  }) async {
    final visitData = {
      'customer_id': customerId,
      'visit_date': visitDate.toUtc().toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': activityIds.map((id) => id.toString()).toList(),
    };

    try {
      await _dio.post('/visits', data: jsonEncode(visitData));
    } catch (e) {
      print('API failed. Saving offline...');
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList('offline_visits') ?? [];
      existing.add(jsonEncode(visitData));
      await prefs.setStringList('offline_visits', existing);
      rethrow;
    }
  }

  //sync offline, remove from offline list
  Future<void> syncOfflineVisit(Visit visit) async {
  final prefs = await SharedPreferences.getInstance();
  final offlineList = prefs.getStringList('offline_visits') ?? [];

  final jsonVisit = jsonEncode({
    'customer_id': visit.customerId,
    'visit_date': visit.visitDate?.toUtc().toIso8601String(),
    'status': visit.status,
    'location': visit.location,
    'notes': visit.notes,
    'activities_done':
        (visit.activitiesDone ?? []).map((id) => id.toString()).toList(),
  });

  try {
    await _dio.post('/visits', data: jsonVisit);

    // remove from shared pref local storage
    offlineList.remove(jsonVisit);
    await prefs.setStringList('offline_visits', offlineList);
  } catch (e) {
    throw Exception('Sync failed: $e');
  }
}


}