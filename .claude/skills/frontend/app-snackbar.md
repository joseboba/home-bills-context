---
name: app-snackbar
description: Skill para implementar el widget AppSnackBar en GastosApp. Úsalo cuando necesites crear o modificar toasts de success, error o warning, o cuando una pantalla/widget necesite mostrar feedback al usuario.
---

# Skill: AppSnackBar — Toasts elegantes

Widget centralizado para todo el feedback visual al usuario en GastosApp.
Ubicación: `lib/shared/presentation/snackbars/app_snackbar.dart`

---

## Implementación del widget

```dart
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

enum SnackBarVariant { success, error, warning }

class AppSnackBar {
  AppSnackBar._();

  static SnackBar success(String message) =>
      _build(message, SnackBarVariant.success);

  static SnackBar error(String message) =>
      _build(message, SnackBarVariant.error);

  static SnackBar warning(String message) =>
      _build(message, SnackBarVariant.warning);

  static SnackBar _build(String message, SnackBarVariant variant) {
    final config = _variantConfig(variant);
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: config.duration,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.zero,
      content: _AppSnackBarContent(message: message, config: config),
    );
  }

  static _SnackBarConfig _variantConfig(SnackBarVariant variant) {
    switch (variant) {
      case SnackBarVariant.success:
        return _SnackBarConfig(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.primary,
          bgColor: AppColors.primaryLight,
          borderColor: AppColors.primary.withOpacity(0.4),
          duration: const Duration(seconds: 2),
        );
      case SnackBarVariant.error:
        return _SnackBarConfig(
          icon: Icons.cancel_rounded,
          iconColor: AppColors.danger,
          bgColor: AppColors.dangerLight,
          borderColor: AppColors.danger.withOpacity(0.4),
          duration: const Duration(seconds: 4),
        );
      case SnackBarVariant.warning:
        return _SnackBarConfig(
          icon: Icons.warning_rounded,
          iconColor: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFEF3C7),
          borderColor: const Color(0xFFF59E0B).withOpacity(0.4),
          duration: const Duration(seconds: 3),
        );
    }
  }
}

class _SnackBarConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final Duration duration;

  const _SnackBarConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.duration,
  });
}

class _AppSnackBarContent extends StatelessWidget {
  final String message;
  final _SnackBarConfig config;

  const _AppSnackBarContent({
    required this.message,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(config.icon, color: config.iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: config.iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Extensión de contexto — `build_context_ext.dart`

Ubicación: `lib/shared/extensions/build_context_ext.dart`

```dart
// Flutter imports
import 'package:flutter/material.dart';

// Internal dependencies
import '../presentation/snackbars/snackbars.dart';

extension AppContext on BuildContext {
  void snackBarSuccess(String msg) =>
      ScaffoldMessenger.of(this).showSnackBar(AppSnackBar.success(msg));
  void snackBarError(String msg) =>
      ScaffoldMessenger.of(this).showSnackBar(AppSnackBar.error(msg));
  void snackBarWarning(String msg) =>
      ScaffoldMessenger.of(this).showSnackBar(AppSnackBar.warning(msg));

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
}
```

---

## Uso desde cualquier pantalla o widget

```dart
// Siempre via extensión de contexto — nunca ScaffoldMessenger directo
context.snackBarSuccess('Gasto guardado correctamente');
context.snackBarError('No se pudo guardar. Intenta de nuevo.');
context.snackBarWarning('Sin conexión. Los cambios se guardarán al reconectar.');
```

---

## Uso desde un Riverpod Notifier (con ref)

```dart
// Opción recomendada: disparar desde la pantalla al observar el estado del notifier.
ref.listen(expenseNotifierProvider, (prev, next) {
  next.whenOrNull(
    error: (e, _) => context.snackBarError(_mapError(e)),
    data: (_) => context.snackBarSuccess('Gasto guardado'),
  );
});
```

---

## Mensajes recomendados por contexto

| Acción | Variante | Mensaje |
|---|---|---|
| Gasto creado | success | "Gasto guardado correctamente" |
| Pago registrado | success | "Pago registrado" |
| Error de red | error | "Sin conexión. Intenta de nuevo." |
| Error de servidor | error | "Algo salió mal. Intenta más tarde." |
| Sesión expirada | warning | "Tu sesión expiró. Inicia sesión de nuevo." |
| Campos incompletos | warning | "Completa todos los campos requeridos." |
| OCR sin resultado | warning | "No se detectó texto en la imagen." |

---

## Notas
- Nunca usar `AlertDialog`, `print` ni `debugPrint` para feedback al usuario.
- El texto siempre en español, conciso, orientado al usuario (no mensajes técnicos).
- `_AppSnackBarContent` usa `Expanded` para que el texto sea responsive con cualquier tamaño de fuente del sistema.
