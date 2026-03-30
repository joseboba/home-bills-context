---
description: Scaffoldea una feature completa con Clean Architecture (entidad, modelo, datasource, repositorio, usecases, provider, pantalla vacía y barrel).
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# /new-feature

Scaffoldea una feature completa con Clean Architecture.

## Uso
```
/new-feature <feature-name>
```

## Ejemplo
```
/new-feature notifications
```

## Antes de generar código

Argumentos recibidos: `$ARGUMENTS`

Extraer del texto anterior los valores ya proporcionados. Para todo lo que falte o no esté claro, preguntar al usuario antes de continuar. No generar ningún archivo hasta tener respuesta a todas las preguntas pendientes.

Preguntas:
1. ¿Nombre de la feature? (en kebab-case, ej: `notifications`, `expense-history`) — requerida si no está en `$ARGUMENTS`
2. ¿Qué entidad principal maneja? (ej: `Notification`, `Payment`) — define el nombre de la entidad Freezed y el modelo DTO
3. ¿Qué endpoints del backend va a consumir? (ej: `GET /notifications`, `POST /notifications/:id/read`) — define el datasource y cuántos usecases generar
4. ¿Tiene algún usecase especial además del CRUD básico? (ej: marcar como leído, calcular totales, aplicar filtros por período)

## Lo que genera
```
lib/features/<feature>/
  data/
    datasources/<feature>_remote_datasource.dart
    models/<feature>_model.dart
    repositories/<feature>_repository_impl.dart
  domain/
    entities/<feature>.dart
    repositories/<feature>_repository.dart
    usecases/
      <usecases según los endpoints confirmados>
      usecases.dart  (barrel)
  presentation/
    providers/<feature>_provider.dart
    providers/providers.dart  (barrel)
    screens/
    widgets/
  <feature>.dart  (barrel del módulo)
```

## Instrucciones

1. Leer `CLAUDE.md` y `.claude/agents/frontend-flutter.md` para convenciones de arquitectura e imports
2. Leer `.claude/skills/riverpod-provider/SKILL.md` para el patrón del provider principal
3. Generar todos los archivos con el boilerplate correcto usando las respuestas del usuario
4. `@freezed` en modelos (con `fromJson`) y entidades (sin `fromJson`)
5. `Either<Failure, T>` en todos los usecases — nunca lanzar excepciones directamente
6. Riverpod `AsyncNotifier` en el provider principal
7. Crear barrel `<feature>.dart` en la raíz de la feature que re-exporte data, domain y presentation
