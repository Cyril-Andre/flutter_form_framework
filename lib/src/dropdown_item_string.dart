/// Contract for dropdown items that provide a display string via a delegate.
///
/// Use [itemString] to get the label for the item. Supported item types:
/// - [ItemString] (objects with a custom label)
/// - [String]
/// - [Enum] (uses [EnumName.name] or extension if provided)
abstract interface class ItemString {
  String get itemString;
}

/// Extension to display any value as a dropdown label.
extension DropdownItemString on dynamic {
  /// Returns the display string for a dropdown item.
  ///
  /// - [ItemString]: uses [ItemString.itemString]
  /// - [Enum]: uses [EnumName.name]
  /// - Otherwise: [toString]
  String toItemString() {
    if (this == null) return '';
    if (this is ItemString) return (this as ItemString).itemString;
    if (this is Enum) return (this as Enum).name;
    return toString();
  }
}
