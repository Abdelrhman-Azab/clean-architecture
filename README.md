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
