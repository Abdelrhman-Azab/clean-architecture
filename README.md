# Clean Architecture Starter Project for Flutter

This project is a robust, production-ready template for building scalable Flutter applications using **Clean Architecture** and the **Feature-First** organizational strategy. It comes pre-configured with a modern tech stack to ensure testability, maintainability, and separation of concerns.

## 🏗 Architecture Overview

The architecture follows the **Separation of Concerns** principle, dividing the application into three independent layers per feature. The **Dependency Rule** is strictly enforced: dependencies only point inwards. Inner layers (Domain) know nothing about outer layers (Data, Presentation).

### 1. Domain Layer (The Core)

- **Role**: Contains pure business logic and enterprise rules.
- **Dependencies**: None. It is platform-agnostic (pure Dart).
- **Components**:
  - **Entities**: Immutable business objects (e.g., `Product`).
  - **UseCases**: Encapsulate specific business actions (e.g., `GetProducts`). They act as the entry point to the domain.
  - **Repository Interfaces**: Abstract contracts defining _what_ data operations are available, without specifying _how_ they are implemented.

### 2. Data Layer (The Infrastructure)

- **Role**: Handles data retrieval, storage, and transformation.
- **Dependencies**: Domain Layer, External Libraries (Dio, Hive).
- **Components**:
  - **Models**: Data Transfer Objects (DTOs) that extend Entities. They handle JSON serialization/deserialization.
  - **Data Sources**:
    - _Remote_: Handles API communication (REST, GraphQL).
    - _Local_: Handles device storage (Database, Cache).
  - **Repository Implementations**: Concrete classes that implement the Domain Repository interfaces. They orchestrate data flow (e.g., "Check cache; if empty, fetch from API and save to cache").

### 3. Presentation Layer (The UI)

- **Role**: Renders the UI and handles user interaction.
- **Dependencies**: Domain Layer.
- **Components**:
  - **State Management (Cubit)**: Manages the state of the view. It calls UseCases and emits States.
  - **Pages & Widgets**: Dumb components that listen to state changes and render the UI.

---

## 🛠 Tech Stack & Benefits

We carefully selected libraries that enforce best practices and reduce boilerplate.

### Core

- **[flutter_bloc](https://pub.dev/packages/flutter_bloc)**: The industry standard for state management.
  - _Benefit_: Separates business logic (Cubit/Bloc) from UI (Widgets). predictable state changes and easy testing.
- **[go_router](https://pub.dev/packages/go_router)**: A declarative routing package.
  - _Benefit_: Simplifies deep linking, nested navigation, and redirection logic compared to the standard Navigator.
- **[get_it](https://pub.dev/packages/get_it)**: A Service Locator for Dependency Injection.
  - _Benefit_: Decouples classes. You request an abstract interface (e.g., `ProductsRepository`), and `get_it` provides the concrete implementation.

### Data & Networking

- **[dio](https://pub.dev/packages/dio)**: A powerful HTTP client for Dart.
  - _Benefit_: Supports interceptors (for logging/auth), global configuration, and cancellation tokens.
- **[hive](https://pub.dev/packages/hive)**: A lightweight, key-value database.
  - _Benefit_: Extremely fast and synchronous local caching.
- **[internet_connection_checker](https://pub.dev/packages/internet_connection_checker)**: Checks for internet connectivity.
  - _Benefit_: Allows the app to robustly switch between Remote and Local data sources.

### Functional & Type Safety

- **[freezed](https://pub.dev/packages/freezed)**: Code generation for immutable classes and unions.
  - _Benefit_: Provides `copyWith`, `toString`, `==` override, and Pattern Matching (Sealed Classes) out of the box. Essential for safe State management.
- **[fpdart](https://pub.dev/packages/fpdart)**: Functional programming types.
  - _Benefit_: We use `Either<Failure, Success>` for error handling. This forces the developer to handle both success and failure cases, eliminating runtime exceptions.

---

## ✅ Requirements

- Dart `^3.9.0` (see `pubspec.yaml:21-23`)
- Flutter (stable channel)
- Code generation tools: `build_runner`, `freezed`, `json_serializable`

---

## 📂 Folder Structure (Feature-First)

We group files by **Feature**, not by layer. This ensures that when you work on a feature (e.g., `Products`), you have everything you need in one place.

```text
lib/
├── core/                       # Shared kernel (Error handling, DI, Routes)
│   ├── di/                     # Dependency Injection Setup
│   ├── error/                  # Failure definitions
│   ├── routes/                 # GoRouter configuration
│   └── usecase/                # Base UseCase interface
│
├── features/
│   └── products/               # FEATURE: Products
│       ├── data/
│       │   ├── datasources/    # ProductsRemoteDataSource, ProductsLocalDataSource
│       │   ├── models/         # ProductModel (JSON parsing)
│       │   └── repositories/   # ProductsRepositoryImpl
│       │
│       ├── domain/
│       │   ├── entities/       # Product (Pure Dart class)
│       │   ├── repositories/   # ProductsRepository (Interface)
│       │   └── usecases/       # GetProducts
│       │
│       └── presentation/
│           ├── cubit/          # ProductsCubit & ProductsState
│           ├── pages/          # ProductsPage
│           └── widgets/        # ProductItem
│
└── main.dart                   # Entry point
```

---

## 🚀 Getting Started

1.  **Clone the repository**
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run Code Generation** (Required for Freezed/JSON):
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the App**:
    ```bash
    flutter run
    ```

### Optional: Continuous Code Generation

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Linting and Formatting

- Analyze: `flutter analyze` (configured via `analysis_options.yaml:10`)
- Format: `dart format .`

### Testing

```bash
flutter test
```

Note: The default template test under `test/widget_test.dart` targets a counter app and may not reflect the current `Products` feature. Update tests as needed.

## 📝 Example Usage: Adding a New Feature

1.  Create a new folder in `lib/features/<feature_name>`.
2.  Create `domain`, `data`, and `presentation` subfolders.
3.  **Domain**: Define your `Entity`, then the `Repository` interface, then the `UseCase`.
4.  **Data**: Create `Model` (extending Entity), implement `DataSources`, and implement the `Repository`.
5.  **DI**: Register all new classes in a dependency container (e.g., `lib/features/<feature_name>/di/dependency.dart`).
6.  **Presentation**: Create `Cubit` (using the UseCase), then build your `Page`.
7.  **Routing**: Add the new page to `lib/core/routes/app_router.dart`.

---

## 🔎 Code Map (This Template)

- App bootstrap in `lib/main.dart:5-9` initializes DI (`lib/core/di/injection_container.dart:9`) and starts `MyApp`.
- Router configuration in `lib/core/routes/app_router.dart:7-17` uses `GoRouter` with `'/'` → `ProductsPage`.
- Dependency injection (`get_it`) setup in `lib/core/di/injection_container.dart:7-47` registers `Dio`, `Hive` box, and feature dependencies.
- Use case base contract in `lib/core/usecase/usecase.dart:4-6` with `NoParams` helper.
- Products feature state management:
  - Cubit: `lib/features/products/presentation/cubit/products_cubit.dart:11-18`
  - State (Freezed unions): `lib/features/products/presentation/cubit/products_state.dart:6-12`
- Data layer:
  - Remote API call: `lib/features/products/data/datasources/products_remote_data_source.dart:17-21` (FakeStore API)
  - Local cache TTL: `lib/features/products/data/datasources/products_local_data_source.dart:13` (1 hour)
  - Cache read/expiry logic: `lib/features/products/data/datasources/products_local_data_source.dart:27-47`
  - Repository orchestration: `lib/features/products/data/repositories/products_repository_impl.dart:16-33`
- Model ↔ Entity mapping: `lib/features/products/data/models/product_model.dart:21-23`

---

## 🌐 Routing Details

- `MaterialApp.router` is configured in `lib/main.dart:16-20` using `routerConfig: router`.
- `GoRouter` instance is defined in `lib/core/routes/app_router.dart:7`, initial route `'/'` renders `ProductsPage`.

---

## ⚙️ Error Handling Strategy

- Failures are explicit with `Either<Failure, T>` (fpdart) and domain `Failure` types (`lib/core/error/failures.dart:1-16`).
- Infrastructure exceptions are mapped to failures (`lib/core/error/exceptions.dart:1-9`).
- UI responds via Freezed states; errors surface through `ProductsState.error` (`lib/features/products/presentation/cubit/products_state.dart:11`).

---

## 🗃 Caching

- Hive box `products_cache` initialized in `lib/core/di/injection_container.dart:11-13`.
- Cached products JSON and metadata keys maintained in `lib/features/products/data/datasources/products_local_data_source.dart:11-13`.
- TTL enforced at 3600 seconds; expired cache triggers remote fetch fallback.

---

## 🔧 Troubleshooting

- If you see build errors for generated files, rerun:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Network errors from FakeStore API are converted to `ServerFailure`; on failure with no valid cache, the UI shows the error message.
