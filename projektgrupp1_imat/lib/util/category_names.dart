import 'package:imat_app/model/imat/product.dart';

const List<ProductCategory> orderedCategories = [
    ProductCategory.ROOT_VEGETABLE,
    ProductCategory.CABBAGE,
    ProductCategory.VEGETABLE_FRUIT,
    ProductCategory.FRUIT,
    ProductCategory.CITRUS_FRUIT,
    ProductCategory.EXOTIC_FRUIT,
    ProductCategory.BERRY,
    ProductCategory.MELONS,
    ProductCategory.HERB,
    ProductCategory.POD,
    ProductCategory.POTATO_RICE,
    ProductCategory.PASTA,
    ProductCategory.MEAT,
    ProductCategory.FISH,
    ProductCategory.BREAD,
    ProductCategory.FLOUR_SUGAR_SALT,
    ProductCategory.DAIRIES,
    ProductCategory.COLD_DRINKS,
    ProductCategory.HOT_DRINKS,
    ProductCategory.NUTS_AND_SEEDS,
    ProductCategory.SWEET,
  ];

String getCategoryName(ProductCategory cat) {
  const categoryNames = {
    ProductCategory.ROOT_VEGETABLE: 'Rotfrukter',
    ProductCategory.CABBAGE: 'Kål',
    ProductCategory.VEGETABLE_FRUIT: 'Grönsaker',
    ProductCategory.FRUIT: 'Frukt och grönt',
    ProductCategory.CITRUS_FRUIT: 'Citrusfrukter',
    ProductCategory.EXOTIC_FRUIT: 'Exotisk frukt',
    ProductCategory.BERRY: 'Bär',
    ProductCategory.MELONS: 'Meloner',
    ProductCategory.HERB: 'Örter',
    ProductCategory.POD: 'Linser, ärtor & bönor',
    ProductCategory.POTATO_RICE: 'Potatis & ris',

    ProductCategory.PASTA: 'Pasta',
    
    ProductCategory.MEAT: 'Kött & Chark',
    ProductCategory.FISH: 'Fisk & skaldjur',
    
    ProductCategory.BREAD: 'Bröd',
    ProductCategory.FLOUR_SUGAR_SALT: 'Mjöl, socker & salt',
    
    ProductCategory.DAIRIES: 'Mejeri',
    
    ProductCategory.COLD_DRINKS: 'Kalla drycker',
    ProductCategory.HOT_DRINKS: 'Varma drycker',
    
    ProductCategory.NUTS_AND_SEEDS: 'Nötter & frön',
    
    ProductCategory.SWEET: 'Godis & snacks',

  };
  return categoryNames[cat] ?? cat.name;
}
