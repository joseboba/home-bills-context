# home-bills-context

Repositorio de contexto para el proyecto **GastosApp** — app móvil Flutter para compartir y dividir gastos del hogar entre dos usuarios.

## Contenido

```
CLAUDE.md                          # Contexto principal del proyecto (leído por Claude Code)
.claude/
  agents/
    frontend-flutter.md            # Subagente especializado en Flutter
  commands/
    new-project.md                 # /new-project: inicializa el proyecto Flutter desde cero
    new-screen.md                  # /new-screen: scaffoldea una pantalla
    new-feature.md                 # /new-feature: scaffoldea una feature completa
    new-widget.md                  # /new-widget: crea un widget
    new-usecase.md                 # /new-usecase: crea un caso de uso
  skills/
    frontend/
      debt-rule-selector.md        # Skill: selector de regla de deuda
      app-snackbar.md              # Skill: toasts AppSnackBar + extensión de contexto
docs/
  er/
    README.md                      # Modelo de datos explicado con ejemplos
    schema.sql                     # SQL completo (Supabase + local)
  architecture/
    flutter-file-structure.md      # Árbol completo de carpetas Flutter
  mockups/
    prototype.html                 # Prototipo HTML interactivo navegable
```

## Uso con Claude Code

1. Clona este repo en la raíz de tu proyecto o como submódulo
2. Claude Code leerá automáticamente `CLAUDE.md` al iniciar
3. Usa los subagentes con `@frontend-flutter` en tus prompts
4. Usa los slash commands: `/new-project`, `/new-screen`, `/new-feature`, `/new-widget`, `/new-usecase`

## Stack

| Capa | Tecnología |
|---|---|
| Mobile | Flutter + Riverpod + GoRouter + Dio + Freezed |
| Auth | Supabase Auth + flutter_secure_storage |
| OCR | ML Kit (on-device) + Gemini API (gratis) |
| Backend | NestJS + TypeScript |
| DB | Supabase PostgreSQL |
| Hosting | Railway / Render |

## Supabase

Proyecto: `shared-bills` (us-west-2)
Migraciones aplicadas: ver `docs/er/schema.sql`
