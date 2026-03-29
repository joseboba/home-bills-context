# GastosApp — Contexto del Proyecto

Aplicación móvil para dos usuarios (José Enrique y su mamá) para registrar y dividir
gastos del hogar. El flujo principal es: tomar foto de factura → ítems detectados
automáticamente → asignar división → actualizar balance.

---

## Stack Técnico

| Capa | Tecnología |
|---|---|
| Mobile | Flutter (Android MVP, iOS después) |
| State Management | Riverpod |
| Navegación | Go Router |
| HTTP Client | Dio |
| Modelos | Freezed + json_serializable |
| Auth | Supabase Auth + JWT en flutter_secure_storage |
| OCR on-device | google_mlkit_text_recognition |
| OCR estructurado | Gemini API (tier gratuito) |
| Backend | NestJS + TypeScript |
| Base de datos | Supabase (PostgreSQL) |
| Hosting backend | Railway o Render (tier gratuito) |

## Librerías Flutter

```yaml
dependencies:
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  go_router: ^14.x
  dio: ^5.x
  freezed_annotation: ^2.x
  json_annotation: ^4.x
  supabase_flutter: ^2.x
  flutter_secure_storage: ^9.x
  google_mlkit_text_recognition: ^0.x
  image_picker: ^1.x
  intl: ^0.x
  flutter_dotenv: ^5.x
  connectivity_plus: ^6.x

dev_dependencies:
  build_runner: ^2.x
  freezed: ^2.x
  json_serializable: ^6.x
  riverpod_generator: ^2.x
```

---

## Arquitectura Flutter — Feature-first + Clean Architecture

```
lib/
├── main.dart
├── app.dart
├── config/                           # interceptors, l10n, router, theme, utilities
├── shared/                           # código compartido: plugins, enums, presentation, domain
├── database/                         # Supabase client + Dio client
│   ├── config/         # env vars, supabase config
│   ├── network/        # Dio client + interceptors
│   ├── error/          # excepciones y failures
│   ├── router/         # GoRouter routes
│   ├── theme/          # light + dark theme, colores, tipografía
│   └── utils/          # currency_formatter, date_formatter
│
└── features/
    ├── auth/           # login, JWT, Supabase Auth
    ├── balance/        # pantalla home, balance neto, movimientos
    ├── expenses/       # agregar gasto OCR/manual, detalle, ítems
    ├── history/        # historial por mes/semana, stats
    └── payments/       # registrar pago, resumen de deuda
```

Cada feature sigue Clean Architecture estricta:
```
feature/
├── data/
│   ├── datasources/    # llamadas HTTP (Dio) o Supabase
│   ├── models/         # Freezed + json_serializable (DTOs)
│   └── repositories/   # implementaciones
├── domain/
│   ├── entities/       # modelos puros de negocio (Freezed)
│   ├── repositories/   # interfaces/contratos
│   └── usecases/       # un archivo por caso de uso
└── presentation/
    ├── providers/      # Riverpod providers/notifiers
    ├── screens/        # pantallas completas
    └── widgets/        # widgets reutilizables del feature
```

Ver `docs/architecture/flutter-file-structure.md` para el árbol completo.

---

## Arquitectura General del Sistema

```
Flutter App
  ├── ML Kit (on-device) → extrae texto crudo de la foto
  └── HTTP/JWT → NestJS API
                  ├── /auth        → login con JWT (Supabase Auth)
                  ├── /balance     → calcular quién debe qué
                  ├── /expenses    → CRUD gastos + ítems + splits
                  ├── /payments    → registrar pagos entre usuarios
                  └── /ocr         → texto crudo → Gemini → JSON
                        ├── Supabase Auth
                        ├── Gemini API (tier gratuito)
                        └── Supabase PostgreSQL
```

---

## Flujo OCR

1. Usuario toma foto en Flutter
2. ML Kit extrae texto crudo on-device
3. Flutter manda el texto al endpoint `/ocr` del backend
4. NestJS manda ese texto a Gemini API con prompt estructurado
5. Gemini devuelve JSON: `{ items[], total, date, merchant }`
6. Flutter muestra ítems para revisión/corrección
7. Usuario asigna splits y guarda

> Las imágenes NO se guardan en DB. Solo el JSON resultante.

---

## Base de Datos — Schemas

```
catalogs  → currencies, debt_rules
app       → app_config, app_users
expenses  → expenses, expense_items,
            expense_periods, expense_period_balances
payments  → debt_payments
            v_balance_by_period (vista)
```

Ver `docs/er/schema.sql` para el SQL completo.
Ver `docs/er/README.md` para explicación del modelo.

---

## Reglas de Negocio Clave

### Tipos de regla de deuda por ítem
| Código | Nombre | Cálculo |
|---|---|---|
| `full` | Deuda completa | debt = item.amount |
| `percentage` | Porcentaje | debt = item.amount × (value / 100) |
| `fixed_amount` | Monto fijo | debt = value |
| `none` | Sin deuda | debt = 0 |

### Cálculo del balance neto
```
balance =
  + Σ deudas de ítems donde debt_owner = usuario_B
  - Σ deudas de ítems donde debt_owner = usuario_A
  - Σ payments de B hacia A
  + Σ payments de A hacia B
  + opening_balance del período activo (arrastre)
```

### Períodos
- Cierran automáticamente al cambio de mes
- Saldos pendientes se arrastran al período siguiente como opening_balance
- Períodos cerrados son solo lectura

### Monedas
- GTQ y USD por gasto
- Balance se muestra por separado o convertido con tipo de cambio global
- Tipo de cambio: 1 valor en app.app_config.usd_to_gtq_rate, editable en DB

---

## Pantallas

1. Login — email + contraseña, JWT en secure storage
2. Balance (home) — balance neto GTQ/USD, movimientos por mes/semana
3. Agregar Gasto — OCR (foto → ML Kit → Gemini) o manual
4. Detalle de Gasto — ítems con regla de deuda, resumen de deuda generada
5. Historial — agrupado por semana, stats del mes seleccionado
6. Registrar Pago — monto, moneda, nota, preview del balance resultante

---

## Agentes disponibles en .claude/agents/

- frontend-flutter.md  → desarrollo de pantallas y widgets Flutter
- (próximos: backend-nestjs, architecture, business-rules)

## Fases de Construcción

- Fase 1 — Backend base: NestJS + Supabase, auth JWT, gastos manuales, balance
- Fase 2 — Flutter MVP: pantallas, entrada manual, sin OCR
- Fase 3 — OCR: ML Kit + Gemini
- Fase 4 — Nice to have: compartir resumen por WhatsApp

---

## Convenciones de Código

### Archivos de barril (barrel files)
- Cada carpeta expone un barrel file `<nombre_carpeta>.dart` que re-exporta todo lo público de esa carpeta.
- Ejemplo: `shared/presentation/snackbars/snackbars.dart` re-exporta `app_snackbar.dart` y `build_context_snackbar_ext.dart`.
- Los features también tienen barrel: `features/expenses/expenses.dart` re-exporta la capa de presentación, etc.
- Importar siempre desde el barrel, nunca desde archivos individuales internos de otra carpeta.

### Orden de imports en cada archivo
```dart
// Dart imports
import 'dart:async';
import 'dart:io';

// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// External dependencies
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Internal dependencies
import 'package:home_bills/shared/shared.dart';
import 'package:home_bills/features/expenses/expenses.dart';
```
- **Todos los imports internos usan el formato `package:home_bills/...`** — nunca rutas relativas (`../../../`).
- La única excepción son los archivos `part`/`part of` que Dart exige como rutas relativas.
- Respetar el orden y una línea en blanco entre cada sección.

### Dart format y linter — exclusión de archivos generados
En `analysis_options.yaml`, excluir siempre los archivos autogenerados:
```yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "lib/generated/**"
```
Para `dart format`, correr con:
```
dart format --exclude="**.g.dart,**.freezed.dart" lib/
```

### Extensiones de contexto
Las operaciones frecuentes sobre `BuildContext` se exponen como extensiones en `shared/extensions/build_context_ext.dart`:
```dart
extension AppContext on BuildContext {
  // Toasts
  void snackBarSuccess(String msg) =>
      ScaffoldMessenger.of(this).showSnackBar(AppSnackBar.success(msg));
  void snackBarError(String msg) =>
      ScaffoldMessenger.of(this).showSnackBar(AppSnackBar.error(msg));
  void snackBarWarning(String msg) =>
      ScaffoldMessenger.of(this).showSnackBar(AppSnackBar.warning(msg));
  // Theme helpers
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
}
```
Uso: `context.snackBarSuccess('Gasto guardado')`, `context.screenWidth`, `context.theme`.

---

## Reglas de UI/UX — Aplicación Global

### Orientación
- La app es **solo vertical (portrait)**. Bloquear en `main.dart` antes de `runApp`:
  ```dart
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  ```
- No existen layouts horizontales en ninguna pantalla ni widget.

### Responsive
- **Nunca usar valores de ancho/alto fijos** (`width: 390`, `height: 844`, etc.).
- Usar `MediaQuery.sizeOf(context)` o `LayoutBuilder` para adaptar el layout.
- Padding y espaciado usando las constantes de `AppSpacing` o cálculos relativos al ancho disponible — nunca píxeles hardcodeados inline.
- Los widgets deben funcionar correctamente en pantallas de 360 px hasta 430 px de ancho.
- `SafeArea` en todas las pantallas para respetar notch, statusbar y home indicator.

### Escalado de texto (accesibilidad)
- **Nunca sobrescribir** `textScaler`, `textScaleFactor`, ni `MediaQuery` para limitar la fuente del sistema.
- Todos los textos usan estilos de `AppTextStyles` (o `Theme.of(context).textTheme`); nunca `fontSize` hardcodeado fuera del tema.
- Los layouts deben acomodar texto grande sin overflow: usar `Flexible`, `Expanded`, `FittedBox` o `maxLines + overflow: TextOverflow.ellipsis` donde corresponda.
- Evitar contenedores de alto fijo que contengan texto variable.

### Toasts — AppSnackBar
- **Todo** feedback al usuario (errores, warnings, confirmaciones) usa `AppSnackBar` (`shared/presentation/snackbars/`). Nunca `AlertDialog`, `print` ni `debugPrint` para comunicar resultados.
- Tres variantes: `success` | `error` | `warning`.
- Estilo:
  - Fondo suave del color de la variante (opacity 0.12) + borde sutil (opacity 0.4)
  - Icono a la izquierda: ✓ verde · ✕ rojo · ⚠ ámbar
  - `borderRadius: 12`, `margin` lateral para no pegarse a los bordes
  - Duración: success → 2 s, error → 4 s, warning → 3 s
  - Posición: parte inferior (`SnackBarBehavior.floating`)
- Mensajes en español, orientados al usuario, concisos (ej: "Gasto guardado", "No se pudo conectar, intenta de nuevo").
- Disparar con: `ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.success(message))`.
- Ver skill `/app-snackbar` para implementación completa del widget.

---

## Patrón plugins/ (shared/plugins/)

Cada librería externa se abstrae en un plugin wrapper:
- `secure_storage/` → flutter_secure_storage
- `image_picker/` → image_picker
- `mlkit/` → google_mlkit_text_recognition
- `connectivity/` → connectivity_plus
- `supabase/` → supabase_flutter auth

Esto centraliza el uso y permite reemplazar librerías sin tocar los features.
Ver `docs/architecture/flutter-file-structure.md` para ejemplos de implementación.
