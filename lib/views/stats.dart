import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:visits_tracker/providers/updated_visit_list_provider.dart';
import 'package:visits_tracker/providers/updated_visit_list_provider.dart';
import '../models/visits.dart';
import '../providers/visit_list_provider.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(combinedVisitListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: visitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (visits) {
          final byDate = <String, int>{};
          final byCustomer = <String, int>{};
          final byLocation = <String, int>{};
          final byStatus = <String, int>{};

          for (final visit in visits) {
            final date = visit.visitDate?.toLocal().toString().split(' ')[0] ?? 'Unknown';
            //final customerName = visit.customerId ?? 'John Doe';
            final location = visit.location ?? 'Space';
            final status = visit.status ?? 'Unknown';

            byDate[date] = (byDate[date] ?? 0) + 1;
            //byCustomer[customerName] = (byCustomer[customerName] ?? 0) + 1;
            byLocation[location] = (byLocation[location] ?? 0) + 1;
            byStatus[status] = (byStatus[status] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _groupingCardWithDateFilter(context, Icons.date_range, 'Visits on Date', byDate),
                const SizedBox(height: 12),
                _groupingCard(Icons.flag, 'Visits by Status', byStatus),
                const SizedBox(height: 12),
                // _groupingCard(Icons.person, 'Visits by Customer', byCustomer),
                // const SizedBox(height: 12),
                _groupingCard(Icons.location_on, 'Visits by Location', byLocation),
                const SizedBox(height: 24),
                const Text('Visits per Customer Over Time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 300, child: _VisitLineChart()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _groupingCard(IconData icon, String title, Map<String, int> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
            const SizedBox(height: 12),
            ...data.entries.map((e) => Text('${e.key}: ${e.value}')),
          ],
        ),
      ),
    );
  }

  Widget _groupingCardWithDateFilter(
      BuildContext context, IconData icon, String title, Map<String, int> data) {
    DateTime? selectedDate;

    return StatefulBuilder(builder: (context, setState) {
      String? formattedDate = selectedDate != null
          ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
          : null;

      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  selectedDate == null
                      ? 'Select Date'
                      : formattedDate!,
                ),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              if (selectedDate != null)
                Text(
                  'Visits on $formattedDate: ${data[formattedDate] ?? 0}',
                  style: const TextStyle(fontSize: 14),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _VisitLineChart extends ConsumerWidget {
  const _VisitLineChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visits = ref.watch(combinedVisitListProvider).value ?? [];

    final Map<String, int> grouped = {};
    for (final v in visits) {
      if (v.customerId == null || v.visitDate == null) continue;
      final key =
          '${v.customerId}-${v.visitDate!.toLocal().toString().split(' ')[0]}';
      grouped[key] = (grouped[key] ?? 0) + 1;
    }

    final sortedKeys = grouped.keys.toList()..sort();

    final points = <FlSpot>[];
    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final y = grouped[key]!.toDouble();
      points.add(FlSpot(i.toDouble(), y));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            barWidth: 3,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor.withOpacity(0.5),
              ],
            ),
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
