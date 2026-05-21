import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:imat_app/model/imat/credit_card.dart';
import 'package:imat_app/model/imat/customer.dart';
import 'package:imat_app/model/imat/order.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/util/category_names.dart';
import 'package:imat_app/model/imat/product_detail.dart';
import 'package:imat_app/model/imat/saved_shopping_cart.dart';
import 'package:imat_app/model/imat/shopping_cart.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/model/imat/user.dart';
import 'package:imat_app/model/internet_handler.dart';

/// Centralt data-management för iMat-appen.
/// Ansvarar för:
/// - Hantering av produktkatalog, kategorier och sökfiltrering
/// - Kundinformation (namn, email, telefon, adress, kreditkort)
/// - Kundvagn med items och totalpris
/// - Sparade varukorgar (server-only, lagras i server extras)
/// - Köphistorik/ordrar (server-only)
/// - Favoriter (server-only, lagras i server extras)
/// - Inloggning/autentisering
///
/// Persistence: Använder InternetHandler för server-kommunikation.
/// Sparade varukorgar, ordrar och favoriter lagras INTE lokalt medan inloggad.
class ImatDataHandler extends ChangeNotifier {
  // Initializes the IMatDataHandler
  ImatDataHandler() {
    _setUp();
  }

  // Never changing, only loaded on startup
  List<Product> get products => _products;

  List<ProductDetail> get details => _details;

  // Access a list of all previous orders
  List<Order> get orders => _orders;

  List<SavedShoppingCart> get savedShoppingCarts => List.unmodifiable(_savedShoppingCarts);

  //
  // Handle product selections
  //

  // Returnernar de produkter som är valda
  List<Product> get selectProducts => _selectProducts;

  String get searchQuery => _searchQuery;

  // Nollställer urvalet till alla produkter.
  // Anropar notifyListeners så att GUI:t får
  // veta att urvalet ändrats.
  void selectAllProducts() {
    _selectProducts.clear();
    _selectProducts.addAll(_products);
    _searchQuery = '';
    notifyListeners();
  }

  // Välj alla favoritmarkerade produkter.
  // Detta sätter selectProducts till de produkter
  // som markerats som favoriter och informerar GUI:t
  // om att urvalet har ändrats
  void selectFavorites() {
    _selectProducts.clear();
    _selectProducts.addAll(favorites);
    notifyListeners();
  }

  // A list of products that has been produced somehow.
  // Sätter selectProducts till innehållet i listan selection.
  // Med denna metod kan man sätta urvalet till vad som helst.
  // Meddelar GUI:t att urvalet har ändrats
  void selectSelection(List<Product> selection) {
    _selectProducts.clear();
    _selectProducts.addAll(selection);
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      selectAllProducts();
    } else {
      selectSelection(findProducts(query));
    }
  }

  // Returnerar alla produkter som hör till category.
  // Med denna och setSelection kan man sätta urvalet till en viss kategori.
  // Meddelar GUI:t att urvalet har ändrats.
  List<Product> findProductsByCategory(ProductCategory category) {
    return products.where((product) => product.category == category).toList();
  }

  // Returnerar en lista med alla produkter vars namn matchar search.
  // Sökningen görs utan hänsyn till case och var i strängen search finns.
  // T ex så hittar "me" både Clementin och Lime.
  List<Product> findProducts(String search) {
    final lowerSearch = search.toLowerCase();

    // Match by product name
    final byName = products.where((product) {
      final name = product.name.toLowerCase();
      return name.contains(lowerSearch);
    }).toList();

    // Match by category display name (e.g. searching "godis" should match SWEET)
    final matchingCategories = orderedCategories.where((cat) {
      final catName = getCategoryName(cat).toLowerCase();
      return catName.contains(lowerSearch);
    }).toList();

    final byCategory = products
        .where((product) => matchingCategories.contains(product.category))
        .toList();

    // Combine and deduplicate
    final combined = <Product>[];
    for (final p in byName) {
      combined.add(p);
    }
    for (final p in byCategory) {
      if (!combined.any((c) => c.productId == p.productId)) combined.add(p);
    }

    return combined;
  }

  // Returnerar produkten med productId idNbr eller null
  // om produkten inte finns med i sortimentet.
  Product? getProduct(int idNbr) {
    for (final product in _products) {
      if (product.productId == idNbr) {
        return product;
      }
    }
    return null;
  }

  //
  // Manage favorites
  //

  // Returnerar en lista med alla favoritmarkerade produkter.
  List<Product> get favorites => _favorites.values.toList();

  // Returnerar om product är markerad som favorit.
  bool isFavorite(Product product) {
    return _favorites[product.productId] != null;
  }

  // Returnerar hur många av produkten som finns i kundvagnen.
  double shoppingCartAmount(Product product) {
    for (final item in _shoppingCart.items) {
      if (item.product.productId == product.productId) {
        return item.amount;
      }
    }
    return 0.0;
  }

  // 'Togglar' om product är favorit eller inte.
  // Dvs om produkten är favorit tas den bort annars läggs
  // läggs den till.
  // Meddelar GUI:t att data har ändrats och uppdaterar på servern
  void toggleFavorite(Product product) {
    var pid = product.productId;

    if (_favorites.containsKey(pid)) {
      _favorites.remove(pid);
    } else {
      _favorites[pid] = product;
    }

    _persistUserFavorites();
    notifyListeners();
  }

  CreditCard getCreditCard() => _creditCard;

  // Sparar information till servern och
  // meddelar gränssnittet att data ändrats
  Future<void> setCreditCard(CreditCard card) async {
    _creditCard.cardType = card.cardType;
    _creditCard.holdersName = card.holdersName;
    _creditCard.validMonth = card.validMonth;
    _creditCard.validYear = card.validYear;
    _creditCard.cardNumber = card.cardNumber;
    _creditCard.verificationCode = card.verificationCode;

    String _ = await InternetHandler.setCreditCard(_creditCard);
    notifyListeners();
  }

  Customer getCustomer() => _customer;

  // Sparar information till servern och
  // meddelar gränssnittet att data ändrats
  Future<void> setCustomer(Customer customer) async {
    _customer.firstName = customer.firstName;
    _customer.lastName = customer.lastName;
    _customer.phoneNumber = customer.phoneNumber;
    _customer.mobilePhoneNumber = customer.mobilePhoneNumber;
    _customer.email = customer.email;
    _customer.address = customer.address;
    _customer.postCode = customer.postCode;
    _customer.postAddress = customer.postAddress;

    String _ = await InternetHandler.setCustomer(_customer);
    notifyListeners();
  }

  // Sparar information till servern och
  // meddelar gränssnittet att data ändrats
  User getUser() => _user;

  void setUser(User user) async {
    _user.userName = user.userName;
    _user.password = user.password;

    String _ = await InternetHandler.setUser(_user);
    notifyListeners();
  }

  // Load user-related data (customer, creditcard, shoppingcart, orders)
  Future<void> loadUserData() async {
    try {
      _clearUserScopedData();

      var response = await InternetHandler.getUser();
      if (response.isNotEmpty) {
        var singleJson = jsonDecode(response);
        _user = User.fromJson(singleJson);
      }

      response = await InternetHandler.getCustomer();
      if (response.isNotEmpty) {
        var singleJson = jsonDecode(response);
        _customer = Customer.fromJson(singleJson);
      }

      response = await InternetHandler.getCreditCard();
      if (response.isNotEmpty) {
        var singleJson = jsonDecode(response);
        _creditCard = CreditCard.fromJson(singleJson);
      }

      response = await InternetHandler.getShoppingCart();
      if (response.isNotEmpty) {
        var singleJson = jsonDecode(response);
        _shoppingCart = ShoppingCart.fromJson(singleJson);
      }

      response = await InternetHandler.getExtras();
      if (response.isNotEmpty) {
        _extras = jsonDecode(response);
        // Do not load saved shopping carts or user orders into local state
        // while the user is logged in; UI will fetch these directly from the server.
        _loadUserFavoritesFromExtras();
      }

      // Load orders from server and store them persistently
      response = await InternetHandler.getOrders();
      if (response.isNotEmpty) {
        try {
          var jsonData = jsonDecode(response) as List;
          _orders.clear();
          for (final rawOrder in jsonData) {
            final order = Order.fromJson(rawOrder as Map<String, dynamic>);
            _orders.add(order);
          }
          _persistUserOrders();
        } catch (e) {
          debugPrint('loadUserData: error parsing orders: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('loadUserData error: $e');
    }
  }

  // Convenience: verify credentials against the stored server user and fetch profile data
  Future<void> login(String userName, String password) async {
    final response = await InternetHandler.getUser();
    if (response.isEmpty) {
      throw Exception('Inget konto finns ännu. Skapa ett konto först.');
    }

    final storedUser = User.fromJson(jsonDecode(response));
    final userMatches = storedUser.userName == userName && storedUser.password == password;
    if (!userMatches) {
      throw Exception('Fel användarnamn eller lösenord.');
    }

    _clearUserScopedData();
    await loadUserData();
  }

  // Log out locally (does not call server)
  void logout() {
    _clearUserScopedData();
    notifyListeners();
  }

  // Returnerar ProductDetail för produkten p
  // eller null om information saknas
  ProductDetail? getDetail(Product p) {
    return getDetailWithId(p.productId);
  }

  // Returnerar ProductDetail för produkten p
  // med idNbr eller null om information saknas
  ProductDetail? getDetailWithId(int idNbr) {
    for (ProductDetail d in _details) {
      if (d.productId == idNbr) {
        return d;
      }
    }
    return null;
  }

  // Returnerar en Map med strängar som nycklar och
  // något som kan uttryckas med json som värde.
  Map<String, dynamic> getExtras() {
    return _extras;
  }

  // Lägg till ett nytt värde för nyckeln key.
  // Om key redan finns så ersätts dess värde med jsonData.
  // jsonData ska vara en bastyp, en lista eller en map.
  // Sparar data till servern och meddelar GUI:t att data ändrats
  void addExtra(String key, dynamic jsonData) {
    _extras[key] = jsonData;
    unawaited(setExtras(_extras));
  }

  // Tar bort key från extras.
  // Sparar data till servern och meddelar GUI:t att data ändrats.
  void removeExtra(String key) {
    _extras.remove(key);
    unawaited(setExtras(_extras));
  }

  // Sparar extras till servern och meddelar GUI:t att data ändrats.
  // Om man ändrar mapen som returneras från getExtras direkt så
  // måste denna metod anropas för att data ska sparas och GUI:t uppdateras
  // annars behöver man inte använda den.
  Future<void> setExtras(Map<String, dynamic> extras) async {
    await InternetHandler.setExtras(extras);
    notifyListeners();
  }

  Future<void> saveShoppingCart(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || _shoppingCart.items.isEmpty) {
      return;
    }

    // Build the SavedShoppingCart JSON
    final newCart = SavedShoppingCart(
      name: trimmedName,
      savedAt: DateTime.now(),
      cart: ShoppingCart(
        _shoppingCart.items
            .map((item) => ShoppingItem(item.product, amount: item.amount))
            .toList(),
      ),
    );

    // Fetch extras from server, update savedShoppingCartsByUser for this user, and save immediately.
    final userKey = _activeUserKey();
    if (userKey == null) return;

    try {
      final extrasRaw = await InternetHandler.getExtras();
      Map<String, dynamic> extras = {};
      if (extrasRaw.isNotEmpty) {
        extras = jsonDecode(extrasRaw) as Map<String, dynamic>;
      }
      final savedByUser = extras[_savedShoppingCartsByUserKey];
      Map<String, dynamic> map = {};
      if (savedByUser is Map) {
        map = Map<String, dynamic>.from(savedByUser);
      }
      final existing = <dynamic>[];
      final list = map[userKey];
      if (list is List) existing.addAll(list);
      // Remove any with same name (case-insensitive)
      existing.removeWhere((e) {
        try {
          final m = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e);
          return (m['name'] as String).toLowerCase() == trimmedName.toLowerCase();
        } catch (_) {
          return false;
        }
      });
      existing.insert(0, newCart.toJson());
      map[userKey] = existing;
      extras[_savedShoppingCartsByUserKey] = map;
      await InternetHandler.setExtras(extras);
      notifyListeners();
    } catch (e) {
      debugPrint('saveShoppingCart: error saving to server: $e');
    }
  }

  /// Save a shopping cart with the provided list of [items] under [name].
  /// This allows saving a subset of the current shopping cart.
  Future<void> saveShoppingCartWithItems(String name, List<ShoppingItem> items) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || items.isEmpty) {
      return;
    }

    final newCart = SavedShoppingCart(
      name: trimmedName,
      savedAt: DateTime.now(),
      cart: ShoppingCart(items.map((item) => ShoppingItem(item.product, amount: item.amount)).toList()),
    );

    final userKey = _activeUserKey();
    if (userKey == null) return;

    try {
      final extrasRaw = await InternetHandler.getExtras();
      Map<String, dynamic> extras = {};
      if (extrasRaw.isNotEmpty) {
        extras = jsonDecode(extrasRaw) as Map<String, dynamic>;
      }
      final savedByUser = extras[_savedShoppingCartsByUserKey];
      Map<String, dynamic> map = {};
      if (savedByUser is Map) {
        map = Map<String, dynamic>.from(savedByUser);
      }
      final existing = <dynamic>[];
      final list = map[userKey];
      if (list is List) existing.addAll(list);
      existing.removeWhere((e) {
        try {
          final m = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e);
          return (m['name'] as String).toLowerCase() == trimmedName.toLowerCase();
        } catch (_) {
          return false;
        }
      });
      existing.insert(0, newCart.toJson());
      map[userKey] = existing;
      extras[_savedShoppingCartsByUserKey] = map;
      await InternetHandler.setExtras(extras);
      notifyListeners();
    } catch (e) {
      debugPrint('saveShoppingCartWithItems: error saving to server: $e');
    }
  }

  Future<void> _persistSavedShoppingCarts() async {
    // Deprecated: persistence is now done directly against server in save methods.
    return;
  }

  void _loadSavedShoppingCartsFromExtras() {
    _savedShoppingCarts.clear();
    final savedCartsByUser = _ensureExtrasMap(_savedShoppingCartsByUserKey);
    if (savedCartsByUser is! Map) {
      return;
    }

    for (final raw in savedCartsByUser.values) {
      if (raw is! List) continue;
      for (final entry in raw) {
        if (entry is Map<String, dynamic>) {
          _savedShoppingCarts.add(SavedShoppingCart.fromJson(entry));
        } else if (entry is Map) {
          _savedShoppingCarts.add(SavedShoppingCart.fromJson(Map<String, dynamic>.from(entry)));
        }
      }
    }
  }

  void _clearUserScopedData() {
    _user = User('', '');
    _favorites.clear();
    _customer = Customer('', '', '', '', '', '', '', '');
    _creditCard = CreditCard('', '', 12, 25, '', 0);
    _shoppingCart = ShoppingCart([]);
    _orders.clear();
    _extras = {};
    _savedShoppingCarts.clear();
  }

  void removeSavedShoppingCart(String name) {
    // Remove the named saved cart on the server for all users if present.
    unawaited(() async {
      try {
        final extrasRaw = await InternetHandler.getExtras();
        Map<String, dynamic> extras = {};
        if (extrasRaw.isNotEmpty) {
          extras = jsonDecode(extrasRaw) as Map<String, dynamic>;
        }
        final savedByUser = extras[_savedShoppingCartsByUserKey];
        if (savedByUser is Map) {
          final map = Map<String, dynamic>.from(savedByUser);
          bool changed = false;
          for (final key in map.keys.toList()) {
            final list = map[key];
            if (list is List) {
              final filtered = list.where((e) {
                try {
                  final m = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e);
                  return !(m['name'] == name);
                } catch (_) {
                  return true;
                }
              }).toList();
              if (filtered.length != list.length) {
                map[key] = filtered;
                changed = true;
              }
            }
          }
          if (changed) {
            extras[_savedShoppingCartsByUserKey] = map;
            await InternetHandler.setExtras(extras);
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint('removeSavedShoppingCart error: $e');
      }
    }());
  }

  /// Fetch saved shopping carts from the server (aggregated across users).
  Future<List<Map<String, dynamic>>> fetchSavedShoppingCartsFromServer() async {
    final List<Map<String, dynamic>> aggregated = [];
    try {
      final extrasRaw = await InternetHandler.getExtras();
      if (extrasRaw.isEmpty) return aggregated;
      final extras = jsonDecode(extrasRaw) as Map<String, dynamic>;
      final savedByUser = extras[_savedShoppingCartsByUserKey];
      if (savedByUser is Map) {
        for (final entry in savedByUser.entries) {
          final userKey = entry.key;
          final rawList = entry.value;
          if (rawList is List) {
            for (final raw in rawList) {
              try {
                final map = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw);
                aggregated.add({'cart': map, 'owner': userKey});
              } catch (_) {
                // ignore malformed
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('fetchSavedShoppingCartsFromServer error: $e');
    }
    return aggregated;
  }

  void addSavedShoppingCartToShoppingCart(SavedShoppingCart savedCart) {
    for (final item in savedCart.cart.items) {
      _shoppingCart.addItem(ShoppingItem(item.product, amount: item.amount));
    }

    setShoppingCart();
  }

  // Returnerar bilden som hör till produkten p.
  // Om bilden inte finns cachad returneras en tillfällig bild.
  // När bilden har hämtats meddelas gränssnittet och bilden visas
  // automatiskt om getImage använts i ett sammanhang som använder watch.
  // getImage använder getImageData med Boxfit.cover.
  Image getImage(Product p) {
    String url = InternetHandler.getImageUrl(p.productId);

    Image? image = _getImage(url);

    bool imageFound = image != null;

    return imageFound ? image : Image.asset('assets/images/placeholder.png');
  }

  // Can be used to create desired images using
  // Image.memory
  // final bytes = getImageData(product);
  // if (bytes != null)
  // Image img = Image.memory(bytes + other parameters)

  // Returnerar bild-data tillhörande produktbilden för p.
  // Om bilden inte är cachad returneras null.
  // När bilden har hämtats uppdateras resultatet precis som
  // för getImage. Man behöver själv hantera null. T ex något i stil med
  // var data = getImageData(p);
  // Widget image = data ?? Image.memory(data) : CircularSpinner();
  // När man använder Image.memory kan man ange ett flertal parametrar
  // t ex storlek. Kolla dokumentationen för Image.
  Uint8List? getImageData(Product p) {
    String url = InternetHandler.getImageUrl(p.productId);

    return _getImageData(url);
  }

  // Returnerar kundvagnen. Så längt det är möjligt är det att
  // fördedra att ändra kundvagnen med metoderna nedan.
  // Om man gör något annat behöver man anropa setShoppingCart för
  // att ändringarna ska sparas.
  ShoppingCart getShoppingCart() => _shoppingCart;

  // Lägger till item i kundvagnen. Om den produkt som ingår i item redan finns
  // i kundvagnen så ökas mängden på det som fanns redan.
  // Uppdaterar till servern och meddelar GUI:t att kundvagnen ändrats.
  void shoppingCartAdd(ShoppingItem item) {
    //print('Adding ${item.product.name}');
    _shoppingCart.addItem(item);

    // Update and notify listeners
    setShoppingCart();
  }

  // Sätter exakt mängd av ett item i kundvagnen med en enda serveruppdatering.
  void shoppingCartSetAmount(ShoppingItem item, double amount) {
    _shoppingCart.setItemAmount(item, amount);

    setShoppingCart();
  }

  // Uppdaterar mängden som finns av item med delta.
  // Ett positiv värde ökar mängden och ett negativ minskar.
  // Om värdet blir <= 0 så tas item bort ur kundvagnen.
  // Uppdaterar till servern och meddelar GUI:t att kundvagnen ändrats.
  void shoppingCartUpdate(ShoppingItem item, {double delta = 0.0}) {
    //print('Adding ${item.product.name}');
    _shoppingCart.updateItem(item, delta: delta);

    // Update and notify listeners
    setShoppingCart();
  }

  // Tar bort item från kundvagnen.
  // Uppdaterar till servern och meddelar GUI:t att kundvagnen ändrats.
  void shoppingCartRemove(ShoppingItem item) {
    //print('Removing ${item.product.name}');
    _shoppingCart.removeItem(item);

    // Update and notify listeners
    setShoppingCart();
  }

  // Tömmer kundvagnen.
  // Uppdaterar på servern och meddelar GUI:t.
  void shoppingCartClear() {
    _shoppingCart.clear();

    // Update and notify listeners
    setShoppingCart();
  }

  // Lägger till alla items från en order i kundvagnen utan att rensa något.
  // Uppdaterar kundvagnen på servern en gång efter att alla items lagts till.
  Future<void> addOrderToShoppingCart(Order order) async {
    for (final item in order.items) {
      _shoppingCart.addItem(ShoppingItem(item.product, amount: item.amount));
    }

    await InternetHandler.setShoppingCart(_shoppingCart);
    notifyListeners();
  }

  double shoppingCartTotal() {
    double total = 0;

    for (final item in _shoppingCart.items) {
      total = total + item.amount * item.product.price;
    }
    return total;
  }

  // Uppdaterar kundvagnen på servern och
  // meddelar GUI:t att kundvagnen ändrats.
  void setShoppingCart() async {
    await InternetHandler.setShoppingCart(_shoppingCart);
    notifyListeners();
  }

  Future<void> placeOrder() async {
    await InternetHandler.placeOrder();
    _shoppingCart.clear();
    notifyListeners();

    // Pick the latest server order and store it under the currently logged in user.
    var response = await InternetHandler.getOrders();

    if (response.isEmpty) {
      debugPrint('placeOrder: empty response from getOrders');
      return;
    }

    try {
      var jsonData = jsonDecode(response) as List;
      if (jsonData.isEmpty) {
        return;
      }

      final latestOrder = Order.fromJson(jsonData.last as Map<String, dynamic>);
      _orders.insert(0, latestOrder);
      _persistUserOrders();
      notifyListeners();
    } catch (e) {
      debugPrint('placeOrder decode error: $e');
    }
  }

  void reset() async {
    await InternetHandler.reset();

    // Clearing favorites
    _favorites.clear();

    // Fetching CreditCard, Customer & User
    var response = await InternetHandler.getCreditCard();
    var singleJson = jsonDecode(response);
    _creditCard = CreditCard.fromJson(singleJson);

    response = await InternetHandler.getCustomer();
    singleJson = jsonDecode(response);
    _customer = Customer.fromJson(singleJson);

    response = await InternetHandler.getUser();
    singleJson = jsonDecode(response);
    _user = User.fromJson(singleJson);

    // Remove orders
    _orders.clear();

    response = await InternetHandler.getShoppingCart();

    //print('Cart $response');
    singleJson = jsonDecode(response);
    _shoppingCart = ShoppingCart.fromJson(singleJson);

    response = await InternetHandler.getExtras();
    _extras = jsonDecode(response);
    _loadUserFavoritesFromExtras();

    notifyListeners();
  }

  ///
  // Code below this line is private and can be disregarded
  ///
  final List<Product> _products = [];

  final List<Product> _selectProducts = [];

  final List<ProductDetail> _details = [];

  final Map<int, Product> _favorites = {};

  User _user = User('', '');
  String _searchQuery = '';

  Customer _customer = Customer('', '', '', '', '', '', '', '');

  CreditCard _creditCard = CreditCard('', '', 12, 25, '', 0);

  ShoppingCart _shoppingCart = ShoppingCart([]);

  final List<Order> _orders = [];

  Map<String, dynamic> _extras = {};

  final List<SavedShoppingCart> _savedShoppingCarts = [];

  static const _savedShoppingCartsByUserKey = 'savedShoppingCartsByUser';
  static const _favoritesByUserKey = 'favoritesByUser';
  static const _ordersByUserKey = 'ordersByUser';

  //final Map<int, Image> _imageCache = HashMap();

  /*
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
*/

  //class ImageCacheProvider extends ChangeNotifier {
  /* import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
*/

  //class ImageCacheProvider extends ChangeNotifier {
  final Map<String, Uint8List> _imageData = {};
  final Set<String> _loadingUrls = {};
  final Queue<String> _queue = Queue();

  final int maxConcurrentRequests = 5;
  int _currentRequests = 0;

  //ImageCacheProvider({this.maxConcurrentRequests = 5});

  /// Students can use this to get raw image bytes
  Uint8List? _getImageData(String url) {
    _triggerLoadIfNeeded(url);
    return _imageData[url];
  }

  /// Students can use this to get an Image widget
  Image? _getImage(String url, {BoxFit fit = BoxFit.cover}) {
    final bytes = _getImageData(url);
    if (bytes != null) {
      return Image.memory(bytes, fit: fit);
    }
    return null;
  }

  void _triggerLoadIfNeeded(String url) {
    if (_imageData.containsKey(url) ||
        _loadingUrls.contains(url) ||
        _queue.contains(url)) {
      return;
    }

    _queue.add(url);
    _tryNext();
  }

  void _tryNext() {
    if (_currentRequests >= maxConcurrentRequests || _queue.isEmpty) return;

    final url = _queue.removeFirst();
    _loadingUrls.add(url);
    _currentRequests++;

    _fetch(url).whenComplete(() {
      _loadingUrls.remove(url);
      _currentRequests--;
      _tryNext();
    });
  }

  Future<void> _fetch(String url) async {
    //print(url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: InternetHandler.apiKeyHeader,
      );
      if (response.statusCode == 200) {
        _imageData[url] = response.bodyBytes;
        notifyListeners(); // So UI rebuilds if needed
      } else {
        debugPrint('Failed to load image $url: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching $url: $e');
    }
  }

  /*
  // Not working, there's no corresponding endpoint
  void setFavorites() async {
    String _ = await InternetHandler.setFavorites(favorites);
    notifyListeners();
  }
  */

  void _setUp() async {
    InternetHandler.kGroupId = 1;

    // Fetching all products
    var response = await InternetHandler.getProducts();

    //print(response);
    List<dynamic> jsonData = jsonDecode(response);

    _products.clear();
    _products.addAll(jsonData.map((item) => Product.fromJson(item)).toList());

    _selectProducts.clear();
    _selectProducts.addAll(_products);

    // Fetching product details
    response = await InternetHandler.getDetails();
    jsonData = jsonDecode(response);

    _details.clear();
    _details.addAll(
      jsonData.map((item) => ProductDetail.fromJson(item)).toList(),
    );

    // Fetching CreditCard, Customer & User
    response = await InternetHandler.getCreditCard();
    var singleJson = jsonDecode(response);
    _creditCard = CreditCard.fromJson(singleJson);

    response = await InternetHandler.getCustomer();
    singleJson = jsonDecode(response);
    _customer = Customer.fromJson(singleJson);

    response = await InternetHandler.getUser();
    singleJson = jsonDecode(response);
    _user = User.fromJson(singleJson);

    //print('User ${singleJson}');

    response = await InternetHandler.getShoppingCart();

    //print('Cart $response');
    singleJson = jsonDecode(response);
    _shoppingCart = ShoppingCart.fromJson(singleJson);

    response = await InternetHandler.getExtras();
    _extras = jsonDecode(response);
    _loadUserFavoritesFromExtras();
    _loadUserOrdersFromExtras();
    _loadSavedShoppingCartsFromExtras();

    /* Testcode

    print('New extras $_extras');
    _extras['Brand'] = 'Findus';

    var _ = await InternetHandler.setExtras(_extras);

    response = await InternetHandler.getExtras();
    _extras = jsonDecode(response);
    // Testcode

    print('Got ${_extras}');

     Testcode 
     */

    notifyListeners();
  }

  String? _activeUserKey() {
    final userName = _user.userName.trim();
    if (userName.isEmpty) {
      return null;
    }
    return userName.toLowerCase();
  }

  Map<String, dynamic> _ensureExtrasMap(String key) {
    final raw = _extras[key];
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  void _persistUserFavorites() {
    final userKey = _activeUserKey();
    if (userKey == null) {
      return;
    }

    final favoritesByUser = _ensureExtrasMap(_favoritesByUserKey);
    favoritesByUser[userKey] = _favorites.keys.toList();
    _extras[_favoritesByUserKey] = favoritesByUser;
    unawaited(setExtras(_extras));
  }

  void _loadUserFavoritesFromExtras() {
    _favorites.clear();

    final userKey = _activeUserKey();
    if (userKey == null) {
      return;
    }

    final favoritesByUser = _ensureExtrasMap(_favoritesByUserKey);
    final rawFavorites = favoritesByUser[userKey];
    if (rawFavorites is! List) {
      return;
    }

    for (final id in rawFavorites) {
      final intId = id is int ? id : int.tryParse('$id');
      if (intId == null) {
        continue;
      }
      final product = getProduct(intId);
      if (product != null) {
        _favorites[intId] = product;
      }
    }
  }

  Map<String, dynamic> _serializeOrder(Order order) {
    return {
      'orderNumber': order.orderNumber,
      'date': order.date.millisecondsSinceEpoch,
      'items': order.items.map((item) => item.toJson()).toList(),
    };
  }

  Order? _deserializeOrder(dynamic raw) {
    if (raw is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(raw);
    final rawItems = map['items'];
    if (rawItems is! List) {
      return null;
    }

    final items = <ShoppingItem>[];
    for (final entry in rawItems) {
      if (entry is Map<String, dynamic>) {
        items.add(ShoppingItem.fromJson(entry));
      } else if (entry is Map) {
        items.add(ShoppingItem.fromJson(Map<String, dynamic>.from(entry)));
      }
    }

    final orderNumber = map['orderNumber'] is int ? map['orderNumber'] as int : 0;
    final dateMs = map['date'] is int ? map['date'] as int : DateTime.now().millisecondsSinceEpoch;
    return Order(orderNumber, DateTime.fromMillisecondsSinceEpoch(dateMs), items);
  }

  /// Returns a list of all orders available to the client.
  ///
  /// First attempts to aggregate orders stored in `_extras['ordersByUser']`.
  /// If no orders are found there, falls back to fetching orders from
  /// the server via `InternetHandler.getOrders()`.
  Future<List<Order>> getAllOrders({bool refreshFromServer = false}) async {
    final List<Order> aggregated = [];
    try {
      final response = await InternetHandler.getOrders();
      if (response.isNotEmpty) {
        final jsonData = jsonDecode(response) as List;
        for (final rawOrder in jsonData) {
          try {
            final order = Order.fromJson(rawOrder as Map<String, dynamic>);
            aggregated.add(order);
          } catch (_) {
            // ignore malformed
          }
        }
      }
    } catch (e) {
      debugPrint('getAllOrders server fetch error: $e');
    }

    aggregated.sort((a, b) => b.date.compareTo(a.date));
    return aggregated;
  }

  void _persistUserOrders() {
    final userKey = _activeUserKey();
    if (userKey == null) {
      return;
    }

    final ordersByUser = _ensureExtrasMap(_ordersByUserKey);
    ordersByUser[userKey] = _orders.map(_serializeOrder).toList();
    _extras[_ordersByUserKey] = ordersByUser;
    unawaited(setExtras(_extras));
  }

  void _loadUserOrdersFromExtras() {
    _orders.clear();

    final userKey = _activeUserKey();
    if (userKey == null) {
      return;
    }

    final ordersByUser = _ensureExtrasMap(_ordersByUserKey);
    final rawOrders = ordersByUser[userKey];
    if (rawOrders is! List) {
      return;
    }

    for (final rawOrder in rawOrders) {
      final order = _deserializeOrder(rawOrder);
      if (order != null) {
        _orders.add(order);
      }
    }
  }
}
