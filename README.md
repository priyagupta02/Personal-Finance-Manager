# Personal Finance Manager

A production-grade personal finance manager built with **Flutter** and the
**BLoC** state-management pattern, following **Clean Architecture**.

> Status: ✅ All 10 core screens implemented · 52 tests passing · analyzer clean.

## Project Overview

Personal Finance Manager helps users track income and expenses, manage budgets
and subscriptions, scan receipts with OCR, and understand their spending through
analytics — all in a scalable, well-tested Flutter codebase. Data is persisted
locally (Hive + secure storage), and the architecture is backend-agnostic so a
real API can be dropped in without touching the UI.

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
│   └── utils/              # Validators, currency formatter, id generator
└── features/               # One folder per feature:
    └── <feature>/
        ├── data/           # datasources, models, repository implementations
        ├── domain/         # entities, repository contracts, use cases
        └── presentation/   # BLoCs/Cubits, pages, widgets
```

Features: `splash`, `auth`, `home`, `transactions`, `budgets`, `analytics`,
`receipt_scanner`, `subscriptions`, `settings`.

**Data flow:** `Presentation (BLoC/Cubit)` → `UseCase` → `Repository (contract)`
→ `Repository impl` → `DataSource`. Errors surface as `Either<Failure, T>`
(via `dartz`), so the UI handles failures without try/catch. BLoC is used for
event-driven flows (auth, transaction list); Cubit for simpler state machines
(splash, home, budgets, analytics, settings).

### Key packages

| Concern              | Package                                   |
| -------------------- | ----------------------------------------- |
| State management     | `flutter_bloc`, `bloc`                    |
| Value equality       | `equatable`                               |
| Dependency injection | `get_it`                                  |
| Navigation           | `go_router`                               |
| Functional errors    | `dartz`                                   |
| Local storage        | `hive` / `hive_flutter`                   |
| Secure storage       | `flutter_secure_storage`                  |
| Env config           | `flutter_dotenv`                          |
| Charts               | `fl_chart`                                |
| Images               | `image_picker`, `flutter_image_compress`  |
| OCR                  | `google_mlkit_text_recognition`           |
| Sharing / export     | `share_plus`                              |
| Debounce (search)    | `stream_transform`                        |
| Hashing              | `crypto`                                  |
| Formatting / i18n    | `intl`                                    |
| Testing              | `bloc_test`, `mocktail`                   |

## Features

All 10 required screens are implemented:

- [x] **Splash** — animated fade-in logo, version display, auth-based routing
- [x] **Authentication** — login/register, real-time validation, password
      visibility toggle, Remember Me, forgot-password flow (Google sign-in
      button present, pending Firebase config)
- [x] **Home Dashboard** — balance/income/expense/savings cards, quick actions,
      monthly spending chart, recent transactions (pull-to-refresh), budget
      overview
- [x] **Transaction List** — infinite scroll pagination, filters (date range,
      category, type, payment method), sort, debounced search, swipe to
      edit/delete, empty states
- [x] **Add/Edit Transaction** — currency amount input, category dropdown,
      date & time picker, payment method, notes, receipt attach with
      compression, tags, recurring toggle, real-time validation, draft save
- [x] **Budget Management** — per-category budgets, weekly/monthly limits,
      alert thresholds (50/75/90%), budget-vs-actual, rollover, spent-vs-
      remaining chart
- [x] **Analytics Dashboard** — expense pie, income-vs-expense line, monthly
      comparison bar, category-over-time, date-range selector, top categories,
      insights
- [x] **Receipt Scanner (OCR)** — camera/gallery capture, on-device OCR,
      amount/date/merchant/category extraction, manual correction, save
- [x] **Subscription Manager** — recurring subscriptions, billing cycles,
      next-billing dates, auto-renewal, calendar of upcoming payments, monthly
      total, in-app renewal reminders
- [x] **Profile & Settings** — profile + edit, theme toggle (light/dark),
      currency selection, notification preferences, biometric toggle, export
      all data, about/privacy, logout

### Bonus / not yet implemented
- Google sign-in (UI present; needs Firebase configuration)
- OS-level local notifications (in-app reminders provided instead)
- Biometric enforcement (`local_auth`) — preference toggle is persisted
- Language / i18n
- PDF/CSV report export (JSON export is implemented)
- SSL pinning, real-time exchange rates, gamification, CSV import

## Setup Instructions

### Prerequisites
- Flutter SDK **3.38.x** (stable), Dart **3.10.x**
- Android Studio / Xcode for a device or emulator

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

The app seeds realistic demo data (transactions, budgets, subscriptions) on
first launch so every screen has content immediately. Register any email/
password to sign in — authentication runs against a local, offline store.

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
flutter test                     # run all tests (52 tests)
flutter test --coverage          # with coverage → coverage/lcov.info
```

### Coverage

The test suite focuses on **business logic** — BLoCs/Cubits, repository query
logic, and the pure receipt parser — rather than pixel-level widget tests.

| Scope                                        | Line coverage |
| -------------------------------------------- | ------------- |
| Logic layer (bloc/cubit + domain + data)     | **~50%**      |
| Overall (including all UI widgets/pages)     | **~27%**      |

Use cases, cubits, and the receipt parser sit at **90–100%**. To view a browsable
HTML report (requires `lcov`):

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Building the APK

```bash
flutter build apk --debug        # build/app/outputs/flutter-apk/app-debug.apk
# or a release build:
flutter build apk --release
```
`minSdkVersion` is 21 (required by ML Kit). ML Kit adds native dependencies, so
the APK is larger than a bare Flutter app.

## Testing Strategy

- **Cubit/BLoC tests** (`bloc_test`) for every stateful feature: splash routing,
  auth (login/register/logout/errors), home aggregation, transaction list
  (pagination, debounced search, delete), add/edit (submit, draft, receipt),
  budgets (period spend, rollover, thresholds), analytics (breakdown, ranges),
  subscriptions (calendar occurrences, totals), settings (persistence).
- **Pure logic tests**: the receipt parser and the transaction query/filter/
  sort/pagination in the repository.
- **Fakes over mocks** where it exercises more real behavior (in-memory repos);
  `mocktail` for boundaries like secure storage.

## Known Issues / Limitations
- Authentication is a local, offline store (salted SHA-256) — no real backend.
- Changing currency updates formatting on the next screen build (already-open
  screens refresh on their next load).
- Google sign-in, OS notifications, biometric enforcement, and i18n are
  deferred (see Bonus above).

## Screenshots / GIFs
_Add screenshots or a short screen recording here before submission._

<!-- Example:
| Dashboard | Analytics | Budgets |
| --- | --- | --- |
| ![](docs/dashboard.png) | ![](docs/analytics.png) | ![](docs/budgets.png) |
-->

## Contributing Workflow

`main` is the stable branch. Work happens on short-lived branches merged via
Pull Request:

- `feat/<name>` — new feature
- `fix/<name>` — bug fix
- `chore/<name>` — tooling/config/docs
- `test/<name>` — tests only

Commits follow **Conventional Commits** (`feat:`, `fix:`, `chore:`, `test:`,
`docs:`, `refactor:`).
