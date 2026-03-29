# /new-screen

Crea una nueva pantalla Flutter siguiendo la arquitectura del proyecto.

## Uso
```
/new-screen <feature> <screen-name>
```

## Ejemplo
```
/new-screen expenses add-expense
```

## Lo que genera
- `lib/features/<feature>/presentation/screens/<screen_name>_screen.dart`
- `lib/features/<feature>/presentation/providers/<feature>_provider.dart` (si no existe)
- Registra la ruta en `lib/core/router/app_routes.dart`

## Instrucciones
1. Leer `CLAUDE.md` para contexto del proyecto
2. Leer `.claude/agents/frontend-flutter.md` para convenciones
3. Crear la pantalla con StatelessWidget + ConsumerWidget (Riverpod)
4. Seguir la paleta AppColors y tipografía DM Sans/DM Mono
5. Incluir soporte light/dark mode desde el inicio
6. Añadir la ruta correspondiente en AppRoutes
