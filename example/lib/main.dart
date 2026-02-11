import 'package:flutter/material.dart';
import 'package:flutter_form_framework/flutter_form_framework.dart';

import 'app_themes.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Form Framework Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

enum Priority { low, medium, high }

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  String? _selectedPriority;
  bool? _agree = false;
  AppFormTheme _formTheme = AppFormTheme.light;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Framework Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('Form theme: '),
                  DropdownButton<AppFormTheme>(
                    value: _formTheme,
                    items: AppFormTheme.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _formTheme = v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FormContainer(
                border: FormContainerBorder.rounded,
                theme: _formTheme.themeData,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormTextField(
                      formFieldKey: 'name',
                      initialValue: 'Jane',
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormDropdown<String>(
                      formFieldKey: 'priority',
                      initialValue: _selectedPriority,
                      items: Priority.values.map((e) => e.name).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Priority (enum as string)',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select priority'),
                      searchable: true,
                      clearable: true,
                      onChanged: (v) => setState(() => _selectedPriority = v),
                    ),
                    const SizedBox(height: 16),
                    FormCheckbox(
                      formFieldKey: 'agree',
                      initialValue: _agree,
                      label: const Text('I agree to the terms'),
                      onChanged: (v) => setState(() => _agree = v),
                    ),
                    const SizedBox(height: 24),
                    _DirtyActions(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FormContainer(
                border: FormContainerBorder.square,
                theme: _formTheme.themeData,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormTextField(
                      formFieldKey: 'readonly_field',
                      initialValue: 'Read-only value',
                      readonly: true,
                      decoration: const InputDecoration(
                        labelText: 'Read-only',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirtyActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = FormFrameScope.of(context);
    if (state == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Row(
          children: [
            Text(
              state.isDirty ? 'Form has unsaved changes' : 'No changes',
              style: TextStyle(
                color: state.isDirty ? Colors.orange : Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: state.isDirty
                  ? () {
                      state.markAsSaved();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved')),
                      );
                    }
                  : null,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
