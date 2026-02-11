# flutter_form_framework

A Material 3–friendly form framework for Flutter with a configurable container, **dirty state** tracking, **readonly** styling, and flexible dropdowns (fixed or async, with support for objects, enums, and simple types).

## Features

- **Form container**: Optional border (none, square, or rounded), padding, and custom colors while respecting Material 3 theming.
- **Dirty state**: The form tracks whether any field has changed since the last "saved" snapshot. Use `FormFrameScope.of(context)?.isDirty` and `markAsSaved()`.
- **Readonly**: Every input widget has a `readonly` property that updates background and foreground colors (from theme or custom [FormThemeData]) and prevents editing.
- **Input widgets**: Text field, dropdown, checkbox, and option (radio) that integrate with the form container, theme, and dirty tracking.
- **Dropdowns**: Support fixed `items`, async `itemsFuture`, and any item type: [ItemString] objects (custom label), [String], or [Enum] (displayed by name).

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_form_framework: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Form container and dirty state

Wrap your form in [FormContainer]. Use [FormFrameScope] to access dirty state and call `markAsSaved()`.

```dart
Form(
  child: FormContainer(
    border: FormContainerBorder.rounded,
    theme: FormThemeData(
      formBackgroundColor: Colors.blue.shade50,
      inputBackgroundColor: Colors.white,
    ),
    child: Column(
      children: [
        FormTextField(
          formFieldKey: 'name',
          initialValue: 'Jane',
          decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
        ),
        // Show save button only when dirty
        ListenableBuilder(
          listenable: FormFrameScope.of(context)!,
          builder: (_, __) => FilledButton(
            onPressed: FormFrameScope.of(context)!.isDirty
                ? () => FormFrameScope.of(context)!.markAsSaved()
                : null,
            child: Text('Save'),
          ),
        ),
      ],
    ),
  ),
)
```

### Border options

- [FormContainerBorder.none]: No border.
- [FormContainerBorder.square]: 1px border, no radius.
- [FormContainerBorder.rounded]: 1px border with 12px radius.

### Theming

Use [FormThemeData] to override colors. When a color is `null`, the framework uses the current Material 3 theme (e.g. `ColorScheme.surface`, `onSurface`). You can set:

- `formBackgroundColor` / `formForegroundColor`: Form container.
- `inputBackgroundColor` / `inputForegroundColor`: Editable inputs.
- `readonlyBackgroundColor` / `readonlyForegroundColor`: Readonly inputs.

### Readonly

Set `readonly: true` on any input. Background and text use the theme (or [FormThemeData] readonly colors), and the field is not editable.

```dart
FormTextField(
  formFieldKey: 'readonly_field',
  initialValue: 'Cannot edit',
  readonly: true,
  decoration: InputDecoration(labelText: 'Read-only'),
)
```

### Dropdown: fixed items

```dart
FormDropdown<String>(
  formFieldKey: 'priority',
  initialValue: selectedPriority,
  items: ['low', 'medium', 'high'],
  decoration: InputDecoration(labelText: 'Priority'),
  onChanged: (v) => setState(() => selectedPriority = v),
)
```

### Dropdown: enum items

Enums are displayed by their `name`:

```dart
enum Priority { low, medium, high }

FormDropdown<Priority>(
  formFieldKey: 'priority',
  initialValue: selectedPriority,
  items: Priority.values,
  ...
)
```

### Dropdown: custom objects (ItemString)

Implement [ItemString] for a custom label:

```dart
class City implements ItemString {
  City(this.name, this.code);
  final String name;
  final String code;
  @override
  String get itemString => name;
}

FormDropdown<City>(
  formFieldKey: 'city',
  items: [City('Paris', 'FR'), City('Brussels', 'BE')],
  ...
)
```

### Dropdown: async items

Use `itemsFuture` for data loaded asynchronously:

```dart
FormDropdown<User>(
  formFieldKey: 'user',
  itemsFuture: api.fetchUsers(),
  ...
)
```

### Checkbox and option (radio)

```dart
FormCheckbox(
  formFieldKey: 'agree',
  initialValue: false,
  label: Text('I agree'),
  onChanged: (v) => setState(() => agree = v),
)

// Radio group: same formFieldKey, parent holds groupValue
FormOptionButton<String>(
  formFieldKey: 'choice',
  value: 'A',
  groupValue: selectedChoice,
  label: Text('Option A'),
  onChanged: (v) => setState(() => selectedChoice = v),
)
```

## Example

See the [example](example/) app for a full demo: container styles, theming, dirty state, readonly field, and dropdown with enum-style items.

## License

MIT
