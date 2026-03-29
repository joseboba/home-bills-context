---
name: debt-rule-selector
description: Skill para crear o modificar el selector de regla de deuda en Flutter. Úsalo cuando necesites implementar la UI para seleccionar entre full, percentage, fixed_amount o none en un ítem de gasto.
---

# Skill: DebtRuleSelector Widget

Widget para seleccionar el tipo de regla de deuda de un ítem.

## Comportamiento esperado

- 4 chips horizontales: "Todo" | "%" | "Monto fijo" | "Solo mío"
- Al seleccionar "%" → aparece TextField numérico (0-100)
- Al seleccionar "Monto fijo" → aparece TextField con símbolo de moneda
- Al seleccionar "Todo" o "Solo mío" → se ocultan los campos adicionales
- Chip activo: fondo `AppColors.primaryLight`, borde `AppColors.primary`
- Chip inactivo: fondo `AppColors.surface2`, borde `AppColors.border`
- "Solo mío" siempre fondo gris — nunca verde

## Parámetros del widget

```dart
class DebtRuleSelector extends ConsumerWidget {
  final String currentRule;           // 'full' | 'percentage' | 'fixed_amount' | 'none'
  final double? ruleValue;            // valor actual del % o monto
  final String currencyCode;          // 'GTQ' | 'USD'
  final void Function(String rule, double? value) onChanged;
}
```

## Mapeo visual

| Código | Chip label | Campo adicional |
|---|---|---|
| `full` | Todo | — |
| `percentage` | % | TextField "0-100" |
| `fixed_amount` | Monto fijo | TextField con símbolo moneda |
| `none` | Solo mío | — |
