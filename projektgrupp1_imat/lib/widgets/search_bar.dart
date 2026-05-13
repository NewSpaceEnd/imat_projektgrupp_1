import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat_data_handler.dart';

class SearchBarWidget extends StatefulWidget {
  final ImatDataHandler iMat;
  final EdgeInsetsGeometry padding;
  final ValueChanged<String>? onSearchSubmitted;

  const SearchBarWidget({
    required this.iMat,
    this.padding = const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
    this.onSearchSubmitted,
    super.key,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  late VoidCallback _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.iMat.searchQuery);
    // Rebuild when controller text changes to show/hide clear button
    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener);
    // Clear text when iMat selection resets to all products
    widget.iMat.addListener(_onImatChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    widget.iMat.removeListener(_onImatChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Sök efter produkter',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.iMat.searchProducts('');
                  },
                )
              : null,
        ),
        onChanged: (query) => _onSearchChanged(query),
        onSubmitted: (query) {
          _onSearchChanged(query);
          if (query.trim().isNotEmpty) {
            widget.onSearchSubmitted?.call(query);
          }
        },
      ),
    );
  }

  void _onImatChanged() {
    final searchQuery = widget.iMat.searchQuery;

    if (_controller.text != searchQuery) {
      _controller.text = searchQuery;
      _controller.selection = TextSelection.collapsed(offset: searchQuery.length);
      return;
    }

    // If selection was reset to all products, clear the search text
    if (widget.iMat.selectProducts.length == widget.iMat.products.length && _controller.text.isNotEmpty) {
      _controller.clear();
    }
  }

  void _onSearchChanged(String query) {
    widget.iMat.searchProducts(query);
  }
}
