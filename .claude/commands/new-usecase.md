---
description: Crea un caso de uso en el domain layer con Either<Failure, T> y lo exporta desde el barrel.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

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

## Antes de generar código

Argumentos recibidos: `$ARGUMENTS`

Extraer del texto anterior los valores ya proporcionados. Para todo lo que falte o no esté claro, preguntar al usuario antes de continuar. No generar ningún archivo hasta tener respuesta a todas las preguntas pendientes.

Si la acción en `$ARGUMENTS` no tiene verbo claro (ej: solo `expense` en lugar de `create-expense`), preguntar por la operación antes de continuar.

Preguntas:
1. ¿Feature y acción? — requeridos si no están en `$ARGUMENTS`. La acción debe tener verbo (ej: `get-balance`, `create-expense`, `delete-payment`)
2. ¿Qué retorna? (`T` en `Either<Failure, T>`) — ej: `Expense`, `List<Payment>`, `HomeBalance`, `void`
3. ¿Qué params recibe en `execute()`? — nombre y tipo de cada parámetro (ej: `String expenseId`, `CreateExpenseParams params`), o `void` si no recibe nada
4. ¿Qué método del repositorio llama? (ej: `_repository.create(params)`, `_repository.getById(id)`)

## Lo que genera
`lib/features/<feature>/domain/usecases/<action>_usecase.dart`

## Template
```dart
class <Action>UseCase {
  final <Feature>Repository _repository;
  const <Action>UseCase(this._repository);

  Future<Either<Failure, <ReturnType>>> execute(<Params>) =>
      _repository.<method>(<args>);
}
```

## Instrucciones

1. Leer `.claude/agents/frontend-flutter.md` para convenciones de imports y arquitectura
2. Nombre de clase: `<Action>UseCase` en PascalCase (ej: `CreateExpenseUseCase`)
3. Nombre de archivo: `<action>_usecase.dart` en snake_case (ej: `create_expense_usecase.dart`)
4. Siempre retornar `Either<Failure, T>` — nunca lanzar excepciones directamente
5. Un archivo por caso de uso — no agrupar múltiples acciones en un mismo archivo
6. Inyectar repositorio por constructor — no instanciar ni usar Dio directamente
7. No lógica de UI, no Riverpod, no Supabase — solo delegar al repositorio
8. Exportar desde el barrel `domain/usecases/usecases.dart`
