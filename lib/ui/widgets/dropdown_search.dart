import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:patrimonio/app/models/dropdown_item.dart';

class DropdownSearch extends StatefulWidget {
  final List<DropdownItem> items;
  final DropdownItem? value;
  final String label;
  final String hint;
  final String searchHint;
  final bool isRequired;
  final String? errorText;
  final Function(DropdownItem?)? onChanged;
  final bool showSearchBox;
  final Widget? prefixIcon;
  final bool dense;
  final bool isEnabled;

  const DropdownSearch({
    super.key,
    required this.items,
    this.value,
    required this.label,
    this.hint = 'Selecione uma opção',
    this.searchHint = 'Pesquisar...',
    this.isRequired = false,
    this.errorText,
    this.onChanged,
    this.showSearchBox = true,
    this.prefixIcon,
    this.dense = false,
    this.isEnabled = true,
  });

  @override
  State<DropdownSearch> createState() => _DropdownSearchState();
}

class _DropdownSearchState extends State<DropdownSearch>
    with TickerProviderStateMixin {
  DropdownItem? _selectedItem;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<DropdownItem> _filteredItems = [];
  bool _isOpen = false;

  // AnimationController para controlar a animação do overlay
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.value;
    _filteredItems = List.from(widget.items);
    _focusNode.addListener(_onFocusChange);

    // Inicializar o AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(DropdownSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _selectedItem = widget.value;
    }
    if (oldWidget.items != widget.items) {
      _filteredItems = List.from(widget.items);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isOpen) {
      _closeDropdown();
    }
  }

  void _toggleDropdown() {
    if (!widget.isEnabled) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() {
      _isOpen = true;
      _isClosing = false;
    });

    _showOverlay();
    _searchController.clear();
    _filteredItems = List.from(widget.items);
    _animationController.forward();
  }

  void _closeDropdown() async {
    if (_isOpen && !_isClosing) {
      setState(() {
        _isClosing = true;
      });

      // Executar animação de fade out
      await _animationController.reverse();

      // Só remover o overlay após a animação terminar
      if (mounted) {
        setState(() {
          _isOpen = false;
          _isClosing = false;
        });
        _removeOverlay();
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: <Widget>[
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeDropdown,
                  behavior: HitTestBehavior.translucent,
                ),
              ),
              Positioned(
                width: size.width,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(
                    0.0,
                    size.height + 2.0,
                  ),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            color: Theme.of(context).colorScheme.surface,
                            shadowColor: Theme.of(context).colorScheme.shadow,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.5,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.showSearchBox &&
                                      widget.items.length > 4)
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          hintText: widget.searchHint,
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0,
                                              ),
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.2),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            borderSide: BorderSide(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                        onChanged: _filterItems,
                                      ),
                                    ),
                                  Flexible(
                                    child:
                                        _filteredItems.isEmpty
                                            ? Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Text(
                                                  'Nenhum resultado encontrado',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                      ),
                                                ),
                                              ),
                                            )
                                            : ListView.builder(
                                              shrinkWrap: true,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                  ),
                                              itemCount: _filteredItems.length,
                                              itemBuilder: (context, index) {
                                                final item =
                                                    _filteredItems[index];
                                                final bool isSelected =
                                                    _selectedItem?.id ==
                                                    item.id;

                                                return Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap:
                                                        () => _selectItem(item),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16.0,
                                                            vertical: 12.0,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  item.name,
                                                                  style: Theme.of(
                                                                    context,
                                                                  ).textTheme.bodyLarge?.copyWith(
                                                                    color:
                                                                        isSelected
                                                                            ? Theme.of(
                                                                              context,
                                                                            ).colorScheme.primary
                                                                            : Theme.of(
                                                                              context,
                                                                            ).colorScheme.onSurface,
                                                                    fontWeight:
                                                                        isSelected
                                                                            ? FontWeight.bold
                                                                            : FontWeight.normal,
                                                                  ),
                                                                ),
                                                                if (item.description !=
                                                                    null)
                                                                  Text(
                                                                    item.description!,
                                                                    style: Theme.of(
                                                                      context,
                                                                    ).textTheme.bodySmall?.copyWith(
                                                                      color:
                                                                          Theme.of(
                                                                            context,
                                                                          ).colorScheme.onSurfaceVariant,
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                          if (isSelected)
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate(
                            effects: [
                              FadeEffect(
                                duration: Duration(milliseconds: 300),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _filterItems(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        _filteredItems =
            widget.items.where((item) => item.matchesSearch(value)).toList();
      }
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _selectItem(DropdownItem item) {
    setState(() {
      _selectedItem = item;
    });
    widget.onChanged?.call(item);
    _closeDropdown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label.isNotEmpty && !widget.dense)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  Text(
                    widget.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (widget.isRequired)
                    Text(
                      '*',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
            ),
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      widget.errorText != null
                          ? colorScheme.error
                          : _isOpen
                          ? colorScheme.primary
                          : colorScheme.outline,
                  width: 1.5,
                ),
                color:
                    widget.isEnabled
                        ? colorScheme.surface
                        : colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: widget.dense ? 10.0 : 14.0,
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      widget.prefixIcon!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.dense && widget.label.isNotEmpty)
                            Text(
                              widget.label + (widget.isRequired ? ' *' : ''),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color:
                                    widget.isEnabled
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          Text(
                            _selectedItem?.name ?? widget.hint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  _selectedItem != null
                                      ? widget.isEnabled
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurfaceVariant
                                      : colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_selectedItem?.description != null &&
                              !widget.dense)
                            Text(
                              _selectedItem!.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color:
                          widget.isEnabled
                              ? _isOpen
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant
                              : colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate(
            target: _isOpen ? 1 : 0,
            effects: [
              const ScaleEffect(
                begin: Offset(1.0, 1.0),
                end: Offset(1.01, 1.0),
                duration: Duration(milliseconds: 150),
              ),
            ],
          ),
          if (widget.errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 6),
              child: Text(
                widget.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
