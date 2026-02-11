import 'package:flutter/material.dart';
import '../form_state.dart';
import '../form_container.dart';
import '../form_input_widget.dart';
import '../dropdown_item_string.dart';

/// Converts a dropdown item to its display string. Used instead of calling
/// [DropdownItemString.toItemString] on a dynamic receiver to avoid
/// NoSuchMethodError when the extension is not resolved (e.g. on web).
String _itemToDisplayString(dynamic item) {
  if (item == null) return '';
  if (item is ItemString) return item.itemString;
  if (item is Enum) return item.name;
  return item.toString();
}

/// Signature for custom filter when [FormDropdown.searchable] is true.
/// Return true to keep the item when the user types [query].
typedef FormDropdownFilterFn<T> = bool Function(T item, String query);

/// A dropdown form field that integrates with [FormContainer] (dirty state,
/// theme, readonly styling). Supports fixed items, async items (Future),
/// and items as [String], [Enum], or [ItemString] objects.
///
/// When [searchable] is true, opening the dropdown shows a search field and
/// filters items by their display string (or [filterFn] if provided).
/// When [clearable] is true, a clear button is shown when a value is selected
/// and allows setting the value back to null.
class FormDropdown<T> extends FormInputWidget {
  const FormDropdown({
    super.key,
    this.fieldKey,
    required this.formFieldKey,
    this.initialValue,
    this.readonly = false,
    this.items,
    this.itemsFuture,
    this.decoration,
    this.hint,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.searchable = false,
    this.clearable = false,
    this.filterFn,
  })  : assert(items != null || itemsFuture != null,
            'Either items or itemsFuture must be provided'),
        assert(items == null || itemsFuture == null,
            'Provide either items or itemsFuture, not both');

  final Key? fieldKey;
  final String formFieldKey;
  final T? initialValue;
  @override
  final bool readonly;
  final List<T>? items;
  final Future<List<T>>? itemsFuture;
  final InputDecoration? decoration;
  final Widget? hint;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T?>? validator;
  final FormFieldSetter<T?>? onSaved;

  /// When true, the dropdown opens a popup with a search field to filter items.
  final bool searchable;

  /// When true, a clear button is shown when a value is selected, allowing null.
  final bool clearable;

  /// Optional custom filter when [searchable] is true. If null, items are
  /// filtered by [DropdownItemString.toItemString] containing the query
  /// (case-insensitive).
  final FormDropdownFilterFn<T>? filterFn;

  @override
  State<FormDropdown<T>> createState() => _FormDropdownState<T>();
}

class _FormDropdownState<T> extends FormInputState<FormDropdown<T>> {
  List<T>? _asyncItems;
  bool _loading = false;
  Object? _error;
  late T? _value;
  final LayerLink _overlayLink = LayerLink();
  FormFrameState? _formState;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    if (widget.itemsFuture != null) _loadItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formState = FormFrameScope.of(context);
    _registerValue(_value);
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.itemsFuture!;
      if (mounted) {
        setState(() {
          _asyncItems = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _asyncItems = [];
          _loading = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(FormDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
      _registerValue(_value);
    }
    if (oldWidget.itemsFuture != widget.itemsFuture && widget.itemsFuture != null) {
      _loadItems();
    }
  }

  void _registerValue(T? value) {
    FormFrameScope.of(context)?.registerField(widget.formFieldKey, value);
  }

  @override
  void dispose() {
    _formState?.unregisterField(widget.formFieldKey);
    super.dispose();
  }

  List<T> get _effectiveItems {
    if (widget.items != null) return widget.items!;
    return _asyncItems ?? [];
  }

  List<T> _filteredItems(String query) {
    if (query.isEmpty) return _effectiveItems;
    final q = query.trim().toLowerCase();
    if (widget.filterFn != null) {
      return _effectiveItems.where((e) => widget.filterFn!(e, query)).toList();
    }
    return _effectiveItems
        .where((e) => _itemToDisplayString(e).toLowerCase().contains(q))
        .toList();
  }

  void _clearSelection(FormFieldState<T?> state) {
    setState(() => _value = null);
    state.didChange(null);
    _registerValue(null);
    widget.onChanged?.call(null);
  }

  void _selectValue(T? v, FormFieldState<T?> state) {
    setState(() => _value = v);
    state.didChange(v);
    _registerValue(v);
    widget.onChanged?.call(v);
  }

  void _showSearchableOverlay(
    BuildContext context,
    FormFieldState<T?> state,
    Color fg,
    BoxConstraints constraints,
  ) {
    final theme = Theme.of(context);
    final overlay = Overlay.of(context);
    final controller = TextEditingController();
    final focusNode = FocusNode();

    late final OverlayEntry overlayEntry;
    void close() {
      focusNode.unfocus();
      overlayEntry.remove();
      controller.dispose();
      focusNode.dispose();
    }

    overlayEntry = OverlayEntry(
      builder: (context) => _SearchableDropdownOverlay<T>(
        layerLink: _overlayLink,
        constraints: constraints,
        theme: theme,
        foregroundColor: fg,
        searchController: controller,
        searchFocusNode: focusNode,
        filterItems: _filteredItems,
        value: _value,
        hint: widget.hint,
        clearable: widget.clearable,
        onSelected: (v) {
          _selectValue(v, state);
          close();
        },
        onClose: close,
        itemString: (T item) => _itemToDisplayString(item),
      ),
    );
    overlay.insert(overlayEntry);
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveThemeColors(context);

    return FormField<T?>(
      key: widget.fieldKey,
      initialValue: widget.initialValue,
      validator: widget.validator,
      onSaved: widget.onSaved,
      builder: (FormFieldState<T?> state) {
        if (_loading) {
          return InputDecorator(
            decoration: (widget.decoration ?? const InputDecoration())
                .copyWith(
                  filled: true,
                  fillColor: colors.background,
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            child: Text(
              'Loading...',
              style: TextStyle(color: colors.foreground.withValues(alpha: 0.6)),
            ),
          );
        }
        if (_error != null) {
          return InputDecorator(
            decoration: (widget.decoration ?? const InputDecoration())
                .copyWith(
                  filled: true,
                  fillColor: colors.background,
                  errorText: _error.toString(),
                ),
            child: Text(
              'Error loading items',
              style: TextStyle(color: colors.foreground),
            ),
          );
        }

        final decoration = (widget.decoration ?? const InputDecoration()).copyWith(
          filled: true,
          fillColor: colors.background,
          errorText: state.errorText,
          labelStyle: TextStyle(color: colors.foreground),
          suffixIcon: _buildSuffixIcon(state, colors.foreground),
        );

        if (widget.searchable && !widget.readonly) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // Use finite constraints; unbounded (e.g. in ScrollView) causes
              // NaN in overlay transform and "Converting object to encodable failed".
              final maxW = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;
              final maxH = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 56.0;
              final safeConstraints = BoxConstraints(
                maxWidth: maxW,
                maxHeight: maxH,
              );
              return InputDecorator(
                decoration: decoration,
                child: CompositedTransformTarget(
                  link: _overlayLink,
                  child: InkWell(
                    onTap: () => _showSearchableOverlay(
                      context,
                      state,
                      colors.foreground,
                      safeConstraints,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _value != null
                              ? Text(
                                  _itemToDisplayString(_value),
                                  style: TextStyle(color: colors.foreground),
                                  overflow: TextOverflow.ellipsis,
                                )
                              : (widget.hint ??
                                  Text(
                                    'Select',
                                    style: TextStyle(
                                        color: colors.foreground.withValues(alpha: 0.6)),
                                  )),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: colors.foreground.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        return InputDecorator(
          decoration: decoration,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: _value,
              isExpanded: true,
              hint: widget.hint ??
                  Text(
                    'Select',
                    style: TextStyle(color: colors.foreground.withValues(alpha: 0.6)),
                  ),
              onChanged: widget.readonly
                  ? null
                  : (T? v) {
                      _selectValue(v, state);
                    },
              items: _buildDropdownItems(colors.foreground),
            ),
          ),
        );
      },
    );
  }

  Widget? _buildSuffixIcon(FormFieldState<T?> state, Color fg) {
    if (!widget.clearable || _value == null || widget.readonly) return null;
    return IconButton(
      icon: Icon(Icons.clear, size: 20, color: fg.withValues(alpha: 0.6)),
      onPressed: () => _clearSelection(state),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  List<DropdownMenuItem<T>> _buildDropdownItems(Color fg) {
    final items = <DropdownMenuItem<T>>[
      ..._effectiveItems.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            _itemToDisplayString(item),
            style: TextStyle(color: fg),
          ),
        );
      }),
    ];
    return items;
  }
}

class _SearchableDropdownOverlay<T> extends StatefulWidget {
  const _SearchableDropdownOverlay({
    required this.layerLink,
    required this.constraints,
    required this.theme,
    required this.foregroundColor,
    required this.searchController,
    required this.searchFocusNode,
    required this.filterItems,
    required this.value,
    required this.hint,
    required this.onSelected,
    required this.onClose,
    required this.itemString,
    this.clearable = false,
  });

  final LayerLink layerLink;
  final BoxConstraints constraints;
  final ThemeData theme;
  final Color foregroundColor;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final List<T> Function(String query) filterItems;
  final T? value;
  final Widget? hint;
  final ValueChanged<T?> onSelected;
  final VoidCallback onClose;
  final String Function(T) itemString;
  final bool clearable;

  @override
  State<_SearchableDropdownOverlay<T>> createState() =>
      _SearchableDropdownOverlayState<T>();
}

class _SearchableDropdownOverlayState<T>
    extends State<_SearchableDropdownOverlay<T>> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _query = widget.searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.filterItems(_query);
    final materialTheme = widget.theme;
    final fg = widget.foregroundColor;

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onClose,
        ),
        Positioned(
          width: widget.constraints.maxWidth.isFinite
              ? widget.constraints.maxWidth
              : 200,
          child: CompositedTransformFollower(
            link: widget.layerLink,
            showWhenUnlinked: false,
            offset: Offset(
              0,
              (widget.constraints.maxHeight.isFinite
                      ? widget.constraints.maxHeight
                      : 56) +
                  4,
            ),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(4),
              color: materialTheme.colorScheme.surface,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 280,
                  minWidth: widget.constraints.maxWidth.isFinite
                      ? widget.constraints.maxWidth
                      : 200,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: widget.searchController,
                        focusNode: widget.searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        style: TextStyle(
                          color: materialTheme.colorScheme.onSurface,
                        ),
                        onChanged: (_) => setState(
                            () => _query = widget.searchController.text),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount:
                            (widget.clearable ? 1 : 0) + filtered.length,
                        itemBuilder: (context, index) {
                          if (widget.clearable && index == 0) {
                            return ListTile(
                              title: Text(
                                'Clear selection',
                                style: TextStyle(
                                    color: materialTheme.colorScheme.primary),
                              ),
                              onTap: () {
                                widget.onSelected(null);
                                widget.onClose();
                              },
                            );
                          }
                          final item = filtered[index - (widget.clearable ? 1 : 0)];
                          return ListTile(
                            title: Text(
                              widget.itemString(item),
                              style: TextStyle(color: fg),
                            ),
                            onTap: () => widget.onSelected(item),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
