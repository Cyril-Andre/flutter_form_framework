# flutter_form_framework — Example

Demo app for the **flutter_form_framework** package: Material 3 forms with a configurable container, dirty state tracking, readonly fields, and dropdowns.

## What this example demonstrates

- **FormContainer**: Two form blocks (rounded and square border) sharing the same theme.
- **Theming**: A selector to switch between light and dark form theme.
- **FormTextField**: Editable text field (e.g. name) and a readonly field (`readonly: true`).
- **FormDropdown**: Dropdown built from an enum (priority), with search, clear, and `onChanged`.
- **FormCheckbox**: Checkbox wired to the form state.
- **Dirty state**: Displays “Form has unsaved changes” / “No changes” and a Save button that is disabled until something changes; `markAsSaved()` resets the state after saving.

## Running the example

From the package root (parent of `example/`):

```bash
flutter pub get
cd example
flutter run
```

Or from the root:

```bash
flutter pub get
flutter run -d chrome
```

For more details on the package, see the [main README](../README.md).
