import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { en, ru, kk }

class LocalizationService {
  static const String _languageKey = 'app_language';
  late SharedPreferences _prefs;

  AppLanguage _currentLanguage = AppLanguage.ru;

  AppLanguage get currentLanguage => _currentLanguage;

  static final LocalizationService _instance = LocalizationService._internal();

  LocalizationService._internal();

  factory LocalizationService() {
    return _instance;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguage = _prefs.getString(_languageKey);
    if (savedLanguage != null) {
      _currentLanguage = AppLanguage.values.firstWhere(
            (lang) => lang.toString() == 'AppLanguage.$savedLanguage',
        orElse: () => AppLanguage.ru,
      );
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    await _prefs.setString(_languageKey, language.toString().split('.').last);
  }

  String getLocaleCode() {
    switch (_currentLanguage) {
      case AppLanguage.ru:
        return 'ru';
      case AppLanguage.kk:
        return 'kk';
      case AppLanguage.en:
        return 'en';
    }
  }

  Map<String, String> getTranslations() {
    switch (_currentLanguage) {
      case AppLanguage.ru:
        return _russianTranslations;
      case AppLanguage.kk:
        return _kazakhTranslations;
      case AppLanguage.en:
        return _englishTranslations;
    }
  }

  String translate(String key) {
    final translations = getTranslations();
    return translations[key] ?? key;
  }
}

const Map<String, String> _englishTranslations = {
  'welcome_back': 'Welcome back,',
  'my_accounts': 'My Accounts',
  'see_all_transactions': 'See All Transactions',
  'home': 'Home',
  'transfer': 'Transfer',
  'loans': 'Loans',
  'history': 'History',
  'cards': 'Cards',
  'scan': 'Scan',
  'bills': 'Bills',
  'total_balance': 'Total Balance',
  'settings': 'Settings',
  'language': 'Language',
  'theme': 'Theme',
  'light': 'Light',
  'dark': 'Dark',
  'kazakh': 'Қазақша',
  'russian': 'Русский',
  'english': 'English',
  'transfer_money': 'Transfer Money',
  'between_accounts': 'Between Accounts',
  'to_other_cards': 'To Other Cards',
  'international': 'International',
  'from_account': 'From Account',
  'select_account': 'Select account',
  'to_recipient': 'To Recipient',
  'select_recipient': 'Select recipient',
  'amount': 'Amount',
  'enter_amount': 'Enter amount',
  'notes': 'Notes',
  'optional': 'Optional',
  'review_transfer': 'Review Transfer',
  'confirm_transfer': 'Confirm Transfer',
  'bill_payments': 'Bill Payments',
  'electricity': 'Electricity',
  'water': 'Water',
  'internet': 'Internet',
  'phone': 'Phone',
  'upcoming_bills': 'Upcoming Bills',
  'overdue_bills': 'Overdue Bills',
  'no_bills': 'No bills',
  'my_cards': 'My Cards',
  'no_cards': 'No cards found',
  'block': 'Block',
  'unblock': 'Unblock',
  'transactions': 'Transactions',
  'spending_analytics': 'Spending Analytics',
  'all': 'All',
  'income': 'Income',
  'expense': 'Expense',
  'no_active_loans': 'No Active Loans',
  'apply_for_loan': 'Apply for Loan',
  'apply_for_new_loan': 'Apply for a new loan',
  'active_loans': 'Active Loans',
  'monthly_payment': 'Monthly Payment',
  'due_date': 'Due Date',
};

const Map<String, String> _russianTranslations = {
  'welcome_back': 'Добро пожаловать,',
  'my_accounts': 'Мои счета',
  'see_all_transactions': 'Показать все транзакций',
  'home': 'Главная',
  'transfer': 'Переводы',
  'loans': 'Кредиты',
  'history': 'История',
  'cards': 'Карты',
  'scan': 'Сканирование',
  'bills': 'Счета',
  'total_balance': 'Общий баланс',
  'settings': 'Параметры',
  'language': 'Язык',
  'theme': 'Тема',
  'light': 'Светлая',
  'dark': 'Тёмная',
  'english': 'English',
  'russian': 'Русский',
  'kazakh': 'Қазақша',
  'transfer_money': 'Перевод денег',
  'between_accounts': 'Между счетами',
  'to_other_cards': 'На другие карты',
  'international': 'Международные',
  'from_account': 'От счета',
  'select_account': 'Выберите счет',
  'to_recipient': 'Получателю',
  'select_recipient': 'Выберите получателя',
  'amount': 'Сумма',
  'enter_amount': 'Введите сумму',
  'notes': 'Примечания',
  'optional': 'Опционально',
  'review_transfer': 'Проверить перевод',
  'confirm_transfer': 'Подтвердить перевод',
  'bill_payments': 'Оплата счетов',
  'electricity': 'Электричество',
  'water': 'Вода',
  'internet': 'Интернет',
  'phone': 'Телефон',
  'upcoming_bills': 'Предстоящие счета',
  'overdue_bills': 'Просроченные счета',
  'no_bills': 'Нет счетов',
  'my_cards': 'Мои карты',
  'no_cards': 'Карты не найдены',
  'block': 'Заблокировать',
  'unblock': 'Разблокировать',
  'transactions': 'Транзакции',
  'spending_analytics': 'Аналитика расходов',
  'all': 'Все',
  'income': 'Доход',
  'expense': 'Расход',
  'no_active_loans': 'Нет активных кредитов',
  'apply_for_loan': 'Подать заявку на кредит',
  'apply_for_new_loan': 'Подать заявку на новый кредит',
  'active_loans': 'Активные кредиты',
  'monthly_payment': 'Ежемесячный платеж',
  'due_date': 'Срок погашения',
};

const Map<String, String> _kazakhTranslations = {
  'welcome_back': 'Қайта қош келдіңіз,',
  'my_accounts': 'Менің есептік жазбаларым',
  'see_all_transactions': 'Барлық транзакциялар',
  'home': 'Басты бет',
  'transfer': 'Аударымдар',
  'loans': 'Кредиттер',
  'history': 'Тарих',
  'cards': 'Карталар',
  'scan': 'Сканерлеу',
  'bills': 'Шоттар',
  'total_balance': 'Барлық балансы',
  'settings': 'Параметрлер',
  'language': 'Тіл',
  'theme': 'Тема',
  'light': 'Жарық',
  'dark': 'Қараңғы',
  'english': 'English',
  'russian': 'Русский',
  'kazakh': 'Қазақша',
  'transfer_money': 'Ақы өту',
  'between_accounts': 'Есептік жазбалар арасында',
  'to_other_cards': 'Басқа карталарға',
  'international': 'Халықаралық',
  'from_account': 'Есептік жазбадан',
  'select_account': 'Есептік жазбаны таңдаңыз',
  'to_recipient': 'Алушыға',
  'select_recipient': 'Алушыны таңдаңыз',
  'amount': 'Сумма',
  'enter_amount': 'Сумманы енгізіңіз',
  'notes': 'Ескертпелер',
  'optional': 'Міндетті емес',
  'review_transfer': 'Ауыстырманы қарау',
  'confirm_transfer': 'Ауыстырманы растау',
  'bill_payments': 'Шоттарды төлеу',
  'electricity': 'Электр энергиясы',
  'water': 'Су',
  'internet': 'Интернет',
  'phone': 'Телефон',
  'upcoming_bills': 'Келе жатқан шоттар',
  'overdue_bills': 'Ешеген шоттар',
  'no_bills': 'Шоттар жоқ',
  'my_cards': 'Менің карталарым',
  'no_cards': 'Карталар табылмады',
  'block': 'Бөгеу',
  'unblock': 'Босату',
  'transactions': 'Транзакциялар',
  'spending_analytics': 'Шығындарды талдау',
  'all': 'Барлығы',
  'income': 'Киіс',
  'expense': 'Шығыны',
  'no_active_loans': 'Белсенді кредиттер жоқ',
  'apply_for_loan': 'Кредитке өтінім беріңіз',
  'apply_for_new_loan': 'Жаңа кредитке өтінім беріңіз',
  'active_loans': 'Белсенді кредиттер',
  'monthly_payment': 'Ай сайынғы төлем',
  'due_date': 'Төлеу мерзімі',
};
