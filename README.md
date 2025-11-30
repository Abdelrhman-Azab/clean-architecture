# Clean Architecture Starter Project for Flutter

This project is a robust, production-ready template for building scalable Flutter applications using **Clean Architecture** and the **Feature-First** organizational strategy. It comes pre-configured with a modern tech stack to ensure testability, maintainability, and separation of concerns.

## 🏗 Architecture Overview

The architecture follows the **Separation of Concerns** principle, dividing the application into three independent layers per feature. The **Dependency Rule** is strictly enforced: dependencies only point inwards. Inner layers (Domain) know nothing about outer layers (Data, Presentation).

### 1. Domain Layer (The Core)
*   **Role**: Contains pure business logic and enterprise rules.
*   **Dependencies**: None. It is platform-agnostic (pure Dart).
*   **Components**:
    *   **Entities**: Immutable business objects (e.g., `Product`).
    *   **UseCases**: Encapsulate specific business actions (e.g., `GetProducts`). They act as the entry point to the domain.
    *   **Repository Interfaces**: Abstract contracts defining *what* data operations are available, without specifying *how* they are implemented.

### 2. Data Layer (The Infrastructure)
*   **Role**: Handles data retrieval, storage, and transformation.
*   **Dependencies**: Domain Layer, External Libraries (Dio, Hive).
*   **Components**:
    *   **Models**: Data Transfer Objects (DTOs) that extend Entities. They handle JSON serialization/deserialization.
    *   **Data Sources**:
        *   *Remote*: Handles API communication (REST, GraphQL).
        *   *Local*: Handles device storage (Database, Cache).
    *   **Repository Implementations**: Concrete classes that implement the Domain Repository interfaces. They orchestrate data flow (e.g., "Check cache; if empty, fetch from API and save to cache").

### 3. Presentation Layer (The UI)
*   **Role**: Renders the UI and handles user interaction.
*   **Dependencies**: Domain Layer.
*   **Components**:
    *   **State Management (Cubit)**: Manages the state of the view. It calls UseCases and emits States.
    *   **Pages & Widgets**: Dumb components that listen to state changes and render the UI.

---

## 🛠 Tech Stack & Benefits

We carefully selected libraries that enforce best practices and reduce boilerplate.

### Core
*   **[flutter_bloc](https://pub.dev/packages/flutter_bloc)**: The industry standard for state management.
    *   *Benefit*: Separates business logic (Cubit/Bloc) from UI (Widgets). predictable state changes and easy testing.
*   **[go_router](https://pub.dev/packages/go_router)**: A declarative routing package.
    *   *Benefit*: Simplifies deep linking, nested navigation, and redirection logic compared to the standard Navigator.
*   **[get_it](https://pub.dev/packages/get_it)**: A Service Locator for Dependency Injection.
    *   *Benefit*: Decouples classes. You request an abstract interface (e.g., `ProductsRepository`), and `get_it` provides the concrete implementation.

### Data & Networking
*   **[dio](https://pub.dev/packages/dio)**: A powerful HTTP client for Dart.
    *   *Benefit*: Supports interceptors (for logging/auth), global configuration, and cancellation tokens.
*   **[hive](https://pub.dev/packages/hive)**: A lightweight, key-value database.
    *   *Benefit*: Extremely fast and synchronous local caching.
*   **[internet_connection_checker](https://pub.dev/packages/internet_connection_checker)**: Checks for internet connectivity.
    *   *Benefit*: Allows the app to robustly switch between Remote and Local data sources.

### Functional & Type Safety
*   **[freezed](https://pub.dev/packages/freezed)**: Code generation for immutable classes and unions.
    *   *Benefit*: Provides `copyWith`, `toString`, `==` override, and Pattern Matching (Sealed Classes) out of the box. Essential for safe State management.
*   **[fpdart](https://pub.dev/packages/fpdart)**: Functional programming types.
    *   *Benefit*: We use `Either<Failure, Success>` for error handling. This forces the developer to handle both success and failure cases, eliminating runtime exceptions.

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

## 📝 Example Usage: Adding a New Feature

1.  Create a new folder in `lib/features/<feature_name>`.
2.  Create `domain`, `data`, and `presentation` subfolders.
3.  **Domain**: Define your `Entity`, then the `Repository` interface, then the `UseCase`.
4.  **Data**: Create `Model` (extending Entity), implement `DataSources`, and implement the `Repository`.
5.  **DI**: Register all new classes in a dependency container (e.g., `lib/features/<feature_name>/di/dependency.dart`).
6.  **Presentation**: Create `Cubit` (using the UseCase), then build your `Page`.
7.  **Routing**: Add the new page to `lib/core/routes/app_router.dart`.
