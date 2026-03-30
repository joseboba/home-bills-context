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

## Instrucciones
1. Leer `.claude/agents/frontend-flutter.md` y `.claude/skills/frontend/riverpod-provider.md`
2. Crear `lib/features/<feature>/presentation/providers/<name>_provider.dart`
3. Crear `lib/features/<feature>/presentation/providers/<name>_provider.g.dart` con el código generado correspondiente
4. Agregar el export al barrel `providers/providers.dart`
5. El provider **nunca** muestra snackbars — propaga errores como `AsyncError`
6. Recordar al usuario que corra `dart run build_runner build --delete-conflicting-outputs`
