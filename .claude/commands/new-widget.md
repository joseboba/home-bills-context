---
description: Crea un widget reutilizable Flutter en la carpeta widgets de una feature o en shared.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# /new-widget

Crea un widget reutilizable Flutter.

## Uso
```
/new-widget <feature|shared> <widget-name>
```

## Ejemplos
```
/new-widget expenses debt-rule-selector
/new-widget shared amount-chip
```

## Antes de generar código

Argumentos recibidos: `$ARGUMENTS`

Extraer del texto anterior los valores ya proporcionados. Para todo lo que falte o no esté claro, preguntar al usuario antes de continuar. No generar ningún archivo hasta tener respuesta a todas las preguntas pendientes.

Si el nombre del widget coincide con un skill existente (`debt-rule-selector`, `app-snackbar`), leer ese skill automáticamente antes de hacer preguntas — puede que ya tenga la especificación completa.

Preguntas:
1. ¿Feature o `shared`? ¿Nombre del widget? — requeridos si no están en `$ARGUMENTS`
2. ¿Cuáles son los parámetros del widget? — listar nombre, tipo y si son requeridos u opcionales (ej: `amount: double` requerido, `currencyCode: String` requerido, `onTap: VoidCallback?` opcional)
3. ¿Necesita estado interno? Si sí, ¿qué tipo? (ej: toggle bool, índice seleccionado, valor de input) — determina si necesita un provider `@riverpod` auto-dispose
4. ¿Emite eventos hacia el padre? (ej: `onChanged(String rule, double? value)`, `onTap()`) — define los callbacks del constructor

## Lo que genera
- `lib/features/<feature>/presentation/widgets/<widget_name>_widget.dart`
  o `lib/shared/presentation/<subcarpeta>/<widget_name>.dart` si es `shared`
- Provider local auto-dispose en el mismo archivo (solo si se confirmó estado interno)
- Export en el barrel correspondiente

## Instrucciones

1. Leer `.claude/agents/frontend-flutter.md` para paleta, convenciones e imports
2. Leer `.claude/skills/design-system/SKILL.md` para AppColors, AppTextStyles, AppSpacing y border radius
3. Si el nombre del widget coincide con un skill específico, leer ese skill en lugar de improvisar la implementación
4. Crear `ConsumerWidget` si tiene estado o necesita leer providers; `StatelessWidget` si no
5. Estado interno → provider `@riverpod` con `keepAlive: false` en el mismo archivo (no setState)
6. Soporte light/dark mode usando `context.theme` y `context.colorScheme`
7. Montos siempre con DM Mono (`AppTextStyles.amountX`)
8. Documentar todos los parámetros del constructor con doc comments (`///`)
9. Exportar desde el barrel de la carpeta correspondiente
