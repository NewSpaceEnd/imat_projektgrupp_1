import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/util/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';

class OrderConfirmationPage extends StatelessWidget {
  static const double serviceFee = 25.0;
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPurpleSoft = Color(0xFFE2D7FF);

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
      appBar: const TopNavBar(),
      body: Container(
        color: const Color(0xFFF6F6F6),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: last == null
                    ? _ConfirmationShell(
                        title: 'Tack! Din beställning är genomförd.',
                        subtitle: 'Du hittar din orderhistorik på profilsidan.',
                        showOrderDetails: false,
                    orderLabel: null,
                        onHomePressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                        onPrint: null,
                        onEmail: null,
                        onFax: null,
                        items: const [],
                        orderSubtotal: 0,
                        appliedServiceFee: 0,
                        totalWithService: 0,
                      )
                    : _ConfirmationShell(
                        title: 'Tack! Din beställning #${last.orderNumber} är genomförd.',
                        subtitle: 'Datum: ${formatOrderDate(last.date)}',
                        showOrderDetails: true,
                        orderLabel: 'Order #${last.orderNumber}',
                        onHomePressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                        onPrint: () => _showExampleAction(
                          context,
                          'Utskrift',
                          'Kvitto skickas till skrivaren. Detta är ett exempel på utskrift.',
                        ),
                        onEmail: () => _showExampleAction(
                          context,
                          'E-post',
                          'Kvitto skulle skickas till din registrerade e-postadress som exempel.',
                        ),
                        onFax: () => _showExampleAction(
                          context,
                          'Fax',
                          'Kvitto skulle faxas till ett angivet nummer som exempel.',
                        ),
                        items: last.items,
                        orderSubtotal: orderSubtotal,
                        appliedServiceFee: appliedServiceFee,
                        totalWithService: totalWithService,
                      ),
              ),
            ),
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

class _ConfirmationShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showOrderDetails;
  final String? orderLabel;
  final VoidCallback onHomePressed;
  final VoidCallback? onPrint;
  final VoidCallback? onEmail;
  final VoidCallback? onFax;
  final List<ShoppingItem> items;
  final double orderSubtotal;
  final double appliedServiceFee;
  final double totalWithService;

  const _ConfirmationShell({
    required this.title,
    required this.subtitle,
    required this.showOrderDetails,
    required this.orderLabel,
    required this.onHomePressed,
    required this.onPrint,
    required this.onEmail,
    required this.onFax,
    required this.items,
    required this.orderSubtotal,
    required this.appliedServiceFee,
    required this.totalWithService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 92),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              if (orderLabel != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F1FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE1D3FF)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        orderLabel!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Köpet visas också i din orderhistorik.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (onPrint != null)
                      ElevatedButton.icon(
                        onPressed: onPrint,
                        icon: const Icon(Icons.print),
                        label: const Text('Skriv ut kvitto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrderConfirmationPage.accentPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (onEmail != null)
                      ElevatedButton.icon(
                        onPressed: onEmail,
                        icon: const Icon(Icons.email_outlined),
                        label: const Text('Skicka på mail'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrderConfirmationPage.accentPurpleSoft,
                          foregroundColor: const Color(0xFF2E2E34),
                        ),
                      ),
                    if (onFax != null)
                      ElevatedButton.icon(
                        onPressed: onFax,
                        icon: const Icon(Icons.fax),
                        label: const Text('Faxa kvitto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrderConfirmationPage.accentPurpleSoft,
                          foregroundColor: const Color(0xFF2E2E34),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showOrderDetails) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Köpta varor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _PurchasedItemsPreview(items: items),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Orderdetaljer', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...items.map((it) {
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
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onHomePressed,
            child: const Text('Till startsidan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: OrderConfirmationPage.accentPurple,
              foregroundColor: Colors.white,
            ),
          ),
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
