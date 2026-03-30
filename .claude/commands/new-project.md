---
description: Inicializa el proyecto Flutter GastosApp desde cero con estructura base, configuración y boilerplate completo.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# /new-project

Inicializa el proyecto Flutter de HomeBillsApp desde cero con toda la estructura, configuración y boilerplate base.

## Uso
```
/new-project
```

## Antes de generar código

Este command no requiere argumentos. Antes de ejecutar cualquier paso, verificar:

1. ¿Existe ya un directorio `lib/` con archivos Dart? Ejecutar `ls lib/` para comprobarlo.
   - Si existe y tiene contenido: preguntar al usuario "Parece que ya hay un proyecto Flutter aquí. ¿Quieres continuar y sobreescribir los archivos base, o prefieres cancelar?"
   - Si no existe o está vacío: continuar con los pasos siguientes sin preguntar.

## Lo que genera

1. Proyecto Flutter (`flutter create`)
2. `pubspec.yaml` con todas las dependencias del stack
3. `analysis_options.yaml` con linter + exclusión de archivos generados
4. Estructura de carpetas completa (`lib/`)
5. Archivos barrel por carpeta
6. `main.dart` con orientación portrait + inicialización de Supabase + dotenv
7. `app.dart` con `MaterialApp.router` + tema light/dark
8. `AppColors`, `AppTextStyles`, `AppTheme`
9. `AppRoutes` con GoRouter skeleton
10. `build_context_ext.dart` con extensiones de contexto
11. `AppSnackBar` + extensión de contexto
12. `.env.example` con las variables necesarias

## Instrucciones

1. Leer `CLAUDE.md` completo para contexto y reglas
2. Leer `.claude/agents/frontend-flutter.md` para convenciones de código y estructura
3. Leer `.claude/skills/design-system/SKILL.md` para `AppColors`, `AppTextStyles` y `AppTheme`
4. Leer `.claude/skills/app-snackbar/SKILL.md` para `AppSnackBar` y extensiones de contexto
5. Leer `docs/architecture/flutter-file-structure.md` para el árbol exacto de carpetas

### Paso 1 — Crear el proyecto
```bash
flutter create --org com.homebills --platforms android home_bills
cd home_bills
```

### Paso 2 — `pubspec.yaml`
Reemplazar con:
```yaml
name: home_bills
description: App para dividir gastos del hogar.
publish_to: none
version: 1.0.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^14.6.2
  dio: ^5.7.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  supabase_flutter: ^2.8.4
  flutter_secure_storage: ^9.2.2
  google_mlkit_text_recognition: ^0.14.0
  image_picker: ^1.1.2
  intl: ^0.19.0
  flutter_dotenv: ^5.2.1
  connectivity_plus: ^6.1.1
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.9.0
  riverpod_generator: ^2.6.3
```

### Paso 3 — `analysis_options.yaml`
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "lib/generated/**"
  language:
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    prefer_single_quotes: true
    sort_child_properties_last: true
    use_super_parameters: true
```

### Paso 4 — Estructura de carpetas
Crear toda la estructura definida en `docs/architecture/flutter-file-structure.md`.
Crear barrel files en cada carpeta (archivo `<nombre_carpeta>.dart`).

### Paso 5 — `main.dart`
```dart
// Dart imports
import 'dart:async';

// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// External dependencies
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Internal dependencies
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: App()));
}
```

### Paso 6 — `app.dart`
MaterialApp.router con GoRouter + tema light/dark desde `AppTheme`.

### Paso 7 — Archivos core
- `config/theme/app_colors.dart` — colores definidos en `frontend-flutter.md`
- `config/theme/app_text_styles.dart` — DM Sans + DM Mono
- `config/theme/app_theme.dart` — ThemeData light + dark
- `config/router/app_routes.dart` — constantes de rutas + GoRouter

### Paso 8 — Extensiones de contexto
Crear `shared/extensions/build_context_ext.dart` con la extensión `AppContext`
(ver skill `app-snackbar` para implementación completa).

### Paso 9 — AppSnackBar
Crear `shared/presentation/snackbars/app_snackbar.dart`
(ver skill `app-snackbar` para implementación completa).

### Paso 10 — `.env.example`
```
# Supabase Auth — requerido por supabase_flutter (anon key es pública por diseño)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Backend NestJS — usado por Dio
API_BASE_URL=http://localhost:3000
```
> GEMINI_API_KEY NO va aquí — es exclusiva del backend NestJS.

### Verificación final
```bash
flutter pub get
flutter analyze
dart format lib/ --exclude="**.g.dart,**.freezed.dart"
flutter run
```
