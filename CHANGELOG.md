## 0.1.0

* Initial release.
* Form container with border options: none, square, rounded.
* Material 3 theming with optional custom colors (FormThemeData).
* Dirty state tracking via FormFrameState (registerField, isDirty, markAsSaved).
* FormTextField, FormDropdown, FormCheckbox, FormOptionButton with:
  * `formFieldKey` for dirty tracking,
  * `readonly` with theme-based background/foreground styling.
* Dropdown: fixed items or async (itemsFuture); items as String, Enum, or ItemString.
* FormThemeScope and FormFrameScope for theme and state access.
