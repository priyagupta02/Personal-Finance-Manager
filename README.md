# Personal Finance Manager

A production-grade personal finance manager built with **Flutter** and the
**BLoC** state-management pattern, following **Clean Architecture**.

> Status: 🚧 In active development. This README is updated as features land.

## Project Overview

Personal Finance Manager helps users track income and expenses, manage budgets
and subscriptions, scan receipts, and understand their spending through
analytics — all in a scalable, well-tested Flutter codebase.

## Architecture

The project uses **feature-first Clean Architecture** with three layers per
feature, keeping business logic independent of Flutter and easy to test.

```
lib/
├── app/                    # Root widget + global BLoC observer
├── core/                   # Cross-cutting concerns (shared by all features)
│   ├── config/             # Environment configuration (.env access)
│   ├── constants/          # App-wide constants & storage keys
│   ├── di/                 # Dependency injection (get_it service locator)
│   ├── error/              # Failures (domain) & Exceptions (data)
│   ├── router/             # Navigation (go_router) + route definitions
│   ├── theme/              # Light/Dark themes, colors
│   ├── usecase/            # Base UseCase contract
│   ├── utils/              # Reusable helpers (validators, ...)
│   └── widgets/            # Shared widgets
└── features/               # One folder per feature:
    └── <feature>/
        ├── data/           # datasources, models, repository implementations
        ├── domain/         # entities, repository contracts, use cases
        └── presentation/   # BLoCs, pages, widgets
```

**Data flow:** `Presentation (BLoC)` → `UseCase` → `Repository (contract)` →
`Repository impl` → `DataSource`. Errors surface as `Either<Failure, T>`
(via `dartz`), so the UI handles failures without try/catch.

### Key packages

| Concern              | Package                      |
| -------------------- | ---------------------------- |
| State management     | `flutter_bloc`, `bloc`       |
| Value equality       | `equatable`                  |
| Dependency injection | `get_it`                     |
| Navigation           | `go_router`                  |
| Functional errors    | `dartz`                      |
| Local storage        | `hive`, `shared_preferences` |
| Secure storage       | `flutter_secure_storage`     |
| Env config           | `flutter_dotenv`             |
| Formatting / i18n    | `intl`                       |
| Testing              | `bloc_test`, `mocktail`      |

## Features

### Implemented
- [x] Project foundation: Clean Architecture scaffold, DI, theming
      (light/dark), routing, environment config, error handling.

### Planned
- [ ] Splash screen (animated logo, auth-based routing)
- [ ] Authentication (login/register, validation, remember me, forgot password)
- [ ] Home dashboard (summary cards, charts, recent transactions)
- [ ] Transaction list (pagination, filters, search, swipe actions)
- [ ] Add/Edit transaction (receipt attach, tags, recurring)
- [ ] Budget management
- [ ] Analytics dashboard (charts, insights)
- [ ] Receipt scanner (OCR)
- [ ] Subscription manager
- [ ] Profile & settings

## Setup Instructions

### Prerequisites
- Flutter SDK **3.38.x** (stable), Dart **3.10.x**
- Android Studio / Xcode for device or emulator

### Steps
```bash
# 1. Clone
git clone https://github.com/priyagupta02/Personal-Finance-Manager.git
cd Personal-Finance-Manager

# 2. Configure environment
cp .env.example .env      # then edit values as needed

# 3. Install dependencies
flutter pub get

# 4. Run
flutter run
```

## Environment Variables

Copy `.env.example` to `.env` (git-ignored — never commit real secrets):

| Variable               | Description                                  |
| ---------------------- | -------------------------------------------- |
| `APP_NAME`             | Display name of the app                      |
| `APP_ENV`              | `development` / `production`                 |
| `API_BASE_URL`         | Base URL for the backend API                 |
| `API_TIMEOUT_MS`       | Network request timeout in milliseconds      |
| `GOOGLE_WEB_CLIENT_ID` | Google Sign-In web client id (bonus feature) |

## Running Tests

```bash
flutter test                     # run all tests
flutter test --coverage          # with coverage → coverage/lcov.info
```

## Known Issues / Limitations
- Feature screens are being implemented incrementally; routes not yet built
  resolve to a placeholder page.

## Contributing Workflow

`main` is the stable branch. Work happens on short-lived branches merged via
Pull Request:

- `feat/<name>` — new feature
- `fix/<name>` — bug fix
- `chore/<name>` — tooling/config
- `test/<name>` — tests only

Commits follow **Conventional Commits** (`feat:`, `fix:`, `chore:`, `test:`,
`docs:`, `refactor:`).
