import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visits_tracker/providers/customer_provider.dart';
import 'package:visits_tracker/providers/updated_visit_list_provider.dart';
import 'package:visits_tracker/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/visits.dart';
import '../providers/visit_list_provider.dart';

class VisitListPage extends ConsumerStatefulWidget {
  const VisitListPage({super.key});

  @override
  ConsumerState<VisitListPage> createState() => _VisitListPageState();
}

class _VisitListPageState extends ConsumerState<VisitListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final visitsAsync = ref.watch(combinedVisitListProvider);
    final customerMapAsync = ref.watch(customerMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visits',),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: visitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading visits: $e')),
          data: (visits) {
            return customerMapAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error loading customers: $e')),
              data: (customerMap) {
                final filteredVisits = visits.where((v) {
                  final query = _searchQuery.toLowerCase();
                  return query.isEmpty ||
                      (v.status?.toLowerCase().contains(query) ?? false) ||
                      (v.location?.toLowerCase().contains(query) ?? false) ||
                      (v.customerId?.toString().contains(query) ?? false);
                }).toList();

                if (filteredVisits.isEmpty) {
                  return const Center(
                      child: Text('No visits match your search.'));
                }

                return Column(
                  children: [
                    TextField(
                      onChanged: (query) => setState(() {
                        _searchQuery = query.toLowerCase();
                      }),
                      decoration: const InputDecoration(
                        hintText:
                            'Search ',
                        prefixIcon: Icon(Icons.search),
                        //border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredVisits.length,
                        itemBuilder: (context, index) {
                          final visit = filteredVisits[index];
                          final isOffline = visit.id == null;

                          final status = visit.status ?? 'Unknown';
                          final bgColor = _getTileColor(status);
                          final customerName = customerMap[visit.customerId]
                                  ?.name ??
                              'Customer #${visit.customerId ?? 'N/A'}';

                          return Card(
                            color: bgColor.withOpacity(1),
                           // elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(
                                customerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${status.toUpperCase()} at ${visit.location ?? 'Space'}\n'
                                '${visit.visitDate?.toLocal().toString().split(" ")[0] ?? 'No date'}',
                              ),
                              trailing: isOffline
                                  ? IconButton(
                                      icon: const Icon(Icons.sync, color: Colors.red,),
                                      tooltip: 'Sync visit',
                                      onPressed: () async {
                                        try {
                                          await ref
                                              .read(apiServiceProvider)
                                              .syncOfflineVisit(visit);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Visit synced successfully'), backgroundColor: Colors.green),
                                            );
                                            ref.invalidate(
                                                combinedVisitListProvider);
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content:
                                                Text('Failed to sync: $e'),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      },
                                    )
                                  : const Icon(Icons.cloud_done_sharp,
                                      color: Colors.green),
                              onTap: () {
                                if (!isOffline) {
                                  context.push('/visit/${visit.id}');
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getTileColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color.fromARGB(0, 208, 252, 240);
      case 'pending':
        return const Color(0xD6EEFF);
      case 'cancelled':
        return const Color.fromARGB(0, 252, 217, 233);
      default:
        return Colors.grey;
    }
  }
}