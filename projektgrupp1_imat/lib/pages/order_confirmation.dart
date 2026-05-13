import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/util/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';

class OrderConfirmationPage extends StatelessWidget {
  static const double serviceFee = 25.0;

  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final orders = iMat.orders;
    final last = orders.isNotEmpty ? orders.last : null;
    final orderSubtotal = last?.getTotal() ?? 0;
    final appliedServiceFee = last == null || last.items.isEmpty ? 0.0 : serviceFee;
    final totalWithService = orderSubtotal + appliedServiceFee;

    return Scaffold(
      appBar: TopNavBar(title: 'Orderbekräftelse'),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: last == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 88),
                    const SizedBox(height: 16),
                    const Text(
                      'Tack! Din beställning är genomförd.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                      child: const Text('Till startsidan'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 88),
                    const SizedBox(height: 12),
                    Text(
                      'Tack! Din beställning #${last.orderNumber} är genomförd.',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Datum: ${formatOrderDate(last.date)}'),
                    const SizedBox(height: 16),
                    _ReceiptActions(
                      onPrint: () => _showExampleAction(context, 'Utskrift', 'Kvitto skickas till skrivaren. Detta är ett exempel på utskrift.'),
                      onEmail: () => _showExampleAction(context, 'E-post', 'Kvitto skulle skickas till din registrerade e-postadress som exempel.'),
                      onFax: () => _showExampleAction(context, 'Fax', 'Kvitto skulle faxas till ett angivet nummer som exempel.'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Köpta varor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    _PurchasedItemsPreview(items: last.items),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Orderdetaljer', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...last.items.map((it) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('${it.product.name} x${it.amount.toStringAsFixed(0)}'),
                                    ),
                                    Text('${it.total.toStringAsFixed(2)} kr'),
                                  ],
                                ),
                              );
                            }),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Varor totalt', style: TextStyle(fontSize: 14)),
                                Text('${orderSubtotal.toStringAsFixed(2)} kr'),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Serviceavgift', style: TextStyle(fontSize: 14)),
                                Text('${appliedServiceFee.toStringAsFixed(2)} kr'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Att betala', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(
                                  '${totalWithService.toStringAsFixed(2)} kr',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                      child: const Text('Till startsidan'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showExampleAction(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ReceiptActions extends StatelessWidget {
  final VoidCallback onPrint;
  final VoidCallback onEmail;
  final VoidCallback onFax;

  const _ReceiptActions({
    required this.onPrint,
    required this.onEmail,
    required this.onFax,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: onPrint,
          icon: const Icon(Icons.print),
          label: const Text('Skriv ut kvitto'),
        ),
        OutlinedButton.icon(
          onPressed: onEmail,
          icon: const Icon(Icons.email_outlined),
          label: const Text('Skicka på mail'),
        ),
        OutlinedButton.icon(
          onPressed: onFax,
          icon: const Icon(Icons.fax),
          label: const Text('Faxa kvitto'),
        ),
      ],
    );
  }
}

class _PurchasedItemsPreview extends StatelessWidget {
  final List<ShoppingItem> items;

  const _PurchasedItemsPreview({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 150,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: context.read<ImatDataHandler>().getImage(item.product),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Antal: ${item.amount.toStringAsFixed(0)}'),
                const SizedBox(height: 4),
                Text(
                  'Pris: ${item.product.price.toStringAsFixed(2)} kr',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  'Rad: ${item.total.toStringAsFixed(2)} kr',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
