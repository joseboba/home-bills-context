# /new-usecase

Crea un caso de uso en el domain layer.

## Uso
```
/new-usecase <feature> <action>
```

## Ejemplo
```
/new-usecase expenses create-expense
```

## Lo que genera
`lib/features/<feature>/domain/usecases/<action>_usecase.dart`

## Template
```dart
class <Action>UseCase {
  final <Feature>Repository _repository;
  const <Action>UseCase(this._repository);

  Future<Either<Failure, <ReturnType>>> execute(<Params> params) =>
      _repository.<method>(params);
}
```

## Instrucciones
1. Siempre retornar Either<Failure, T>
2. Un archivo por caso de uso
3. Inyectar repositorio por constructor
4. No lógica de UI ni Dio — solo llamar al repositorio
