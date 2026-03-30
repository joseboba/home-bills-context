---
name: error-handling
description: Flujo completo de manejo de errores en GastosApp. Úsalo cuando implementes datasources, repositorios, providers o cualquier capa que maneje errores HTTP, de red o de negocio.
---

# Skill: Error Handling — GastosApp

---

## Flujo completo (de abajo hacia arriba)

```
HttpPlugin.get/post/...
  → lanza HttpException (con statusCode y message)
      ↓
Repository (catch HttpException)
  → retorna/lanza Failure (subtipo según statusCode)
      ↓
Notifier (AsyncValue.guard o resultado de usecase)
  → estado AsyncError<Failure>
      ↓
ProviderErrorObserver  (config/interceptors/error_observer.dart)
  → muestra AppSnackBar.error automáticamente para todo AsyncError
```

`ProviderErrorObserver` está registrado en `ProviderScope` en `main.dart`. **No hay que manejar errores en la UI** salvo que se quiera un comportamiento diferente al snackbar por defecto.

---

## Tipos de Failure (`shared/domain/failures/failure.dart`)

```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class AuthFailure extends Failure {
  const AuthFailure([String message = 'Error de autenticación']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Sin conexión. Intenta de nuevo.']) : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Algo salió mal. Intenta más tarde.']) : super(message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String message = 'Error inesperado.']) : super(message);
}
```

---

## Mapeo HttpException → Failure en repositorios

```dart
// En repository_impl.dart
Future<Either<Failure, T>> someMethod() async {
  try {
    final result = await _datasource.fetch();
    return Right(result.toDomain());
  } on HttpException catch (e) {
    return Left(_mapError(e));
  }
}

Failure _mapError(HttpException e) {
  if (e.statusCode == 401 || e.statusCode == 403) return const AuthFailure();
  if (e.statusCode == null) return const NetworkFailure();   // sin internet
  if (e.statusCode! >= 500) return const ServerFailure();
  return ServerFailure(e.message);
}
```

---

## Providers — propagar sin atrapar

Los providers **no muestran snackbars** ni capturan errores. Solo propagan:

```dart
// AsyncNotifier con usecase que retorna Either
Future<void> createExpense(CreateExpenseParams params) async {
  state = const AsyncLoading();
  final result = await CreateExpenseUseCase(ref.read(expenseRepositoryProvider))
      .execute(params);
  state = result.fold(
    (failure) => AsyncError(failure, StackTrace.current),
    (expense) => AsyncData(expense),
  );
}

// AsyncNotifier con build() que puede fallar — usar AsyncValue.guard
@override
Future<List<Expense>> build() async {
  return AsyncValue.guard(() async {
    final result = await ref.read(getExpensesUseCaseProvider).execute(periodCode);
    return result.fold((f) => throw f, (data) => data);
  });
}
```

---

## Cuándo manejar errores en la UI

Solo si se necesita un comportamiento distinto al snackbar global (ej: navegación, limpiar form):

```dart
// En el screen — solo para side effects, no para mostrar errores
ref.listen(createExpenseProvider, (_, next) {
  next.whenOrNull(
    data: (_) => context.go(AppRoutes.home),   // ← navegación al éxito
    // Los errores NO se manejan aquí — ProviderErrorObserver los captura
  );
});
```

---

## Auth — datasource diferente

El datasource de auth usa Supabase directamente (no HttpPlugin). Sus errores se capturan como `AuthException` de Supabase y se mapean a `AuthFailure` en el repositorio:

```dart
// auth_repository_impl.dart
try {
  await _supabase.auth.signInWithPassword(email: email, password: password);
} on AuthException catch (e) {
  throw const AuthFailure('Credenciales incorrectas. Verifica tu email y contraseña.');
}
```

---

## Mensajes de error recomendados

| Tipo | Mensaje al usuario |
|---|---|
| `AuthFailure` login | "Credenciales incorrectas. Verifica tu email y contraseña." |
| `AuthFailure` sesión | "Tu sesión expiró. Inicia sesión de nuevo." |
| `NetworkFailure` | "Sin conexión. Intenta de nuevo." |
| `ServerFailure` | "Algo salió mal. Intenta más tarde." |
| `UnexpectedFailure` | "Error inesperado. Intenta de nuevo." |

Mensajes siempre en español, orientados al usuario, sin términos técnicos.
