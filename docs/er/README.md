# Modelo de Datos — GastosApp

## Schemas

| Schema | Responsabilidad |
|---|---|
| `catalogs` | ENUMs normalizados: monedas, reglas de deuda |
| `app` | Configuración global y usuarios |
| `expenses` | Gastos, ítems, períodos y balances de período |
| `payments` | Pagos directos y vista de balance neto |

---

## Relaciones clave

```
catalogs.currencies ←── expenses.expenses (expense_currency_code)
                    ←── payments.debt_payments (payment_currency_code)
                    ←── expenses.expense_period_balances (currency_code)

catalogs.debt_rules ←── expenses.expense_items (debt_rule_code)

app.app_users ←── expenses.expenses (paid_by_user_id, co_payer_user_id)
              ←── expenses.expense_items (debt_owner_user_id)
              ←── payments.debt_payments (paid_by_user_id, paid_to_user_id)

expenses.expense_periods ←── expenses.expenses (expense_period_code)
                         ←── payments.debt_payments (expense_period_code)
                         ←── expenses.expense_period_balances (expense_period_id)
```

---

## Descripción de tablas

### catalogs.currencies
Monedas soportadas. Extensible sin tocar el schema.
Datos semilla: GTQ (Quetzal, Q), USD (Dólar, $)

### catalogs.debt_rules
Tipos de regla de deuda disponibles por ítem:
| Código | Cálculo |
|---|---|
| `full` | debt = item_total_amount |
| `percentage` | debt = item_total_amount × (debt_rule_value / 100) |
| `fixed_amount` | debt = debt_rule_value |
| `none` | debt = 0 (gasto personal) |

### app.app_config
Una sola fila (constraint único). Tipo de cambio USD→GTQ configurable directo en DB.

### app.app_users
Espejo de Supabase auth.users. Trigger `on_auth_user_created` sincroniza automáticamente.
En producción solo existen 2 usuarios (José Enrique y Mamá).

### expenses.expense_periods
Un registro por mes en formato 'YYYY-MM'.
`period_closed_at = NULL` → período activo.
Cierre automático al cambio de mes.

### expenses.expense_period_balances
Balance por período × moneda. Normalizado: una fila por (período, moneda).
`opening_balance` = arrastre del mes anterior.
`closing_balance = NULL` → período activo.

### expenses.expenses
Una factura o gasto. Puede tener co_payer si ambos pagaron parte.
Constraints importantes:
- co_payer_user_id != paid_by_user_id
- Si hay co_payer, co_payment_amount es obligatorio

### expenses.expense_items
Ítem individual con su regla de deuda independiente.
`item_total_amount` = quantity × unit_price (desnormalizado para performance).
Constraints en DB validan coherencia de debt_rule_code vs debt_rule_value vs debt_owner.

### payments.debt_payments
Pago directo entre usuarios para saldar deuda acumulada.

### payments.v_balance_by_period (VISTA)
Calcula el balance neto automáticamente:
`current_net_balance = opening_balance + total_debts_generated - total_payments_made`

---

## Ejemplo del flujo de deuda

```
José paga pantalón Q200 para mamá:
  expense_items: debt_rule='full', debt_owner=mamá
  → mamá debe +Q200

Mamá paga supermercado Q100:
  ítem leche Q20: debt_rule='percentage', value=50, owner=josé → josé debe Q10
  ítem shampoo Q80: debt_rule='full', owner=josé → josé debe Q80
  → josé debe +Q90

Balance neto: mamá debe Q200 - Q90 = Q110 a José ✅

Mamá registra pago de Q110:
  payments.debt_payments: paid_by=mamá, paid_to=josé, amount=110
  → balance neto = Q0
```
