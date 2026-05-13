import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/customer.dart';
import 'package:imat_app/model/imat/order.dart';
import 'package:imat_app/model/imat/saved_shopping_cart.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/util/date_formatter.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:provider/provider.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final handler = context.watch<ImatDataHandler>();
    final customer = handler.getCustomer();
    final loggedIn = handler.getUser().userName.isNotEmpty;

    return Scaffold(
      appBar: const TopNavBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useStackedLayout = constraints.maxWidth < 980;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: useStackedLayout
                ? Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: _ProfileSidebar(
                          loggedIn: loggedIn,
                          onUserInfoTap: () => _showAccountInfo(context, handler),
                          onOrdersTap: () => _showOrders(context, handler),
                          onSavedCartsTap: () => _showSavedCarts(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _ProfileContent(
                          loggedIn: loggedIn,
                          customer: customer,
                          onSettingsTap: () => _showAccountInfo(context, handler),
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 190,
                        child: _ProfileSidebar(
                          loggedIn: loggedIn,
                          onUserInfoTap: () => _showAccountInfo(context, handler),
                          onOrdersTap: () => _showOrders(context, handler),
                          onSavedCartsTap: () => _showSavedCarts(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ProfileContent(
                          loggedIn: loggedIn,
                          customer: customer,
                          onSettingsTap: () => _showAccountInfo(context, handler),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  void _showAccountInfo(BuildContext context, ImatDataHandler handler) {
    final user = handler.getUser();
    final customer = handler.getCustomer();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kontoinformation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Användarnamn: ${user.userName}'),
              const SizedBox(height: 8),
              Text('Namn: ${customer.firstName} ${customer.lastName}'),
              const SizedBox(height: 8),
              Text('E-post: ${customer.email}'),
              const SizedBox(height: 8),
              Text(
                'Telefon: ${customer.phoneNumber.isNotEmpty ? customer.phoneNumber : customer.mobilePhoneNumber}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Stäng'),
            ),
          ],
        );
      },
    );
  }

  void _showSavedCarts(BuildContext context) {
    final handler = context.read<ImatDataHandler>();
    final savedCarts = handler.savedShoppingCarts;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sparade varukorgar'),
        content: SizedBox(
          width: double.maxFinite,
          height: 420,
          child: savedCarts.isEmpty
              ? const Center(child: Text('Inga sparade varukorgar ännu.'))
              : ListView.separated(
                  itemCount: savedCarts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final savedCart = savedCarts[index];
                    return _SavedCartCard(
                      savedCart: savedCart,
                      onRestore: () {
                        context.read<ImatDataHandler>().addSavedShoppingCartToShoppingCart(savedCart);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Varukorgen "${savedCart.name}" lades till i kundvagnen')),
                        );
                      },
                      onDelete: () {
                        context.read<ImatDataHandler>().removeSavedShoppingCart(savedCart.name);
                        Navigator.pop(context);
                        _showSavedCarts(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stäng'),
          ),
        ],
      ),
    );
  }

  void _showOrders(BuildContext context, ImatDataHandler handler) {
    final orders = handler.orders;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tidigare beställningar'),
          content: SizedBox(
            width: double.maxFinite,
            height: 420,
            child: orders.isEmpty
                ? const Center(child: Text('Inga ordrar hittades.'))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _OrderExpansionCard(
                        order: order,
                        onBuyAgain: () async {
                          await context.read<ImatDataHandler>().addOrderToShoppingCart(order);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Varorna lades till i kundvagnen')),
                          );
                        },
                        onPrint: () => _showOrderAction(
                          context,
                          'Utskrift',
                          'Det här är ett exempel på att skicka ordern till skrivaren.',
                        ),
                        onEmail: () => _showOrderAction(
                          context,
                          'E-post',
                          'Det här är ett exempel på att skicka ordern via e-post.',
                        ),
                        onFax: () => _showOrderAction(
                          context,
                          'Fax',
                          'Det här är ett exempel på att faxa orderkvitto.',
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Stäng'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderAction(BuildContext context, String title, String message) {
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

class _ProfileSidebar extends StatelessWidget {
  final bool loggedIn;
  final VoidCallback onUserInfoTap;
  final VoidCallback onOrdersTap;
  final VoidCallback onSavedCartsTap;

  const _ProfileSidebar({
    required this.loggedIn,
    required this.onUserInfoTap,
    required this.onOrdersTap,
    required this.onSavedCartsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Mina Sidor',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _ProfileMenuItem(label: 'Mina uppgifter', onTap: onUserInfoTap),
          _ProfileMenuItem(label: 'Köphistorik', onTap: onOrdersTap),
          _ProfileMenuItem(label: 'Sparade varukorgar', onTap: onSavedCartsTap),
          if (!loggedIn) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Logga in'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Skapa konto'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final bool loggedIn;
  final Customer customer;
  final VoidCallback onSettingsTap;

  const _ProfileContent({
    required this.loggedIn,
    required this.customer,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileTextField(
                              label: 'Namn',
                              initialValue: loggedIn ? customer.firstName : '',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileTextField(
                              label: 'Efternamn',
                              initialValue: loggedIn ? customer.lastName : '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ProfileTextField(
                        label: 'Personnummer',
                        initialValue: loggedIn ? customer.postCode : '',
                      ),
                      const SizedBox(height: 16),
                      _ProfileTextField(
                        label: 'Adress',
                        initialValue: loggedIn ? customer.address : '',
                      ),
                      const SizedBox(height: 16),
                      _ProfileTextField(
                        label: 'Telefonnummer',
                        initialValue: loggedIn ? customer.phoneNumber : customer.mobilePhoneNumber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 160,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: onSettingsTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBCA9F7),
                              foregroundColor: const Color(0xFF2E2E34),
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text(
                              'Inställningar',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 205,
                        height: 205,
                        decoration: const BoxDecoration(
                          color: Color(0xFFBCA9F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, size: 138, color: Color(0xFF2E3236)),
                      ),
                      const SizedBox(height: 28),
                      Container(height: 1.5, width: 180, color: Colors.black54),
                      const SizedBox(height: 20),
                      Container(height: 1.5, width: 140, color: Colors.black54),
                      const SizedBox(height: 16),
                      Container(height: 1.5, width: 140, color: Colors.black54),
                      const SizedBox(height: 16),
                      Container(height: 1.5, width: 140, color: Colors.black54),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final String label;
  final String initialValue;

  const _ProfileTextField({required this.label, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _SavedCartCard extends StatelessWidget {
  final SavedShoppingCart savedCart;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _SavedCartCard({
    required this.savedCart,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(savedCart.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${savedCart.cart.items.length} varor • Sparad ${formatOrderDate(savedCart.savedAt)}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDelete,
                    child: const Text('Ta bort'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRestore,
                    child: const Text('Lägg till i varukorg'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderExpansionCard extends StatelessWidget {
  final Order order;
  final VoidCallback onPrint;
  final VoidCallback onEmail;
  final VoidCallback onFax;
  final VoidCallback onBuyAgain;

  const _OrderExpansionCard({
    required this.order,
    required this.onPrint,
    required this.onEmail,
    required this.onFax,
    required this.onBuyAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text('Order ${order.orderNumber}'),
        subtitle: Text(
          '${formatOrderDate(order.date)} • ${order.items.length} varor • ${order.getTotal().toStringAsFixed(2)} kr',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: context.read<ImatDataHandler>().getImage(item.product),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'Antal: ${item.amount.toStringAsFixed(0)} • Pris: ${item.product.price.toStringAsFixed(2)} kr',
                        ),
                      ],
                    ),
                  ),
                  Text('${item.total.toStringAsFixed(2)} kr'),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Totalt', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${order.getTotal().toStringAsFixed(2)} kr', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: onPrint,
                icon: const Icon(Icons.print),
                label: const Text('Skriv ut'),
              ),
              OutlinedButton.icon(
                onPressed: onEmail,
                icon: const Icon(Icons.email_outlined),
                label: const Text('Maila'),
              ),
              OutlinedButton.icon(
                onPressed: onFax,
                icon: const Icon(Icons.fax),
                label: const Text('Faxa'),
              ),
              OutlinedButton.icon(
                onPressed: onBuyAgain,
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Köp igen'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
