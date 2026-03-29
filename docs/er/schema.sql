-- ══════════════════════════════════════════════════════════════════════
-- GastosApp — Schema SQL completo
-- PostgreSQL 15+ / Supabase
-- ══════════════════════════════════════════════════════════════════════
--
-- Schemas:
--   catalogs  → tablas de referencia / ENUMs normalizados
--   app       → configuración global y usuarios
--   expenses  → gastos, facturas e ítems
--   payments  → períodos, balances y pagos
-- ══════════════════════════════════════════════════════════════════════

CREATE SCHEMA IF NOT EXISTS catalogs;
CREATE SCHEMA IF NOT EXISTS app;
CREATE SCHEMA IF NOT EXISTS expenses;
CREATE SCHEMA IF NOT EXISTS payments;


-- ══════════════════════════════════════════════════════════════════════
-- SCHEMA: catalogs
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE catalogs.currencies (
  currency_code        TEXT PRIMARY KEY,
  currency_name        TEXT NOT NULL,
  currency_symbol      TEXT NOT NULL,
  is_active            BOOLEAN NOT NULL DEFAULT TRUE,
  currency_created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO catalogs.currencies (currency_code, currency_name, currency_symbol) VALUES
  ('GTQ', 'Quetzal guatemalteco',  'Q'),
  ('USD', 'Dólar estadounidense',  '$');

-- ──────────────────────────────────────────────────────────────────────

CREATE TABLE catalogs.debt_rules (
  debt_rule_code        TEXT PRIMARY KEY,
  debt_rule_name        TEXT NOT NULL,
  debt_rule_description TEXT NOT NULL,
  debt_rule_created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO catalogs.debt_rules (debt_rule_code, debt_rule_name, debt_rule_description) VALUES
  ('full',         'Deuda completa',  'El debt_owner debe el 100% del monto del ítem'),
  ('percentage',   'Porcentaje',      'El debt_owner debe un porcentaje definido del monto del ítem'),
  ('fixed_amount', 'Monto fijo',      'El debt_owner debe un monto fijo independiente del precio del ítem'),
  ('none',         'Sin deuda',       'El ítem no genera deuda, es gasto personal de quien pagó');


-- ══════════════════════════════════════════════════════════════════════
-- SCHEMA: app
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE app.app_config (
  app_config_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usd_to_gtq_rate       DECIMAL(10,4) NOT NULL,
  rate_updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  app_config_created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX app_config_single_row ON app.app_config ((TRUE));

INSERT INTO app.app_config (usd_to_gtq_rate) VALUES (7.8000);

-- ──────────────────────────────────────────────────────────────────────

-- NOTA: En Supabase, app_user_id referencia auth.users(id)
-- En local actúa standalone
CREATE TABLE app.app_users (
  app_user_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name         TEXT NOT NULL,
  email                TEXT NOT NULL UNIQUE,
  app_user_created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Usuarios de prueba para desarrollo local
INSERT INTO app.app_users (app_user_id, display_name, email) VALUES
  ('00000000-0000-0000-0000-000000000001', 'José Enrique', 'jose@gastosapp.com'),
  ('00000000-0000-0000-0000-000000000002', 'Mamá',          'mama@gastosapp.com');

-- Trigger para Supabase (comentado para local)
-- CREATE OR REPLACE FUNCTION app.handle_new_auth_user()
-- RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
-- BEGIN
--   INSERT INTO app.app_users (app_user_id, display_name, email)
--   VALUES (
--     NEW.id,
--     COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
--     NEW.email
--   );
--   RETURN NEW;
-- END;
-- $$;
-- CREATE TRIGGER on_auth_user_created
--   AFTER INSERT ON auth.users
--   FOR EACH ROW EXECUTE FUNCTION app.handle_new_auth_user();


-- ══════════════════════════════════════════════════════════════════════
-- SCHEMA: payments
-- (se crea antes que expenses por la FK de expenses → payments)
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE payments.expense_periods (
  expense_period_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  period_code          TEXT NOT NULL UNIQUE,  -- 'YYYY-MM'
  period_closed_at     TIMESTAMPTZ,           -- NULL = período activo
  period_created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_period_code_format CHECK (period_code ~ '^\d{4}-\d{2}$')
);

INSERT INTO payments.expense_periods (period_code)
  VALUES (TO_CHAR(NOW(), 'YYYY-MM'));

-- ──────────────────────────────────────────────────────────────────────

CREATE TABLE payments.expense_period_balances (
  period_balance_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_period_id         UUID NOT NULL REFERENCES payments.expense_periods(expense_period_id) ON DELETE CASCADE,
  currency_code             TEXT NOT NULL REFERENCES catalogs.currencies(currency_code),
  opening_balance           DECIMAL(10,2) NOT NULL DEFAULT 0,
  closing_balance           DECIMAL(10,2),  -- NULL = período activo
  period_balance_created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT uq_period_currency UNIQUE (expense_period_id, currency_code)
);

-- ──────────────────────────────────────────────────────────────────────

CREATE TABLE payments.debt_payments (
  debt_payment_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_period_code       TEXT NOT NULL REFERENCES payments.expense_periods(period_code),
  paid_by_user_id           UUID NOT NULL REFERENCES app.app_users(app_user_id),
  paid_to_user_id           UUID NOT NULL REFERENCES app.app_users(app_user_id),
  payment_amount            DECIMAL(10,2) NOT NULL,
  payment_currency_code     TEXT NOT NULL REFERENCES catalogs.currencies(currency_code),
  payment_note              TEXT,
  payment_date              TIMESTAMPTZ NOT NULL,
  payment_created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_payment_users_different CHECK (paid_by_user_id != paid_to_user_id),
  CONSTRAINT chk_payment_amount_positive CHECK (payment_amount > 0)
);


-- ══════════════════════════════════════════════════════════════════════
-- SCHEMA: expenses
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE expenses.expenses (
  expense_id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_period_code     TEXT NOT NULL REFERENCES payments.expense_periods(period_code),
  paid_by_user_id         UUID NOT NULL REFERENCES app.app_users(app_user_id),
  co_payer_user_id        UUID REFERENCES app.app_users(app_user_id),
  co_payment_amount       DECIMAL(10,2),
  merchant_name           TEXT,
  expense_currency_code   TEXT NOT NULL REFERENCES catalogs.currencies(currency_code),
  expense_total_amount    DECIMAL(10,2) NOT NULL,
  expense_note            TEXT,
  expense_date            TIMESTAMPTZ NOT NULL,
  expense_created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_co_payer_different CHECK (co_payer_user_id IS NULL OR co_payer_user_id != paid_by_user_id),
  CONSTRAINT chk_co_payment_amount  CHECK (co_payer_user_id IS NULL OR co_payment_amount IS NOT NULL),
  CONSTRAINT chk_total_positive     CHECK (expense_total_amount > 0)
);

-- ──────────────────────────────────────────────────────────────────────

CREATE TABLE expenses.expense_items (
  expense_item_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_id            UUID NOT NULL REFERENCES expenses.expenses(expense_id) ON DELETE CASCADE,
  item_name             TEXT NOT NULL,
  item_quantity         DECIMAL(10,3) NOT NULL,
  item_unit_price       DECIMAL(10,2) NOT NULL,
  item_total_amount     DECIMAL(10,2) NOT NULL,  -- quantity × unit_price (desnormalizado)
  item_note             TEXT,
  debt_rule_code        TEXT NOT NULL REFERENCES catalogs.debt_rules(debt_rule_code),
  debt_rule_value       DECIMAL(10,2),
  debt_owner_user_id    UUID REFERENCES app.app_users(app_user_id),

  CONSTRAINT chk_item_quantity_positive   CHECK (item_quantity > 0),
  CONSTRAINT chk_item_unit_price_positive CHECK (item_unit_price > 0),
  CONSTRAINT chk_item_total_positive      CHECK (item_total_amount > 0),
  CONSTRAINT chk_debt_value_required      CHECK (
    (debt_rule_code IN ('full', 'none')               AND debt_rule_value IS NULL) OR
    (debt_rule_code IN ('percentage', 'fixed_amount') AND debt_rule_value IS NOT NULL AND debt_rule_value > 0)
  ),
  CONSTRAINT chk_debt_owner_required      CHECK (
    (debt_rule_code = 'none'  AND debt_owner_user_id IS NULL) OR
    (debt_rule_code != 'none' AND debt_owner_user_id IS NOT NULL)
  ),
  CONSTRAINT chk_percentage_max           CHECK (
    debt_rule_code != 'percentage' OR debt_rule_value <= 100
  )
);


-- ══════════════════════════════════════════════════════════════════════
-- VISTA: Balance neto por período y moneda
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW payments.v_balance_by_period AS
WITH debt_generated AS (
  SELECT
    e.expense_period_code,
    e.expense_currency_code  AS currency_code,
    ei.debt_owner_user_id    AS debtor_user_id,
    e.paid_by_user_id        AS creditor_user_id,
    SUM(
      CASE ei.debt_rule_code
        WHEN 'full'         THEN ei.item_total_amount
        WHEN 'percentage'   THEN ROUND(ei.item_total_amount * ei.debt_rule_value / 100, 2)
        WHEN 'fixed_amount' THEN ei.debt_rule_value
        ELSE 0
      END
    ) AS debt_amount
  FROM expenses.expense_items ei
  JOIN expenses.expenses e ON e.expense_id = ei.expense_id
  WHERE ei.debt_rule_code != 'none'
  GROUP BY e.expense_period_code, e.expense_currency_code, ei.debt_owner_user_id, e.paid_by_user_id
),
payments_made AS (
  SELECT
    expense_period_code,
    payment_currency_code AS currency_code,
    paid_by_user_id,
    paid_to_user_id,
    SUM(payment_amount) AS total_paid
  FROM payments.debt_payments
  GROUP BY expense_period_code, payment_currency_code, paid_by_user_id, paid_to_user_id
)
SELECT
  ep.expense_period_id,
  ep.period_code,
  ep.period_closed_at,
  c.currency_code,
  COALESCE(epb.opening_balance, 0)              AS opening_balance,
  COALESCE(SUM(dg.debt_amount), 0)              AS total_debts_generated,
  COALESCE(SUM(pm.total_paid), 0)               AS total_payments_made,
  COALESCE(epb.opening_balance, 0)
    + COALESCE(SUM(dg.debt_amount), 0)
    - COALESCE(SUM(pm.total_paid), 0)           AS current_net_balance
FROM payments.expense_periods ep
CROSS JOIN catalogs.currencies c
LEFT JOIN payments.expense_period_balances epb
       ON epb.expense_period_id = ep.expense_period_id
      AND epb.currency_code = c.currency_code
LEFT JOIN debt_generated dg
       ON dg.expense_period_code = ep.period_code
      AND dg.currency_code = c.currency_code
LEFT JOIN payments_made pm
       ON pm.expense_period_code = ep.period_code
      AND pm.currency_code = c.currency_code
WHERE c.is_active = TRUE
GROUP BY ep.expense_period_id, ep.period_code, ep.period_closed_at,
         c.currency_code, epb.opening_balance;
