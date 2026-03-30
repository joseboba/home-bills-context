---
description: Crea una pantalla Flutter con su ruta en GoRouter, dentro de una feature existente.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

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

## Antes de generar código

Argumentos recibidos: `$ARGUMENTS`

Extraer del texto anterior los valores ya proporcionados. Para todo lo que falte o no esté claro, preguntar al usuario antes de continuar. No generar ningún archivo hasta tener respuesta a todas las preguntas pendientes.

Preguntas:
1. ¿Feature y nombre de la pantalla? — requeridos si no están en `$ARGUMENTS`. Features disponibles: `expenses`, `auth`, `balance`, `payments`, `history`, `home`
2. ¿Cuál es el propósito de esta pantalla? (una línea) — ayuda a nombrar el provider y la ruta correctamente
3. ¿Recibe parámetros de navegación? (ej: `expenseId: String`, `periodCode: String`) — define el constructor de la ruta en GoRouter; responder "ninguno" si no aplica
4. ¿Qué datos muestra o con qué providers interactúa? (ej: lee `expenseListProvider`, dispara `createExpenseProvider`) — si no está claro, describir qué información aparece en pantalla
5. ¿Tiene formulario o inputs? — determina si necesita `ConsumerStatefulWidget` con `TextEditingController`

## Lo que genera
- `lib/features/<feature>/presentation/screens/<screen_name>_screen.dart`
- `lib/features/<feature>/presentation/providers/<screen_name>_provider.dart` (solo si el usuario confirmó que la pantalla necesita estado propio)
- Ruta registrada en `lib/config/router/app_routes.dart`

## Instrucciones

1. Leer `CLAUDE.md` para contexto del proyecto
2. Leer `.claude/agents/frontend-flutter.md` para convenciones de arquitectura e imports
3. Leer `.claude/skills/design-system/SKILL.md` para estructura visual, spacing y tipografía
4. Crear la pantalla con `ConsumerWidget` por defecto
   - Usar `ConsumerStatefulWidget` solo si el usuario confirmó formulario/inputs (necesita `TextEditingController`, `FocusNode`)
5. Incluir `SafeArea` en el widget raíz de la pantalla
6. Usar `AppSpacing.X` para todos los espaciados — nunca valores numéricos inline
7. Soporte light/dark mode usando `context.theme` y `context.colorScheme`
8. Registrar la ruta en `lib/config/router/app_routes.dart` (no en `lib/core/router/`)
9. No crear provider automáticamente — solo si el usuario lo confirmó en la pregunta 4 o 5
