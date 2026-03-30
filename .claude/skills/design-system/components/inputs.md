# Componentes: Inputs — GastosApp

API de referencia para todos los inputs del design system.
Ubicación: `lib/shared/presentation/inputs/`

Todo el estilo visual está centralizado en `AppTheme.inputDecorationTheme`. Los widgets solo definen estructura.

---

## `AppTextField`

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

## `AppPasswordField`

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

## `AppCurrencyField`

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
