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
  presentation/
    providers/<feature>_provider.dart
    screens/
    widgets/
```

## Instrucciones
1. Leer `CLAUDE.md` y `.claude/agents/frontend-flutter.md`
2. Generar todos los archivos con el boilerplate correcto
3. Freezed en modelos y entidades
4. Riverpod AsyncNotifier en providers
5. Either<Failure,T> en usecases
