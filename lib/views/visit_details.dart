import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visits_tracker/providers/customer_provider.dart';
import 'package:visits_tracker/providers/new_visit_provider.dart';
import 'package:visits_tracker/providers/updated_visit_list_provider.dart';
import '../models/visits.dart';
import '../models/customer.dart';
import '../models/activity.dart';
import '../providers/visit_list_provider.dart';
import '../providers/new_visit_provider.dart'; 

class VisitDetailPage extends ConsumerWidget {
  final int visitId;

  const VisitDetailPage({super.key, required this.visitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(combinedVisitListProvider);
    final customersAsync = ref.watch(customerMapProvider);
    final activitiesAsync = ref.watch(activityListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Visit Details')),
      body: visitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading visit: $e')),
        data: (visits) {
          final visit =
              visits.firstWhere((v) => v.id == visitId, orElse: () => Visit());

          if (visit.id == null) {
            return const Center(child: Text('Visit not found.'));
          }

          return customersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading customer: $e')),
            data: (customerMap) {
              final customer =
                  customerMap[visit.customerId] ?? Customer(name: 'Unknown');

              return activitiesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error loading activities: $e')),
                data: (activities) {
                  final activityDescriptions = (visit.activitiesDone ?? [])
                      .map((id) =>
                          activities.firstWhere((a) => a.id == id,
                              orElse: () => Activity(description: 'Unknown')))
                      .map((a) => a.description ?? 'Unknown')
                      .join(', ');

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        _infoTile(Icons.person, 'Customer', customer.name ?? ''),
                        _infoTile(Icons.flag, 'Status', visit.status ?? 'N/A'),
                        _infoTile(Icons.date_range, 'Visit Date',
                            visit.visitDate?.toLocal().toString().split(' ')[0] ??
                                'N/A'),
                        _infoTile(Icons.location_on, 'Location',
                            visit.location ?? 'N/A'),
                        _infoTile(Icons.notes, 'Notes', visit.notes ?? 'N/A'),
                        _infoTile(Icons.task_alt, 'Activities Done',
                            activityDescriptions),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
