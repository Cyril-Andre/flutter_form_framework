# flutter_form_framework

A Material 3–friendly form framework for Flutter with a configurable form
container, dirty state tracking, readonly styling, and flexible dropdowns
(fixed or async, strings, enums, or custom objects).

## Features

- **Form container** — Configurable border (none, square, rounded), padding,
  and optional theme. Uses Material 3 colors by default.
- **Dirty state tracking** — Know when any field value has changed since the
  last “saved” snapshot. Register fields by key; call `markAsSaved()` to
  update the baseline.
- **Readonly styling** — Input widgets get distinct background and foreground
  colors when `readonly` is true, and editing is disabled.
- **Theme** — Optional `FormThemeData` for form container and input colors
  (background, foreground, readonly). Falls back to `ThemeData` / ColorScheme.
- **Form widgets** — Text field, dropdown, checkbox, and option button (radio)
  that integrate with the container, theme, and dirty state.
- **Flexible dropdowns** — Support fixed `List<T>`, async `Future<List<T>>`,
  and items as `String`, `Enum`, or `ItemString`. Optional searchable and
  clearable modes.

## Installation

Add `flutter_form_framework` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_form_framework: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Usage

### Basic form with container and fields

Wrap your form fields in a `FormContainer`. Use `FormTextField`, `FormDropdown`,
`FormCheckbox`, and `FormOptionButton` with a `formFieldKey` so they register
with the shared state for dirty tracking and theming.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_framework/flutter_form_framework.dart';

Form(
  child: FormContainer(
    border: FormContainerBorder.rounded,
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
          initialValue: null,
          items: ['Low', 'Medium', 'High'],
          decoration: const InputDecoration(
            labelText: 'Priority',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FormCheckbox(
          formFieldKey: 'agree',
          initialValue: false,
          label: const Text('I agree'),
        ),
      ],
    ),
  ),
)
```

### Dirty state

Access `FormFrameState` via `FormFrameScope.of(context)` to check if the form
has unsaved changes and to mark it as saved after persisting.

```dart
final formState = FormFrameScope.of(context);

// Check if any field value changed since last snapshot
if (formState?.isDirty ?? false) {
  // Show "Unsaved changes" or enable Save button
}

// After saving to backend or local storage, update the baseline
formState?.markAsSaved();
```

You can also read `currentValues` or `initialValues` from the same state.

### Optional theme

Pass `FormThemeData` to customize form and input colors. Omit it to use
Material 3 theme colors.

```dart
FormContainer(
  theme: FormThemeData(
    formBackgroundColor: Colors.grey.shade100,
    inputBackgroundColor: Colors.white,
    readonlyBackgroundColor: Colors.grey.shade200,
  ),
  child: /* ... */,
)
```

### Readonly mode

Set `readonly: true` on any form input widget. It will use the theme’s
readonly colors and prevent user edits.

```dart
FormTextField(
  formFieldKey: 'name',
  initialValue: 'Jane',
  readonly: true,
  decoration: const InputDecoration(labelText: 'Name'),
)
```

### Dropdown: async items and enums

Use `itemsFuture` for async loading. Use enums or custom types that implement
`ItemString` for display labels.

```dart
enum Priority { low, medium, high }

FormDropdown<Priority>(
  formFieldKey: 'priority',
  initialValue: Priority.medium,
  items: Priority.values,
  searchable: true,
  clearable: true,
  decoration: const InputDecoration(
    labelText: 'Priority',
    border: OutlineInputBorder(),
  ),
)
```

## Widgets overview

| Widget              | Description                                      |
|---------------------|--------------------------------------------------|
| `FormContainer`     | Container with border, padding, theme, and state |
| `FormTextField`     | Text field with theme and dirty tracking         |
| `FormDropdown<T>`   | Dropdown; fixed/async items; optional search     |
| `FormCheckbox`      | Checkbox with optional tristate                  |
| `FormOptionButton<T>` | Radio option; use with same `formFieldKey` for group |

All input widgets accept a `formFieldKey` (for state) and `readonly`. They
participate in `FormThemeScope` and `FormFrameScope` when placed inside a
`FormContainer`.

## Custom form widgets

Extend `FormInputWidget` and `FormInputState` to build custom inputs that
respect the same theme and readonly styling. Use `resolveThemeColors(context)`
in your `build` method for background and foreground colors.

## Example

The package includes a full example in the `example/` directory. Run it with:

```bash
cd example && flutter run
```

It demonstrates the form container, all field types, theme switching, dirty
state, and readonly mode.

## Requirements

- Dart SDK `>=3.0.0 <4.0.0`
- Flutter `>=3.0.0`
- Material 3 is recommended; the framework uses Material 3 theme colors when
  custom theme colors are not set.

## Links

- [Package on pub.dev](https://pub.dev/packages/flutter_form_framework)
- [Source code](https://github.com/Cyril-Andre/flutter_form_framework)
- [Issue tracker](https://github.com/Cyril-Andre/flutter_form_framework/issues)

## License

MIT
