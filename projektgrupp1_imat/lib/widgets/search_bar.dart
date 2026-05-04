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
  }

  @override
  void dispose() {
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
        ),
        onChanged: (query) => _onSearchChanged(query),
      ),
    );
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
