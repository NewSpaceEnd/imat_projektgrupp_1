import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat_data_handler.dart';

class SearchBarWidget extends StatefulWidget {
  final ImatDataHandler iMat;

  const SearchBarWidget({required this.iMat, super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // Rebuild when controller text changes to show/hide clear button
    _controller.addListener(() => setState(() {}));
    // Clear text when iMat selection resets to all products
    widget.iMat.addListener(_onImatChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    widget.iMat.removeListener(_onImatChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
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
                    widget.iMat.selectAllProducts();
                  },
                )
              : null,
        ),
        onChanged: (query) => _onSearchChanged(query),
      ),
    );
  }

  void _onImatChanged() {
    // If selection was reset to all products, clear the search text
    if (widget.iMat.selectProducts.length == widget.iMat.products.length && _controller.text.isNotEmpty) {
      _controller.clear();
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      widget.iMat.selectAllProducts();
    } else {
      final results = widget.iMat.findProducts(query);
      widget.iMat.selectSelection(results);
    }
  }
}
