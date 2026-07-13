# Tracker

Tracker is an iOS habit and event tracking app. Users can create trackers, assign schedules, mark completion by date, organize trackers into categories, filter and search them, and view statistics.

## Overview

The project is a UIKit app with custom collection/table UI, CoreData persistence, localization, onboarding, dark theme support, and analytics.

## Features

- Onboarding
- Main tracker screen
- Create trackers and categories
- Edit existing trackers
- Select schedule days
- Select emoji and color
- Mark tracker completion
- Prevent completion for future dates
- Date-based tracker filtering
- Search by tracker name
- Filter screen
- Statistics screen
- Dark theme support
- Russian and English localization
- AppMetrica analytics
- Snapshot test target

## Tech Stack

- Swift
- UIKit
- CoreData
- MVVM elements for category flow
- UICollectionView
- UITableView
- UserDefaults
- AppMetrica
- XCTest

## Architecture

The project separates persistence, screens, models, and analytics:

```text
tracker/
├── Tracker/
│   ├── Analytic/       # Analytics service
│   ├── CoreData/       # Stores, stack, dependencies
│   ├── Helpers/        # Models, settings, date helpers
│   ├── Onboarding/     # Onboarding flow
│   ├── Statistic/      # Statistics screen and service
│   ├── TabBar/         # Main tab bar
│   └── Tracker/        # Tracker screens and creation flow
└── TrackerTests/       # Tests
```

## Key Implementation Details

- `TrackerStore`, `TrackerCategoryStore`, and `TrackerRecordStore` wrap CoreData access.
- `Dependencies` creates shared services for screens.
- `TrackerViewController` displays trackers for the selected date.
- `NewTrackerViewController` manages tracker creation with schedule, emoji, and color selection.
- `EditTrackerViewController` reuses creation logic for editing.
- `FilterService` and `FiltersViewController` handle tracker filtering.
- `StatisticService` calculates completed tracker metrics.
- `AnalitycService` sends screen and click events.

## Getting Started

1. Open `tracker/Tracker.xcodeproj` in Xcode.
2. Select the app scheme.
3. Run on an iPhone simulator.

## Repository

[github.com/shogassxzp/tracker](https://github.com/shogassxzp/tracker)
