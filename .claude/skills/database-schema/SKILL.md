---
name: database-schema
description: Schema de la base de datos de GastosApp (Supabase/PostgreSQL). Úsalo cuando necesites saber qué campos devuelve el backend, cómo se relacionan las tablas, o qué modelos Freezed crear para deserializar respuestas de la API.
---

# Skill: Database Schema — GastosApp

El frontend **no accede a Supabase directamente** (salvo auth). Toda la data viene del backend NestJS via HTTP. Este schema es la fuente de verdad de qué campos existen y cómo se llaman — los endpoints del backend los reflejan en sus responses.

---

## Schemas en DB

| Schema | Contenido |
|---|---|
| `catalogs` | ENUMs normalizados: monedas, reglas de deuda |
| `app` | Configuración global y usuarios |
| `expenses` | Gastos y sus ítems |
| `payments` | Períodos, balances por período, pagos directos |

---

## Tablas de referencia (catalogs)

### `catalogs.currencies`
| Campo | Tipo | Notas |
|---|---|---|
| `currency_code` | TEXT PK | `'GTQ'` \| `'USD'` |
| `currency_name` | TEXT | "Quetzal guatemalteco" |
| `currency_symbol` | TEXT | `'Q'` \| `'$'` |
| `is_active` | BOOLEAN | |

### `catalogs.debt_rules`
| Campo | Tipo | Notas |
|---|---|---|
| `debt_rule_code` | TEXT PK | `'full'` \| `'percentage'` \| `'fixed_amount'` \| `'none'` |
| `debt_rule_name` | TEXT | |

---

## app.app_users

| Campo | Tipo | Notas |
|---|---|---|
| `app_user_id` | UUID PK | Espejo de `auth.users.id` en Supabase |
| `display_name` | TEXT | "José Enrique" o "Mamá" |
| `email` | TEXT UNIQUE | |

Solo existen 2 registros en producción.

---

## expenses.expenses

| Campo | Tipo | Notas |
|---|---|---|
| `expense_id` | UUID PK | |
| `expense_period_code` | TEXT FK | `'YYYY-MM'` → `expense_periods.period_code` |
| `paid_by_user_id` | UUID FK | Quien pagó (principal) |
| `co_payer_user_id` | UUID FK? | Quien pagó parte (opcional) |
| `co_payment_amount` | DECIMAL(10,2)? | Obligatorio si hay co_payer |
| `merchant_name` | TEXT? | Nombre del comercio/tienda |
| `expense_currency_code` | TEXT FK | `'GTQ'` \| `'USD'` |
| `expense_total_amount` | DECIMAL(10,2) | Total del gasto |
| `expense_note` | TEXT? | Nota opcional |
| `expense_date` | TIMESTAMPTZ | Fecha del gasto (no de creación) |
| `expense_created_at` | TIMESTAMPTZ | |

---

## expenses.expense_items

| Campo | Tipo | Notas |
|---|---|---|
| `expense_item_id` | UUID PK | |
| `expense_id` | UUID FK | Cascading delete |
| `item_name` | TEXT | Nombre del ítem |
| `item_quantity` | DECIMAL(10,3) | |
| `item_unit_price` | DECIMAL(10,2) | |
| `item_total_amount` | DECIMAL(10,2) | `quantity × unit_price` (desnormalizado) |
| `item_note` | TEXT? | |
| `debt_rule_code` | TEXT FK | `'full'` \| `'percentage'` \| `'fixed_amount'` \| `'none'` |
| `debt_rule_value` | DECIMAL(10,2)? | NULL para `full`/`none`; requerido para `percentage`/`fixed_amount` |
| `debt_owner_user_id` | UUID FK? | NULL si `debt_rule_code = 'none'`; requerido en otros casos |

---

## payments.expense_periods

| Campo | Tipo | Notas |
|---|---|---|
| `expense_period_id` | UUID PK | |
| `period_code` | TEXT UNIQUE | `'YYYY-MM'` (ej: `'2026-03'`) |
| `period_closed_at` | TIMESTAMPTZ? | NULL = período activo |

---

## payments.debt_payments

| Campo | Tipo | Notas |
|---|---|---|
| `debt_payment_id` | UUID PK | |
| `expense_period_code` | TEXT FK | |
| `paid_by_user_id` | UUID FK | Quien pagó la deuda |
| `paid_to_user_id` | UUID FK | Quien recibió el pago |
| `payment_amount` | DECIMAL(10,2) | > 0 |
| `payment_currency_code` | TEXT FK | `'GTQ'` \| `'USD'` |
| `payment_note` | TEXT? | |
| `payment_date` | TIMESTAMPTZ | |

---

## payments.v_balance_by_period (VISTA — endpoint `/balance`)

Esta vista es lo que el endpoint `/balance` devuelve. Es el dato central de la app.

| Campo | Tipo | Notas |
|---|---|---|
| `expense_period_id` | UUID | |
| `period_code` | TEXT | `'YYYY-MM'` |
| `period_closed_at` | TIMESTAMPTZ? | NULL = activo |
| `currency_code` | TEXT | Una fila por moneda |
| `opening_balance` | DECIMAL | Arrastre del período anterior |
| `total_debts_generated` | DECIMAL | Suma de deudas del período |
| `total_payments_made` | DECIMAL | Suma de pagos del período |
| `current_net_balance` | DECIMAL | `opening + debts - payments` |

**Positivo** = alguien debe dinero. El backend decide la dirección (quién debe a quién).

---

## Relaciones clave

```
app_users ──< expenses (paid_by, co_payer)
app_users ──< expense_items (debt_owner)
app_users ──< debt_payments (paid_by, paid_to)

expense_periods ──< expenses (period_code)
expense_periods ──< debt_payments (period_code)
expense_periods ──< expense_period_balances

expenses ──< expense_items (cascade delete)
```

---

## Modelos Freezed recomendados para el frontend

`build.yaml` configura `field_rename: snake` globalmente — los campos del modelo usan el
nombre completo de la columna DB en `camelCase` y `json_serializable` hace la conversión
automáticamente. **Sin `@JsonKey`.**

```dart
// Expense
@freezed
class ExpenseModel with _$ExpenseModel {
  const factory ExpenseModel({
    required String expenseId,           // → expense_id
    required String expensePeriodCode,   // → expense_period_code
    required String paidByUserId,        // → paid_by_user_id
    String? coPayerUserId,               // → co_payer_user_id
    double? coPaymentAmount,             // → co_payment_amount
    String? merchantName,                // → merchant_name
    required String expenseCurrencyCode, // → expense_currency_code
    required double expenseTotalAmount,  // → expense_total_amount
    String? expenseNote,                 // → expense_note
    required DateTime expenseDate,       // → expense_date
  }) = _ExpenseModel;
  factory ExpenseModel.fromJson(Map<String, dynamic> json) => _$ExpenseModelFromJson(json);
}
```

El mapper `toDomain()` traduce a los nombres limpios de la entidad de dominio.
