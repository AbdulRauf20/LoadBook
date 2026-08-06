import 'package:flutter/material.dart';

class CustomerForm extends StatefulWidget {
  final String? initialName;
  final String? initialPhoneNumber;
  final int? initialMonthlySales;

  final Future<bool> Function({
    required String name,
    required String phoneNumber,
    required int monthlySales,
  }) onSave;

  const CustomerForm({
    super.key,
    required this.onSave,
    this.initialName,
    this.initialPhoneNumber,
    this.initialMonthlySales,
  });

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}


class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _monthlySalesController = TextEditingController();

  bool _isSaving = false;

@override
void initState() {
  super.initState();

  _nameController.text = widget.initialName ?? '';

  _phoneController.text = widget.initialPhoneNumber ?? '';

  _monthlySalesController.text =
      (widget.initialMonthlySales ?? 0).toString();
}
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _monthlySalesController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final monthlySales = int.tryParse(_monthlySalesController.text.trim()) ?? 0;

    final success = await widget.onSave(
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      monthlySales: monthlySales,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Shop Name',
              hintText: 'Enter shop name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter shop name';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              hintText: '03XXXXXXXXX',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter mobile number';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _monthlySalesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Sales',
              hintText: 'Optional',
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save Customer', style: TextStyle(fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }
}
