import 'package:projektgrupp1_imat/util/home_models.dart';

const List<String> homeCategories = [
  'Frukt och gront',
  'Charkuteri',
  'Fisk & skaldjur',
  'Mejeri',
  'Brod & kakor',
  'Vegetariskt',
  'Fardigmat',
  'Glass, godis & snacks',
];

const List<SectionData> homeSections = [
  SectionData(
    title: 'Frukt och gront',
    cta: 'Till all frukt och gront',
    products: [
      ProductData(
        country: 'Frankrike',
        name: 'Apple',
        detail: 'Pink Lady',
        unit: '0,18 kg',
        unitPrice: '35,91 kr/kg',
        price: '6,46 kr',
        art: ProductArtType.apple,
      ),
      ProductData(
        country: 'Ecuador',
        name: 'Banan',
        detail: '',
        unit: '0,18 kg',
        unitPrice: '23,82 kr/kg',
        price: '4,29 kr',
        art: ProductArtType.banana,
      ),
      ProductData(
        country: 'Sverige',
        name: 'Potatis',
        detail: '',
        unit: '0,10 kg',
        unitPrice: '12,25 kr/kg',
        price: '1,23 kr',
        art: ProductArtType.potato,
      ),
      ProductData(
        country: 'Nederlanderna',
        name: 'Chili',
        detail: 'Rod peppar',
        unit: '0,02 kg',
        unitPrice: '169,00 kr/kg',
        price: '3,37 kr',
        art: ProductArtType.chili,
      ),
      ProductData(
        country: 'Sverige',
        name: 'Gurka',
        detail: '',
        unit: '0,25 kg',
        unitPrice: '19,60 kr/kg',
        price: '4,90 kr',
        art: ProductArtType.potato,
      ),
    ],
  ),
  SectionData(title: 'Charkuteri', cta: 'Till all charkuteri', products: []),
];
