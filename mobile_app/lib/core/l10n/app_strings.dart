import '../../providers/locale_provider.dart';

/// Small hand-rolled translation dictionary (English / Odia only, per the
/// app's language setting). Deliberately not using Flutter's gen-l10n /
/// MaterialLocalizations machinery — Odia isn't a stock Material locale and
/// this app only needs a handful of UI strings translated, not full ICU
/// pluralization or date/number formatting.
const Map<String, Map<AppLanguage, String>> _dict = {
  'good_day': {
    AppLanguage.english: 'Good day 👋',
    AppLanguage.odia: 'ଶୁଭ ଦିନ 👋',
  },
  'greeting': {
    AppLanguage.english: 'Hello,',
    AppLanguage.odia: 'ନମସ୍କାର,',
  },
  'search_hint': {
    AppLanguage.english: 'Search rice, oil, spices...',
    AppLanguage.odia: 'ଚାଉଳ, ତେଲ, ମସଲା ଖୋଜନ୍ତୁ...',
  },
  'bulk_ordering': {
    AppLanguage.english: 'BULK ORDERING',
    AppLanguage.odia: 'ଥୋକ ଅର୍ଡର',
  },
  'hero_title': {
    AppLanguage.english: 'Get a custom quotation\nfor your next event',
    AppLanguage.odia: 'ଆପଣଙ୍କ ଆସନ୍ତା ଅନୁଷ୍ଠାନ ପାଇଁ\nବିଶେଷ କୋଟେସନ ପାଆନ୍ତୁ',
  },
  'promo_badge': {
    AppLanguage.english: 'LIMITED TIME',
    AppLanguage.odia: 'ସୀମିତ ସମୟ',
  },
  'promo_title': {
    AppLanguage.english: 'Flat ₹100 OFF',
    AppLanguage.odia: 'ସିଧା ₹100 ଛାଡ',
  },
  'promo_subtitle': {
    AppLanguage.english: 'on your first bulk order — code WELCOME100',
    AppLanguage.odia: 'ଆପଣଙ୍କ ପ୍ରଥମ ଥୋକ ଅର୍ଡରରେ — କୋଡ WELCOME100',
  },
  'promo_cta': {
    AppLanguage.english: 'Shop Now',
    AppLanguage.odia: 'କିଣନ୍ତୁ',
  },
  'guided_entry_title': {
    AppLanguage.english: "Not sure where to start?",
    AppLanguage.odia: 'କେଉଁଠାରୁ ଆରମ୍ଭ କରିବେ ଜାଣି ନାହାଁନ୍ତି?',
  },
  'guided_entry_subtitle': {
    AppLanguage.english: "Answer 2 quick questions, we'll suggest items",
    AppLanguage.odia: '୨ଟି ଛୋଟ ପ୍ରଶ୍ନର ଉତ୍ତର ଦିଅନ୍ତୁ, ଆମେ ଦ୍ରବ୍ୟ ପରାମର୍ଶ ଦେବୁ',
  },
  'guided_appbar_title': {
    AppLanguage.english: 'Quick Start',
    AppLanguage.odia: 'ଶୀଘ୍ର ଆରମ୍ଭ',
  },
  'step_label': {
    AppLanguage.english: 'Step',
    AppLanguage.odia: 'ପାଦ',
  },
  'occasion_step_title': {
    AppLanguage.english: "What's the occasion?",
    AppLanguage.odia: "ଅବସର କ'ଣ?",
  },
  'occasion_step_subtitle': {
    AppLanguage.english: "Pick the event you're shopping for",
    AppLanguage.odia: 'ଆପଣ କେଉଁ ଅନୁଷ୍ଠାନ ପାଇଁ କିଣୁଛନ୍ତି ବାଛନ୍ତୁ',
  },
  'guest_step_title': {
    AppLanguage.english: 'How many guests?',
    AppLanguage.odia: 'କେତେ ଅତିଥି?',
  },
  'guest_step_subtitle': {
    AppLanguage.english: 'This helps us size your order right',
    AppLanguage.odia: 'ଏହା ଆପଣଙ୍କ ଅର୍ଡର ପରିମାଣ ଠିକ କରିବାରେ ସାହାଯ୍ୟ କରେ',
  },
  'guests_upto_50': {
    AppLanguage.english: 'Up to 50',
    AppLanguage.odia: '୫୦ ପର୍ଯ୍ୟନ୍ତ',
  },
  'guests_50_100': {
    AppLanguage.english: '50 – 100',
    AppLanguage.odia: '୫୦ – ୧୦୦',
  },
  'guests_100_250': {
    AppLanguage.english: '100 – 250',
    AppLanguage.odia: '୧୦୦ – ୨୫୦',
  },
  'guests_250_plus': {
    AppLanguage.english: '250+',
    AppLanguage.odia: '୨୫୦+',
  },
  'result_title': {
    AppLanguage.english: "You're all set!",
    AppLanguage.odia: 'ସବୁ ପ୍ରସ୍ତୁତ!',
  },
  'result_subtitle': {
    AppLanguage.english: 'Popular essentials to get your order started',
    AppLanguage.odia: 'ଆରମ୍ଭ କରିବାକୁ କିଛି ଲୋକପ୍ରିୟ ଆବଶ୍ୟକୀୟ ଦ୍ରବ୍ୟ',
  },
  'start_shopping': {
    AppLanguage.english: 'Start Shopping',
    AppLanguage.odia: 'କିଣିବା ଆରମ୍ଭ କରନ୍ତୁ',
  },
  'next': {
    AppLanguage.english: 'Next',
    AppLanguage.odia: 'ପରବର୍ତ୍ତୀ',
  },
  'back': {
    AppLanguage.english: 'Back',
    AppLanguage.odia: 'ପଛକୁ',
  },
  'shop_by_occasion': {
    AppLanguage.english: 'Shop by Occasion',
    AppLanguage.odia: 'ଅବସର ଅନୁସାରେ କିଣନ୍ତୁ',
  },
  'celebrations': {
    AppLanguage.english: 'Celebrations',
    AppLanguage.odia: 'ଉତ୍ସବ',
  },
  'business_bulk': {
    AppLanguage.english: 'Business & Bulk',
    AppLanguage.odia: 'ବ୍ୟବସାୟ ଓ ଥୋକ',
  },
  'categories': {
    AppLanguage.english: 'Categories',
    AppLanguage.odia: 'ବର୍ଗ',
  },
  'see_all': {
    AppLanguage.english: 'See all',
    AppLanguage.odia: 'ସବୁ ଦେଖନ୍ତୁ',
  },
  'popular_bulk_products': {
    AppLanguage.english: 'Popular Bulk Products',
    AppLanguage.odia: 'ଲୋକପ୍ରିୟ ଥୋକ ଦ୍ରବ୍ୟ',
  },
  'shop_by_category': {
    AppLanguage.english: 'Shop by Category',
    AppLanguage.odia: 'ବର୍ଗ ଅନୁସାରେ କିଣନ୍ତୁ',
  },
  'more': {
    AppLanguage.english: 'More',
    AppLanguage.odia: 'ଅଧିକ',
  },
  'swipe_categories_hint': {
    AppLanguage.english: 'Swipe for more categories',
    AppLanguage.odia: 'ଅଧିକ ବର୍ଗ ପାଇଁ ସ୍ୱାଇପ କରନ୍ତୁ',
  },
  'recent_orders': {
    AppLanguage.english: 'Recent Orders',
    AppLanguage.odia: 'ସାମ୍ପ୍ରତିକ ଅର୍ଡର',
  },
  'view_all': {
    AppLanguage.english: 'View all',
    AppLanguage.odia: 'ସବୁ ଦେଖନ୍ତୁ',
  },
  'no_products_yet': {
    AppLanguage.english: 'No products available yet. Check back soon.',
    AppLanguage.odia: 'ଏବେ କୌଣସି ଦ୍ରବ୍ୟ ନାହିଁ। ଟିକିଏ ପରେ ଦେଖନ୍ତୁ।',
  },
  'profile': {
    AppLanguage.english: 'Profile',
    AppLanguage.odia: 'ପ୍ରୋଫାଇଲ',
  },
  'addresses': {
    AppLanguage.english: 'Addresses',
    AppLanguage.odia: 'ଠିକଣା',
  },
  'addresses_subtitle': {
    AppLanguage.english: 'Manage saved delivery addresses',
    AppLanguage.odia: 'ସେଭ ହୋଇଥିବା ଠିକଣା ପରିଚାଳନା କରନ୍ତୁ',
  },
  'my_orders': {
    AppLanguage.english: 'My Orders',
    AppLanguage.odia: 'ମୋର ଅର୍ଡର',
  },
  'my_orders_subtitle': {
    AppLanguage.english: 'View your complete order history',
    AppLanguage.odia: 'ଆପଣଙ୍କ ସମସ୍ତ ଅର୍ଡର ଇତିହାସ ଦେଖନ୍ତୁ',
  },
  'support': {
    AppLanguage.english: 'Support',
    AppLanguage.odia: 'ସହାୟତା',
  },
  'support_subtitle': {
    AppLanguage.english: 'Chat with our support team',
    AppLanguage.odia: 'ଆମ ସହାୟତା ଦଳ ସହିତ କଥାବାର୍ତ୍ତା କରନ୍ତୁ',
  },
  'dark_mode': {
    AppLanguage.english: 'Dark Mode',
    AppLanguage.odia: 'ଡାର୍କ ମୋଡ',
  },
  'dark_mode_subtitle': {
    AppLanguage.english: 'Toggle the app appearance',
    AppLanguage.odia: 'ଆପ ର ରୂପ ପରିବର୍ତ୍ତନ କରନ୍ତୁ',
  },
  'language': {
    AppLanguage.english: 'Language',
    AppLanguage.odia: 'ଭାଷା',
  },
  'language_subtitle': {
    AppLanguage.english: 'English',
    AppLanguage.odia: 'ଓଡ଼ିଆ',
  },
  'choose_language': {
    AppLanguage.english: 'Choose language',
    AppLanguage.odia: 'ଭାଷା ବାଛନ୍ତୁ',
  },
  'english': {
    AppLanguage.english: 'English',
    AppLanguage.odia: 'ଇଂରାଜୀ (English)',
  },
  'odia': {
    AppLanguage.english: 'Odia',
    AppLanguage.odia: 'ଓଡ଼ିଆ (Odia)',
  },
  'log_out': {
    AppLanguage.english: 'Log Out',
    AppLanguage.odia: 'ଲଗ ଆଉଟ',
  },
};

/// Looks up [key] for [lang], falling back to English then to the key
/// itself so a missing translation never crashes the UI.
String t(AppLanguage lang, String key) {
  final entry = _dict[key];
  if (entry == null) return key;
  return entry[lang] ?? entry[AppLanguage.english] ?? key;
}
