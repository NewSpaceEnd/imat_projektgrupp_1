import 'package:flutter/material.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/util/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final orders = iMat.orders;
    final last = orders.isNotEmpty ? orders.last : null;

    return Scaffold(
      appBar: TopNavBar(title: 'Orderbekräftelse'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: last == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 88),
                  const SizedBox(height: 16),
                  const Text('Tack! Din beställning är genomförd.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('Till startsidan')),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 88),
                  const SizedBox(height: 12),
                  Text('Tack! Din beställning #${last.orderNumber} är genomförd.', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Datum: ${formatOrderDate(last.date)}'),
                  const SizedBox(height: 12),
                  const Text('Innehåll:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: last.items.length,
                      itemBuilder: (context, idx) {
                        final it = last.items[idx];
                        return ListTile(
                          title: Text(it.product.name),
                          subtitle: Text('${it.amount} ${it.product.unit}'),
                          trailing: Text('${(it.product.price * it.amount).toStringAsFixed(2)} kr'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Totalt: ${last.getTotal().toStringAsFixed(2)} kr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('Till startsidan')),
                ],
              ),
      ),
    );
  }
}
