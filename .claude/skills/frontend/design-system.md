---
name: design-system
description: Skill de referencia del design system de GastosApp. Úsalo cuando necesites crear o modificar cualquier componente UI: inputs, botones, cards, spacing, colores, tipografía. Garantiza homogeneidad visual en toda la app.
---

# Skill: Design System — GastosApp

Referencia completa de todos los componentes, tokens y reglas visuales.

---

## Tokens de color — `AppColors`
`lib/config/theme/app_colors.dart`

| Token | Light | Dark | Uso |
|---|---|---|---|
| `primary` | #22C55E | — | Acciones principales, focus, bordes activos |
| `primaryDark` | #16A34A | — | Hover, variante dark del primary |
| `primaryLight` | #DCFCE7 | — | Fondos de chips activos, fondos de iconos |
| `danger` | #EF4444 | — | Errores, destructivo |
| `dangerLight` | #FEE2E2 | — | Fondo toast error |
| `warning` | #F59E0B | — | Advertencias |
| `warningLight` | #FEF3C7 | — | Fondo toast warning |
| `bgLight/bgDark` | #F8FAFC / #0B1120 | — | Scaffold background |
| `surfaceLight/surfaceDark` | #FFFFFF / #1A2235 | — | Cards, inputs, AppBar |
| `text1Light/text1Dark` | #0F172A / #F1F5F9 | — | Títulos, texto principal |
| `text2Light/text2Dark` | #475569 / #94A3B8 | — | Subtítulos, labels, hints |
| `text3Light/text3Dark` | #94A3B8 / #64748B | — | Placeholders, metadata |
| `borderLight/borderDark` | #E2E8F0 / #2D3F5A | — | Bordes de inputs y cards |

---

## Tipografía — `AppTextStyles`
`lib/config/theme/app_text_styles.dart`

| Token | Font | Size | Weight | Uso |
|---|---|---|---|---|
| `displayLarge` | DM Sans | 32 | 700 | Montos grandes, hero |
| `displayMedium` | DM Sans | 24 | 700 | Títulos de pantalla |
| `titleLarge` | DM Sans | 20 | 600 | Sección, AppBar |
| `titleMedium` | DM Sans | 16 | 600 | Card title, form label activo |
| `bodyLarge` | DM Sans | 16 | 400 | Texto principal |
| `bodyMedium` | DM Sans | 14 | 400 | Texto secundario, botones |
| `bodySmall` | DM Sans | 12 | 400 | Metadata, chips |
| `labelMedium` | DM Sans | 12 | 500 | Labels de formulario |
| `amountLarge` | DM Mono | 32 | 600 | Balance hero |
| `amountMedium` | DM Mono | 20 | 500 | Montos en lista |
| `amountSmall` | DM Mono | 14 | 400 | Montos secundarios, prefix de input |

Siempre usar `context.textTheme.X` o `AppTextStyles.X`. Nunca `fontSize` inline.

---

## Espaciado — `AppSpacing`
`lib/config/utilities/app_spacing.dart`

| Constante | Valor | Uso |
|---|---|---|
| `xs` | 4 | Gaps internos mínimos |
| `sm` | 8 | Entre elementos relacionados |
| `md` | 16 | Padding interno de cards/inputs |
| `lg` | 24 | Separación entre secciones |
| `xl` | 32 | Separación mayor |
| `xxl` | 48 | Separación entre bloques grandes |
| `screenHorizontal` | 24 | Padding lateral de pantallas |
| `cardPadding` | 16 | Padding interno de cards |
| `inputSpacing` | 16 | Espaciado entre inputs en un form |
| `buttonVertical` | 16 | Padding vertical de botones |
| `sectionSpacing` | 32 | Entre secciones de pantalla |

Para contenedores (iconos, avatares): `context.screenWidth * factor`.

---

## Inputs — `shared/presentation/inputs/`

Todo el estilo visual está centralizado en `AppTheme.inputDecorationTheme`. Los widgets solo definen estructura.

### `AppTextField`
Input de texto genérico.

```dart
AppTextField(
  controller: controller,
  label: 'Nombre',
  prefixIcon: const Icon(Icons.person_outlined),
  keyboardType: TextInputType.text,
  textInputAction: TextInputAction.next,
  validator: (v) => v!.isEmpty ? 'Requerido' : null,
)
```

| Parámetro | Tipo | Requerido |
|---|---|---|
| `controller` | `TextEditingController` | ✓ |
| `label` | `String` | ✓ |
| `hint` | `String?` | |
| `prefixIcon` | `Widget?` | |
| `suffixIcon` | `Widget?` | |
| `validator` | `String? Function(String?)?` | |
| `keyboardType` | `TextInputType?` | |
| `textInputAction` | `TextInputAction?` | |
| `onFieldSubmitted` | `ValueChanged<String>?` | |
| `obscureText` | `bool` (default `false`) | |
| `enabled` | `bool` (default `true`) | |
| `maxLines` | `int` (default `1`) | |
| `inputFormatters` | `List<TextInputFormatter>?` | |

---

### `AppPasswordField`
Campo de contraseña con toggle de visibilidad.
**El estado `isObscure` es controlado por el padre vía Riverpod** (patrón controlled component).

```dart
// En el archivo del widget padre — provider local auto-dispose
@riverpod
class PasswordObscure extends _$PasswordObscure {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

// En el build del padre
AppPasswordField(
  controller: passwordController,
  label: 'Contraseña',
  isObscure: ref.watch(passwordObscureProvider),
  onToggleObscure: () => ref.read(passwordObscureProvider.notifier).toggle(),
  validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
)
```

---

### `AppCurrencyField`
Input numérico para montos con símbolo de moneda.

```dart
AppCurrencyField(
  controller: amountController,
  label: 'Monto',
  currency: CurrencyCode.gtq, // o CurrencyCode.usd
  validator: (v) => v!.isEmpty ? 'Ingresa el monto' : null,
)
```

Permite solo números con hasta 2 decimales. Muestra el símbolo de la moneda (`Q` o `$`) como prefijo.

---

## Border Radius estándar

| Contexto | Radio |
|---|---|
| Inputs y botones | `10` |
| Cards y contenedores | `16` |
| Hero cards | `24` |
| Iconos/avatares | `iconSize * 0.28` (proporcional) |
| Toasts | `12` |

---

## Toasts — `AppSnackBar`

Siempre vía extensión de contexto. Ver skill `app-snackbar` para detalles.

```dart
context.snackBarSuccess('Gasto guardado');
context.snackBarError(failure.message);
context.snackBarWarning('Sin conexión');
```

---

## Reglas de diseño (resumen)

- **Sin `setState()`** — todo estado en Riverpod
- **Sin valores numéricos inline** — usar `AppSpacing.X` y `AppTextStyles.X`
- **Sin `fontSize` hardcodeado** — respetar el text scaling del sistema
- **Sin dimensiones fijas** para contenedores — usar `context.screenWidth * factor`
- **Sin `AlertDialog`** para feedback — solo `AppSnackBar`
- **`SafeArea`** en todas las pantallas
