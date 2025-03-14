import 'package:flutter/material.dart';
import 'package:snaply/snaply.dart';

class FormPage extends StatefulWidget {
  const FormPage({
    required this.counterValue,
    Key? key,
  }) : super(key: key);

  final int counterValue;

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  int? _age;

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      SnaplyReporter.instance.setAttributes(
        attrKey: 'user_info',
        attrMap: {
          'user_name': _name ?? 'NA',
          'user_email': _email ?? 'NA',
          'user_age': _age.toString(),
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit form'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'Your Counter Value',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.counterValue}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Name is required';
                    return null;
                  },
                  onSaved: (value) => _name = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email is required';
                    if (!value!.contains('@')) return 'Invalid email';
                    return null;
                  },
                  onSaved: (value) => _email = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Age is required';
                    final age = int.tryParse(value!);
                    if (age == null || age < 0) return 'Invalid age';
                    return null;
                  },
                  onSaved: (value) => _age = int.tryParse(value ?? ''),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitForm,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Submit',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
