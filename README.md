# Bachelor Buddy 🏠📱

> **Your all-in-one personal life manager** — tailored specifically for bachelors, young professionals, and roommates. Track daily expenses, split bills, automate tiffin confirmations, manage tasks with smart intent automations, and stay hydrated with Android Home Screen widgets.

---

## 🌟 Features

### 1. Expense Tracker & Roommate Splits
- **Strict Integer Arithmetic**: All transactions stored in integer **paise** (1 ₹ = 100 paise) preventing floating-point rounding errors.
- **Indian Numbering System**: Formatted with standard comma separations (`₹1,25,000.00`).
- **Dynamic Category Tracking**: Seeded with default categories (*Food, Tiffin, Rent, Travel, Groceries, Utilities, Recharge, Entertainment, Health, Shopping, Salary, Freelance*), plus custom categories.
- **Swipe-to-Delete with Undo**: Instantly delete with SnackBar undo restoration.
- **Roommate Split Tagging**: Categorize shared apartment costs.
- **CSV Export**: Export transactions directly to CSV for spreadsheets or WhatsApp sharing.

### 2. Tiffin Tracker with Auto-Expense Integration
- **Meal Plans**: Define breakfast, lunch, or dinner plans with vendor name, price per meal, active days, and daily reminder times.
- **Interactive Daily Status**: Confirm meal delivery (`Received` / `Skip` / `Pending`).
- **Automatic Expense Synchronization**:
  - Marking a meal **Received** automatically logs an expense under the *Tiffin* category with a `⚡ Auto` badge and links directly to the tiffin log.
  - Marking **Skipped** removes the charge and deletes the linked transaction if previously marked received.
- **Monthly Billing Overview**: Real-time aggregation of total meals received, skipped, and total vendor bill in ₹.

### 3. Smart To-Do List with Action Automations
- **Live Keyword & Intent Parser**: As you type tasks like *"Buy groceries for ₹450"*, the app automatically parses the amount (`45000 paise`) and category (`Groceries`).
- **One-Tap Action Execution**: When the task is checked complete, `ActionRunner` executes the registered action, automatically creating the expense without manual data entry.
- **Recurring Tasks**: Supports `Daily`, `Weekly`, and `Monthly` recurrence with automatic next-instance scheduling.
- **Priorities & Due Dates**: High, Medium, Low priorities with smart overdue indicators.

### 4. Hydration & Water Reminder
- **Visual Progress Ring**: Daily intake vs target (e.g. 1,600 / 2,500 ml).
- **Quick Logging**: `+1 Glass` (configurable glass size e.g. 200ml) and `+500ml Bottle` buttons.
- **7-Day History Chart**: Visual streak tracker.
- **Daytime Scheduled Notifications**: Smart reminders between configurable active hours (`07:00` to `22:00`).

### 5. Budget Planner & Recurring Bills
- **Overall & Category Limits**: Set monthly caps and track linear progress bars (Green <75%, Amber 75-90%, Red >90%).
- **Safe-to-Spend Per Day**: Dynamically computes `(Monthly Limit - Total Spent) / Days Left in Month`.
- **Spending Distribution**: Interactive pie charts via `fl_chart`.
- **Recurring Expenses**: Auto-generate monthly recurring bills (Rent, WiFi, Subscriptions) on their scheduled day.

### 6. Android Home Screen Widgets
- Powered by `home_widget` with native Android `RemoteViews`:
  1. **Tiffin Widget**: View today's meal status with instant `Received` / `Skip` interactive buttons.
  2. **Water Widget**: Live hydration progress with direct `+1 Glass` button.
  3. **Tasks Widget**: Top pending tasks due today.
  4. **Budget Widget**: Monthly budget meter with safe-to-spend allowance.
  5. **Quick-Add Expense Widget**: One-tap expense presets (Chai ₹20, Meal ₹100, Custom).

---

## 🏗 Architecture & Tech Stack

- **Framework**: Flutter 3.47+ (Dart 3.13+)
- **Architecture**: Clean Feature-First Architecture (Data / Domain / UI)
- **State Management**: `flutter_riverpod` (v2.6+)
- **Database**: `drift` with SQLite (WAL mode, foreign keys enabled, typed DAOs and reactive queries)
- **Navigation**: `go_router` with shell routing and deep links
- **Event Bus**: Typed in-memory domain event bus (`DomainEvent`) ensuring decoupled cross-feature effects
- **Action Pipeline**: `IntentParser` -> `ActionIntent` -> `ActionRegistry` -> `ActionRunner`
- **Widgets**: `home_widget` with Android `AppWidgetProvider` native layouts
- **Notifications**: `flutter_local_notifications` with timezone support

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24+ installed and added to `PATH`
- Android Studio / VS Code with Flutter extension

### Installation & Run
```bash
# Clone the repository
cd bachelor_buddy

# Install dependencies
flutter pub get

# Generate Drift database models
dart run build_runner build --delete-conflicting-outputs

# Run unit and widget tests
flutter test

# Run the app on your connected device or emulator
flutter run
```

---

## 🧪 Testing & Validation
All unit and widget test suites can be executed with:
```bash
flutter test
```
Verification passes with **0 analyzer warnings or errors**:
```bash
flutter analyze
```
