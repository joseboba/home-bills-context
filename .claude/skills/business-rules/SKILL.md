---
name: business-rules
description: Reglas de negocio de GastosApp. Úsalo para validar decisiones de producto, calcular deudas correctamente, entender el modelo de períodos y monedas, y conocer quiénes son los usuarios de la app.
---

# Skill: Business Rules — GastosApp

---

## Usuarios

La app tiene exactamente **2 usuarios fijos**. No hay registro público.

| Usuario | Rol |
|---|---|
| José Enrique | Usuario principal, desarrollador de la app |
| Mamá | Segunda usuaria |

En código, los usuarios se identifican por `app_user_id` (UUID). El frontend nunca hardcodea UUIDs — los resuelve consultando `app.app_users` o desde el JWT de Supabase.

---

## Tipos de regla de deuda por ítem

Cada ítem de un gasto tiene una regla independiente que define cuánto debe el `debt_owner`:

| Código | Chip UI | Cálculo | `debt_rule_value` |
|---|---|---|---|
| `full` | "Todo" | `debt = item_total_amount` | NULL |
| `percentage` | "%" | `debt = item_total_amount × (value / 100)` | 1–100 |
| `fixed_amount` | "Monto fijo" | `debt = value` | > 0 |
| `none` | "Solo mío" | `debt = 0` (gasto personal) | NULL |

**Reglas de validación en DB:**
- `full` y `none`: `debt_rule_value` debe ser NULL
- `percentage` y `fixed_amount`: `debt_rule_value` es obligatorio y > 0
- `percentage`: `debt_rule_value` ≤ 100
- Si `debt_rule_code = 'none'`: `debt_owner_user_id` debe ser NULL
- Si `debt_rule_code != 'none'`: `debt_owner_user_id` es obligatorio

---

## Cálculo del balance neto

```
balance_neto =
  opening_balance (arrastre del período anterior)
  + Σ deudas generadas por ítems donde debt_owner = usuario_B
  - Σ deudas generadas por ítems donde debt_owner = usuario_A
  - Σ payments donde paid_by = usuario_B → paid_to = usuario_A
  + Σ payments donde paid_by = usuario_A → paid_to = usuario_B
```

El backend expone esto via vista `payments.v_balance_by_period`. El frontend nunca recalcula el balance — lo consume del endpoint `/balance`.

---

## Períodos

- Un período = un mes, formato `'YYYY-MM'` (ej: `'2026-03'`)
- `period_closed_at = NULL` → período activo (el actual)
- Los períodos cierran automáticamente al cambio de mes
- Los períodos cerrados son **de solo lectura** — no se pueden agregar gastos ni pagos
- El saldo pendiente de un período cerrado se arrastra como `opening_balance` al siguiente

**Implicaciones para el frontend:**
- Antes de agregar un gasto, verificar que el período está activo
- Los movimientos de períodos cerrados se muestran pero sin botones de edición

---

## Monedas

| Código | Nombre | Símbolo |
|---|---|---|
| `GTQ` | Quetzal guatemalteco | Q |
| `USD` | Dólar estadounidense | $ |

- Cada gasto tiene **una sola moneda** (`expense_currency_code`)
- El balance se calcula **por separado para cada moneda**
- Conversión GTQ↔USD: se usa `app_config.usd_to_gtq_rate` (editable en DB, no en UI)
- El frontend muestra los balances por moneda o convertidos, según preferencia del usuario

Formateo estándar:
```
GTQ → "Q 245.50"
USD → "$12.50"
```

---

## Gastos con co-pagador

Un gasto puede tener dos pagadores:
- `paid_by_user_id`: quien pagó la mayor parte (o todo)
- `co_payer_user_id`: quien pagó una parte (`co_payment_amount`)
- Si hay `co_payer`, `co_payment_amount` es obligatorio
- `co_payer_user_id != paid_by_user_id` (constraint en DB)

---

## Flujo de vida de un gasto

```
1. Usuario toma foto (OCR) o ingresa manual
2. Se crean expense + expense_items con sus debt_rules
3. Los ítems con debt_rule != 'none' generan deuda automáticamente (vista en DB)
4. El balance neto se actualiza en tiempo real
5. Cuando la deuda acumula, el deudor registra un payment
6. Al cierre de mes, el balance pendiente se arrastra al siguiente período
```

---

## Pantallas y su propósito de negocio

| Pantalla | Propósito |
|---|---|
| Login | Autenticación — solo 2 usuarios, sin registro público |
| Home (Balance) | Vista principal — balance neto GTQ/USD + movimientos del período |
| Agregar Gasto | Entrada OCR o manual — foto → ítems → asignar deuda → guardar |
| Detalle de Gasto | Ver ítems, reglas de deuda aplicadas, deuda generada por gasto |
| Historial | Movimientos agrupados por semana, stats del mes seleccionado |
| Registrar Pago | Saldar deuda acumulada — monto, moneda, nota, preview del balance resultante |
