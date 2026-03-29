# Estructura de Carpetas Flutter — GastosApp

Basada en la estructura real del equipo (zigo_app como referencia).
Feature-first + Clean Architecture + capa de plugins para abstracción de librerías.

```
lib/
├── main.dart                         # init: dotenv, supabase, riverpod
├── app.dart                          # MaterialApp.router + GoRouter + tema
│
├── config/                           # Configuración global de la app
│   ├── config.dart                   # barrel file
│   ├── interceptors/                 # Dio interceptors (JWT, connectivity, errors)
│   ├── l10n/                         # Internacionalización (español)
│   ├── router/                       # GoRouter setup + AppRoutes constants + auth guard
│   ├── theme/                        # AppTheme light/dark, AppColors, AppTextStyles
│   └── utilities/                    # Helpers globales reutilizables
│
├── shared/                           # Código compartido entre features
│   ├── shared.dart                   # barrel file
│   ├── async/                        # FutureBuilder helpers, AsyncValue widgets
│   ├── constants/                    # Constantes globales (urls, keys, etc.)
│   ├── data/                         # DTOs/models compartidos entre features
│   ├── dialog/                       # Diálogos y bottom sheets reutilizables
│   ├── domain/                       # Entidades y contratos compartidos
│   ├── enums/                        # Enums globales (CurrencyCode, DebtRuleCode, etc.)
│   ├── extensions/                   # Extension methods (String, DateTime, double)
│   ├── form/                         # Widgets de formulario reutilizables
│   ├── helper/                       # Helpers: CurrencyFormatter, DateFormatter
│   ├── hooks/                        # Custom hooks si se usa flutter_hooks
│   ├── infrastructure/               # Implementaciones base (base datasource, etc.)
│   ├── notification/                 # Manejo de notificaciones locales
│   ├── plugins/                      # *** Abstracción de librerías externas ***
│   │   ├── plugins.dart              # barrel file
│   │   ├── secure_storage/           # Wrapper de flutter_secure_storage
│   │   │   └── secure_storage_plugin.dart
│   │   ├── image_picker/             # Wrapper de image_picker
│   │   │   └── image_picker_plugin.dart
│   │   ├── mlkit/                    # Wrapper de google_mlkit_text_recognition
│   │   │   └── text_recognizer_plugin.dart
│   │   ├── connectivity/             # Wrapper de connectivity_plus
│   │   │   └── connectivity_plugin.dart
│   │   └── supabase/                 # Wrapper de supabase_flutter auth
│   │       └── supabase_auth_plugin.dart
│   └── presentation/                 # Widgets UI reutilizables globales
│       ├── buttons/                  # AppButton, AppOutlinedButton, AppIconButton
│       ├── cards/                    # AppCard, SurfaceCard
│       ├── chips/                    # AppChip, SelectableChip
│       ├── inputs/                   # AppTextField, CurrencyInput, AmountInput
│       ├── loaders/                  # AppLoader, SkeletonLoader
│       └── snackbars/                # AppSnackBar (success, error, info)
│
├── database/                         # Configuración de base de datos / Supabase
│   ├── supabase_client.dart          # supabaseClientProvider (Riverpod)
│   └── dio_client.dart               # dioClientProvider con base URL + interceptors
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/auth_remote_datasource.dart
    │   │   ├── models/app_user_model.dart
    │   │   └── repositories/auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/app_user.dart
    │   │   ├── repositories/auth_repository.dart
    │   │   └── usecases/
    │   │       ├── login_usecase.dart
    │   │       └── logout_usecase.dart
    │   └── presentation/
    │       ├── providers/auth_provider.dart
    │       ├── screens/login_screen.dart
    │       └── widgets/login_form.dart
    │
    ├── balance/
    │   ├── data/
    │   │   ├── datasources/balance_remote_datasource.dart
    │   │   ├── models/
    │   │   │   ├── balance_model.dart
    │   │   │   └── movement_model.dart
    │   │   └── repositories/balance_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── balance.dart         # { gtq, usd, netGtq, owedBy }
    │   │   │   └── movement.dart        # { id, name, amount, type, date, period }
    │   │   ├── repositories/balance_repository.dart
    │   │   └── usecases/get_balance_usecase.dart
    │   └── presentation/
    │       ├── providers/balance_provider.dart
    │       ├── screens/balance_screen.dart     # HOME
    │       └── widgets/
    │           ├── balance_hero_card.dart      # card verde con monto neto
    │           ├── currency_toggle.dart        # GTQ | USD | Ambos
    │           ├── movement_list_item.dart
    │           ├── period_divider.dart
    │           └── quick_actions_row.dart      # Escanear | Manual | Pago
    │
    ├── expenses/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── expense_remote_datasource.dart
    │   │   │   └── ocr_remote_datasource.dart
    │   │   ├── models/
    │   │   │   ├── expense_model.dart
    │   │   │   ├── expense_item_model.dart
    │   │   │   └── ocr_result_model.dart
    │   │   └── repositories/
    │   │       ├── expense_repository_impl.dart
    │   │       └── ocr_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── expense.dart
    │   │   │   ├── expense_item.dart
    │   │   │   └── ocr_result.dart
    │   │   ├── repositories/
    │   │   │   ├── expense_repository.dart
    │   │   │   └── ocr_repository.dart
    │   │   └── usecases/
    │   │       ├── create_expense_usecase.dart
    │   │       ├── get_expenses_usecase.dart
    │   │       ├── delete_expense_usecase.dart
    │   │       └── scan_receipt_usecase.dart   # usa mlkit plugin + ocr repo
    │   └── presentation/
    │       ├── providers/
    │       │   ├── expense_provider.dart
    │       │   └── ocr_provider.dart
    │       ├── screens/
    │       │   ├── add_expense_screen.dart     # tabs: OCR | Manual
    │       │   └── expense_detail_screen.dart
    │       └── widgets/
    │           ├── expense_item_row.dart
    │           ├── debt_rule_selector.dart     # full|%|fijo|none
    │           ├── payer_selector.dart         # José | Mamá | Ambos
    │           ├── ocr_scanner_widget.dart     # cámara + ML Kit
    │           ├── ocr_review_list.dart
    │           └── debt_summary_card.dart
    │
    ├── history/
    │   ├── data/
    │   │   ├── datasources/history_remote_datasource.dart
    │   │   ├── models/period_summary_model.dart
    │   │   └── repositories/history_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/period_summary.dart
    │   │   ├── repositories/history_repository.dart
    │   │   └── usecases/get_period_history_usecase.dart
    │   └── presentation/
    │       ├── providers/history_provider.dart
    │       ├── screens/history_screen.dart
    │       └── widgets/
    │           ├── month_chip_selector.dart
    │           └── history_stats_row.dart
    │
    └── payments/
        ├── data/
        │   ├── datasources/payment_remote_datasource.dart
        │   ├── models/debt_payment_model.dart
        │   └── repositories/payment_repository_impl.dart
        ├── domain/
        │   ├── entities/debt_payment.dart
        │   ├── repositories/payment_repository.dart
        │   └── usecases/register_payment_usecase.dart
        └── presentation/
            ├── providers/payment_provider.dart
            ├── screens/register_payment_screen.dart
            └── widgets/
                ├── payment_users_arrow.dart     # Mamá → José visual
                └── balance_preview_card.dart    # "Después del pago: Q 0.00"
```

---

## Patrón plugins/ — Abstracción de librerías externas

Cada librería externa tiene su propio plugin wrapper en `shared/plugins/`.
Esto centraliza el uso y facilita reemplazar librerías sin tocar los features.

### Ejemplo: SecureStoragePlugin
```dart
// shared/plugins/secure_storage/secure_storage_plugin.dart
abstract class SecureStoragePlugin {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class FlutterSecureStoragePlugin implements SecureStoragePlugin {
  final FlutterSecureStorage _storage;
  const FlutterSecureStoragePlugin(this._storage);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  // ...
}

@riverpod
SecureStoragePlugin secureStorage(SecureStorageRef ref) =>
    FlutterSecureStoragePlugin(const FlutterSecureStorage());
```

### Ejemplo: TextRecognizerPlugin
```dart
// shared/plugins/mlkit/text_recognizer_plugin.dart
abstract class TextRecognizerPlugin {
  Future<String> recognize(XFile image);
  void dispose();
}

class MLKitTextRecognizerPlugin implements TextRecognizerPlugin {
  final TextRecognizer _recognizer = TextRecognizer();

  @override
  Future<String> recognize(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final recognized = await _recognizer.processImage(inputImage);
    return recognized.blocks.map((b) => b.text).join('\n');
  }

  @override
  void dispose() => _recognizer.close();
}
```

---

## Enums compartidos (shared/enums/)

```dart
// currency_code.dart
enum CurrencyCode {
  gtq('GTQ', 'Q'),
  usd('USD', '\$');

  const CurrencyCode(this.code, this.symbol);
  final String code;
  final String symbol;
}

// debt_rule_code.dart
enum DebtRuleCode {
  full,
  percentage,
  fixedAmount,
  none;
}
```
