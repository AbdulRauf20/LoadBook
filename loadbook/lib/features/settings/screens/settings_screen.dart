  import 'package:flutter/material.dart';

  import '../../../data/local/database.dart';
  import '../controllers/settings_controller.dart';

  class SettingsScreen extends StatefulWidget {
    final LoadBookDatabase database;

    const SettingsScreen({super.key, required this.database});

    @override
    State<SettingsScreen> createState() => _SettingsScreenState();
  }

  class _SettingsScreenState extends State<SettingsScreen> {
    late final SettingsController controller;

    final businessNameController = TextEditingController();
    final balanceController = TextEditingController();

    TimeOfDay reminderTime = const TimeOfDay(hour: 18, minute: 0);

    @override
    void initState() {
      super.initState();

      controller = SettingsController(widget.database);

      _load();
    }

    Future<void> _load() async {
      await controller.load();

      final settings = controller.settings!;

      businessNameController.text = settings.businessName;
      balanceController.text = settings.availableBalance.toString();

      reminderTime = TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      );

      if (mounted) {
        setState(() {});
      }
    }

    @override
    void dispose() {
      businessNameController.dispose();
      balanceController.dispose();
      controller.dispose();
      super.dispose();
    }

    Future<void> _save() async {
      await controller.save(
        businessName: businessNameController.text.trim(),
        availableBalance: int.tryParse(balanceController.text.trim()) ?? 0,
        reminderHour: reminderTime.hour,
        reminderMinute: reminderTime.minute,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    }

    @override
    Widget build(BuildContext context) {
      if (controller.settings == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(title: const Text('Business Settings')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: businessNameController,
              decoration: const InputDecoration(labelText: 'Business Name'),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Available Balance'),
            ),

            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reminder Time'),
              subtitle: Text(reminderTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: reminderTime,
                );

                if (picked != null) {
                  setState(() {
                    reminderTime = picked;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      );
    }
  }
