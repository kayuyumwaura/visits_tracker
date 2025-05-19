import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visits_tracker/providers/new_visit_provider.dart';
import 'package:visits_tracker/providers/visit_list_provider.dart';
import '../models/customer.dart';
import '../models/activity.dart';
import '../providers/new_visit_provider.dart';
import '../services/api_service.dart';

class AddVisitPage extends ConsumerStatefulWidget {
  const AddVisitPage({super.key});

  @override
  ConsumerState<AddVisitPage> createState() => _AddVisitPageState();
}

class _AddVisitPageState extends ConsumerState<AddVisitPage> {
  final _formKey = GlobalKey<FormState>();

  Customer? selectedCustomer;
  String? selectedStatus;
  DateTime? selectedDate;
  List<Activity> selectedActivities = [];
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> statusOptions = ['Pending', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(customerListProvider);
    final activityAsync = ref.watch(activityListProvider);

    if (customerAsync.isLoading || activityAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (customerAsync.hasError || activityAsync.hasError) {
      return const Scaffold(
        body: Center(child: Text('Error loading form data.')),
      );
    }

    final customers = customerAsync.value ?? [];
    final activities = activityAsync.value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Add Visit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              DropdownButtonFormField<Customer>(
                value: selectedCustomer,
                decoration: const InputDecoration(
                  labelText: 'Customer',
                  border: OutlineInputBorder( ),
                ),
                items: customers.map((customer) {
                  return DropdownMenuItem(
                    value: customer,
                    child: Text(customer.name ?? 'John Doe'),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Select a customer' : null,
                onChanged: (value) => setState(() => selectedCustomer = value),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Select a status' : null,
                onChanged: (value) => setState(() => selectedStatus = value),
              ),
              const SizedBox(height: 16),

              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Visit Date',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(
                  text: selectedDate != null
                      ? '${selectedDate!.toLocal()}'.split(' ')[0]
                      : '',
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    setState(() => selectedDate = pickedDate);
                  }
                },
                validator: (_) =>
                    selectedDate == null ? 'Select a visit date' : null,
              ),
              const SizedBox(height: 16),

              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Activities Done',
                  border: OutlineInputBorder(),
                ),
                child: Column(
                  children: activities.map((activity) {
                    final isSelected = selectedActivities.contains(activity);
                    return CheckboxListTile(
                      title: Text(activity.description ?? ''),
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            selectedActivities.add(activity);
                          } else {
                            selectedActivities.remove(activity);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a location' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
    color: Color.fromARGB(255, 217, 194, 251),
    width: 0.5,               
  ),
  borderRadius: BorderRadius.circular(16), 
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[200]
                   ),
                  onPressed: _handleSubmit,
                  child: const Text('Submit', style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final api = ref.read(apiServiceProvider);

      try {
        await api.submitVisit(
          customerId: selectedCustomer!.id!,
          visitDate: selectedDate!,
          status: selectedStatus!,
          location: _locationController.text.trim(),
          notes: _notesController.text.trim(),
          activityIds: selectedActivities.map((a) => a.id!).toList(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visit submitted successfully')),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved offline. Will sync later.'),
              backgroundColor: Colors.orange,
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      }
    }
  }
}
