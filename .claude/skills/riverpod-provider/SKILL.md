---
name: riverpod-provider
description: Skill para crear y organizar Riverpod providers en GastosApp. Úsalo cuando necesites crear un nuevo provider, notifier, o mover estado de un widget a su carpeta de providers.
---

# Skill: Riverpod Providers — GastosApp

## Regla fundamental

**Todo provider vive en `presentation/providers/`, nunca dentro de un screen o widget.**
Esto aplica incluso para estado local de un solo widget (toggle de contraseña, selección de tab, etc.).

```
feature/presentation/
  providers/
    auth_provider.dart           ← AsyncNotifier principal del feature
    password_obscure_provider.dart  ← estado local de un widget, pero en providers/
    providers.dart               ← barrel
  screens/
  widgets/
```

---

## Tipos de provider y cuándo usarlos

### AsyncNotifier — operaciones async (API, Supabase)
```dart
// External dependencies
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Internal dependencies
import 'package:home_bills/features/auth/domain/domain.dart';
import 'package:home_bills/shared/shared.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AppUser?> build() async {
    return await ref.read(authRepositoryProvider).getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await LoginUseCase(ref.read(authRepositoryProvider))
        .execute(LoginParams(email: email, password: password));
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (user) => AsyncData(user),
    );
  }
}
```

### Notifier — estado síncrono simple
```dart
// External dependencies
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'password_obscure_provider.g.dart';

@riverpod
class PasswordObscure extends _$PasswordObscure {
  @override
  bool build() => true;
  void toggle() => state = !state;
}
```

### Provider funcional — datos derivados o repositorios
```dart
@riverpod
ExpenseRepository expenseRepository(Ref ref) {
  return ExpenseRepositoryImpl(ref.read(expenseDataSourceProvider));
}
```

---

## Estructura del archivo

```dart
// Dart imports         ← solo si hay imports de dart:
import 'dart:async';

// Flutter imports      ← solo si hay imports de Flutter
import 'package:flutter/material.dart';

// External dependencies
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Internal dependencies
import 'package:home_bills/features/expenses/domain/domain.dart';
import 'package:home_bills/shared/shared.dart';

part 'my_provider.g.dart';   ← siempre al final de los imports, antes del código

@riverpod
class MyNotifier extends _$MyNotifier {
  ...
}
```

---

## Barrel — providers.dart

Cada provider nuevo debe exportarse en el barrel:
```dart
export 'auth_provider.dart';
export 'password_obscure_provider.dart';
export 'my_new_provider.dart';   ← agregar aquí
```

---

## Manejo de errores en providers

Los providers **no muestran snackbars directamente**. Propagan el error como `AsyncError` y el interceptor global lo captura:

```dart
// Correcto — propagar el Failure como AsyncError
state = result.fold(
  (failure) => AsyncError(failure, StackTrace.current),
  (data) => AsyncData(data),
);

// Incorrecto — no lanzar SnackBars desde providers
// ScaffoldMessenger.of(context)... ← NO
// context.snackBarError(...)      ← NO (no hay context aquí)
```

El `ProviderErrorObserver` en `main.dart` intercepta todo `AsyncError` globalmente y muestra el toast correspondiente.

---

## Uso desde widgets

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Leer estado
    final isLoading = ref.watch(myNotifierProvider).isLoading;
    final data = ref.watch(myNotifierProvider).valueOrNull;

    // Escuchar solo transiciones (navegación, side effects NO relacionados a errores)
    ref.listen(myNotifierProvider, (_, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null) context.go(AppRoutes.home);
        },
      );
    });
    // Los errores NO se manejan aquí — los captura ProviderErrorObserver globalmente
  }
}
```

---

## Generación de código

Después de crear o modificar un provider con `@riverpod`, correr:
```bash
dart run build_runner build --delete-conflicting-outputs
```

O en modo watch durante desarrollo:
```bash
dart run build_runner watch --delete-conflicting-outputs
```
