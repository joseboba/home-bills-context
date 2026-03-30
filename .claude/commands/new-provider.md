---
description: Crea un Riverpod provider (AsyncNotifier, Notifier o funcional) en la carpeta providers de una feature.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# /new-provider

Crea un Riverpod provider en la carpeta correcta del feature.

## Uso
```
/new-provider <feature> <provider-name> [tipo]
```

## Tipos disponibles
- `async` (default) — AsyncNotifier para operaciones con API/Supabase
- `sync` — Notifier para estado síncrono simple
- `functional` — provider funcional (repositorios, servicios)

## Ejemplos
```
/new-provider expenses expense-list
/new-provider auth password-obscure sync
/new-provider expenses expense-repository functional
```

## Antes de generar código

Argumentos recibidos: `$ARGUMENTS`

Extraer del texto anterior los valores ya proporcionados. Para todo lo que falte o no esté claro, preguntar al usuario antes de continuar. No generar ningún archivo hasta tener respuesta a todas las preguntas pendientes.

Preguntas:
1. ¿Feature y nombre del provider? — requeridos si no están en `$ARGUMENTS`
2. ¿Qué tipo? — si no está en `$ARGUMENTS` o el valor no es `async`/`sync`/`functional`, preguntar explicando las opciones:
   - `async`: para llamadas a API o Supabase, expone `AsyncValue<T>`
   - `sync`: para estado local simple (toggle, selección, contador), expone `T` directo
   - `functional`: para repositorios o servicios que se inyectan como dependencias
3. ¿Qué retorna? (ej: `List<Expense>`, `HomeBalance`, `bool`, `void`) — define el generic `T` del notifier
4. ¿Tiene parámetros de entrada en `build()`? (ej: `String periodCode`, `String expenseId`) — define si el notifier es una "family"; responder "ninguno" si no aplica
5. ¿Qué usecase o repositorio llama? (ej: `GetExpensesUseCase`, `expenseRepositoryProvider`)

## Instrucciones

1. Leer `.claude/agents/frontend-flutter.md` para convenciones de imports y arquitectura
2. Leer `.claude/skills/riverpod-provider/SKILL.md` para patrones completos con ejemplos
3. Crear `lib/features/<feature>/presentation/providers/<name>_provider.dart`
4. Crear `lib/features/<feature>/presentation/providers/<name>_provider.g.dart` con el código generado
5. Agregar el export al barrel `presentation/providers/providers.dart`
6. El provider **nunca** muestra snackbars — propaga errores como `AsyncError` o `throw failure`
7. Recordar al usuario que ejecute: `dart run build_runner build --delete-conflicting-outputs`
