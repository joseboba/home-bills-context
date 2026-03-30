# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# GastosApp

App móvil para dos usuarios (José Enrique y su mamá) para registrar y dividir gastos del hogar.
Fase actual: **Fase 2 — Flutter MVP** (entrada manual, sin OCR todavía).

---

## Routing — qué herramienta usar para qué

| Tipo de tarea | Herramienta |
|---|---|
| Decisión de producto, UX o regla de negocio | agente `business-owner` |
| Código Flutter (pantallas, widgets, providers, modelos) | agente `frontend-flutter` |
| Revisar código generado antes de darlo por listo | agente `qa-reviewer` |
| Scaffolding de feature completa | comando `/new-feature` |
| Nueva pantalla | comando `/new-screen` |
| Nuevo widget reutilizable | comando `/new-widget` |
| Nuevo provider Riverpod | comando `/new-provider` |
| Nuevo caso de uso | comando `/new-usecase` |
| Design system (colores, spacing, tipografía, inputs) | skill `design-system` |
| Patrón de providers y notifiers | skill `riverpod-provider` |
| Toasts y feedback al usuario | skill `app-snackbar` |
| Flujo de errores (HttpException → Failure → AsyncError) | skill `error-handling` |
| Campos del backend y modelos Freezed | skill `database-schema` |
| Reglas de deuda, períodos, monedas, usuarios | skill `business-rules` |
| Widget selector de regla de deuda | skill `debt-rule-selector` |

---

## Comandos de Desarrollo

```bash
# Instalar dependencias
flutter pub get

# Generar código (Freezed, Riverpod, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Modo watch
dart run build_runner watch --delete-conflicting-outputs

# Ejecutar
flutter run

# Build release APK
flutter build apk --release

# Análisis estático
flutter analyze

# Formatear (excluye archivos generados)
dart format --exclude="**.g.dart,**.freezed.dart" lib/

# Tests
flutter test
flutter test test/features/auth/
flutter test test/features/auth/login_test.dart
```

---

## Estado del proyecto

| Feature | Estado |
|---|---|
| `auth/` | Implementado — login/logout con Supabase Auth |
| `home/` | Implementado — balance neto + movimientos del período |
| `balance/` | Stub — pantalla placeholder |
| `expenses/` | Stub — barrel file únicamente |
| `history/` | Stub — barrel file únicamente |
| `payments/` | Stub — barrel file únicamente |

---

## Fases

- **Fase 1** — Backend base: NestJS + Supabase, auth JWT, gastos manuales, balance ✅
- **Fase 2** — Flutter MVP: pantallas + OCR (ML Kit + Gemini) + entrada manual ← estamos aquí
- **Fase 3** — Nice to have: compartir resumen por WhatsApp

> El OCR es el flujo principal del MVP. ML Kit extrae texto on-device, Gemini lo estructura en JSON de ítems. La entrada manual es el fallback.

---

## Convenciones no negociables

- Imports internos: siempre `package:home_bills/...`, nunca rutas relativas
- `strict-casts: true` y `strict-raw-types: true` activos en `analysis_options.yaml`
- Regex de email: `RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')`
- Plugins externos (Dio, connectivity_plus, etc.) solo via `shared/plugins/` — nunca importar las librerías directamente en features
