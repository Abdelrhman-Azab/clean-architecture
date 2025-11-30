# Clean Architecture Starter Project for Flutter

This project serves as a template and example for implementing Clean Architecture in Flutter applications. It follows a **Feature-First** organization strategy, ensuring scalability, testability, and maintainability for future projects.

## Architecture Overview

The architecture is divided into **3 main layers** per feature. The dependency rule is strict: **inner layers should not know about outer layers**.

### 1. Domain Layer (The Inner Core)
This is the heart of the application. It contains pure business logic and is completely independent of Flutter, external libraries, or data sources.
- **Entities**: Simple Dart objects representing the core data (e.g., `User`, `Product`).
- **Repositories (Interfaces)**: Abstract contracts defining *what* operations can be performed (e.g., `Future<User> login()`), without knowing *how* they are implemented.
- **UseCases**: Classes that encapsulate a single specific business rule or action (e.g., `LoginUser`, `GetConcreteNumber`). They orchestrate the flow of data to and from the repositories.

### 2. Data Layer (The Adapter)
This layer is responsible for retrieving and storing data. It acts as the bridge between the Domain layer and the outside world.
- **Models**: Subclasses of Entities that handle JSON serialization/deserialization (`fromJson`, `toJson`) and data transformation.
- **Data Sources**: Low-level logic to fetch data.
    - *RemoteDataSource*: Handles API calls (Dio, Http).
    - *LocalDataSource*: Handles caching and local storage (Hive, SharedPrefs, SQLite).
- **Repositories (Implementation)**: Implements the abstract Domain Repository. It contains the logic to decide where to fetch data (e.g., check local cache first; if empty, call API).

### 3. Presentation Layer (The UI)
This layer handles what the user sees and interacts with.
- **State Management (Cubit)**: Exposes functions to the UI, executes UseCases, and emits States. It keeps logic out of the UI widgets.
- **States (Freezed)**: We use `freezed` to create immutable state unions (e.g., `Initial`, `Loading`, `Success`, `Error`), enabling safe pattern matching in the UI.
- **Pages & Widgets**: "Dumb" UI components that simply render the current State and call Cubit functions.

---

## Key Packages & Tools
- **Freezed**: For immutable data classes, union types (States), and `copyWith` functionality. Essential for robust Domain Entities and Cubit States.
- **Json Serializable**: Works with Freezed for automatic JSON parsing in the Data layer.
- **GetIt & Injectable**: For Dependency Injection (wiring up the layers).
- **Dartz / fpdart**: (Optional) For functional error handling (`Either<Failure, Success>`).

## Folder Structure

We use a **Feature-First** approach. Each feature (e.g., `authentication`, `number_trivia`) is a self-contained module with its own 3 layers.

```text
lib/
├── core/                       # Global reusable code
│   ├── error/                  # Failures and Exceptions
│   ├── network/                # Network info checker
│   └── usecases/               # Base UseCase interface
│
├── features/
│   └── number_trivia/          # Example Feature
│       ├── data/
│       │   ├── datasources/    # RemoteDataSource, LocalDataSource
│       │   ├── models/         # NumberTriviaModel
│       │   └── repositories/   # NumberTriviaRepositoryImpl
│       │
│       ├── domain/
│       │   ├── entities/       # NumberTrivia
│       │   ├── repositories/   # INumberTriviaRepository
│       │   └── usecases/       # GetRandomNumberTrivia
│       │
│       └── presentation/
│           ├── cubit/          # NumberTriviaCubit
│           ├── pages/          # NumberTriviaPage
│           └── widgets/        # Feature-specific widgets
│
└── main.dart
```

## Why this Architecture?
- **Scalability**: Features are independent. Adding a new feature doesn't break existing ones.
- **"Screaming" Architecture**: The directory structure tells you *what the app does* (UseCases) rather than just *how it's built*.
- **Reusability**: Business logic (UseCases) is decoupled from UI and Frameworks.
- **Testability**: Each layer can be tested in isolation (Unit Tests for Domain/Data, Widget Tests for Presentation).

---

## Full Feature Example: Number Trivia

Here is a walkthrough of how a feature is implemented, starting from the inner Domain layer out to the Presentation layer.

### 1. Domain Layer (Business Logic)

**Entity (`entities/number_trivia.dart`)**
Pure Dart class. using `freezed` here is great for value equality.
```dart
@freezed
class NumberTrivia with _$NumberTrivia {
  const factory NumberTrivia({
    required String text,
    required int number,
  }) = _NumberTrivia;
}
```

**Repository Interface (`repositories/number_trivia_repository.dart`)**
Defines the contract. We use `Either` (from `dartz` or `fpdart`) to handle errors gracefully without try-catch blocks in UI.
```dart
abstract class NumberTriviaRepository {
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number);
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia();
}
```

**UseCase (`usecases/get_random_number_trivia.dart`)**
Encapsulates the action.
```dart
class GetRandomNumberTrivia {
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia(this.repository);

  Future<Either<Failure, NumberTrivia>> call() async {
    return await repository.getRandomNumberTrivia();
  }
}
```

### 2. Data Layer (Data Retrieval)

**Model (`models/number_trivia_model.dart`)**
Extends or implements the Entity. Adds JSON parsing.
```dart
@freezed
class NumberTriviaModel with _$NumberTriviaModel implements NumberTrivia {
  const factory NumberTriviaModel({
    required String text,
    required int number,
  }) = _NumberTriviaModel;

  factory NumberTriviaModel.fromJson(Map<String, dynamic> json) =>
      _$NumberTriviaModelFromJson(json);
}
```

**Repository Implementation (`repositories/number_trivia_repository_impl.dart`)**
The "Brain" that decides which data source to use.
```dart
class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  // Constructor...

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await remoteDataSource.getRandomNumberTrivia();
        localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
```

### 3. Presentation Layer (UI & State)

**Cubit State (`cubit/number_trivia_state.dart`)**
Union types with Freezed.
```dart
@freezed
class NumberTriviaState with _$NumberTriviaState {
  const factory NumberTriviaState.initial() = _Initial;
  const factory NumberTriviaState.loading() = _Loading;
  const factory NumberTriviaState.loaded(NumberTrivia trivia) = _Loaded;
  const factory NumberTriviaState.error(String message) = _Error;
}
```

**Cubit (`cubit/number_trivia_cubit.dart`)**
Manages the state.
```dart
class NumberTriviaCubit extends Cubit<NumberTriviaState> {
  final GetRandomNumberTrivia getRandomNumberTrivia;

  NumberTriviaCubit({required this.getRandomNumberTrivia}) 
      : super(const NumberTriviaState.initial());

  Future<void> getTrivia() async {
    emit(const NumberTriviaState.loading());
    final failureOrTrivia = await getRandomNumberTrivia();
    
    emit(failureOrTrivia.fold(
      (failure) => NumberTriviaState.error(_mapFailureToMessage(failure)),
      (trivia) => NumberTriviaState.loaded(trivia),
    ));
  }
}
```

**Page (`pages/number_trivia_page.dart`)**
Consumes the state.
```dart
BlocBuilder<NumberTriviaCubit, NumberTriviaState>(
  builder: (context, state) {
    return state.when(
      initial: () => MessageDisplay(message: 'Start searching!'),
      loading: () => LoadingWidget(),
      loaded: (trivia) => TriviaDisplay(numberTrivia: trivia),
      error: (message) => MessageDisplay(message: message),
    );
  },
);
```



A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
