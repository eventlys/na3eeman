# Na3eeman flutter i18n & RTL Localization Plan

## 1. Initial Analysis
- **Current State:** The flutter project uses a mix of `easy_localization` (seen in `pubspec.yaml` and `main.dart` with `assets/Lang/*.json` files) and some custom getx-based localization `AppLocalization` in `lib/Language/config/config_lang.dart`. 
- **Hardcoded Strings:** Nearly ~470 hardcoded text widgets across the application (`lib/Packages/...`).
- **Directionality:** Currently no extensive RTL wrapping. 
- **Goal:** To convert the entire architecture to use the official `flutter_localizations` & `intl` packages with `.arb` files, ensuring RTL (Right-to-Left) rendering and culturally appropriate Arabic translations. Backend modifications will be applied to APIs sending text.

## 2. Implementation Sub-steps

### Phase A: Core Setup & Dependency Configuration
1. Update `pubspec.yaml` to ensure `flutter_localizations` and `intl` are present, and enable `generate: true`.
2. Add `l10n.yaml` at the root folder to configure the code generation.
3. Remove conflicting packages if possible (`easy_localization`, `get` localization mappings) to standardize on `AppLocalizations`.
4. Create `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.
5. Update `main.dart` to register the new `localizationsDelegates` and set `ar` as the primary locale.

### Phase B: Iterative Extraction & Translation
Since there are hundreds of strings, extraction will be staggered starting from the most critical user journeys:
1. **Core Navigation & App Layouts:** Sidebar, generic headers, common buttons.
2. **Dashboards (Admin & Intern):** Metrics, KPIs, Section headers.
3. **Authentication:** Login, Signup, OTP.
4. **Shops & Appointments:** Shop lists, map views, appointment details.
5. **Backend Responses:** Inspect DRF error messages and make them translatable (Django `ugettext_lazy` / `gettext_lazy`).

### Phase C: RTL and UI Refactoring
1. **Directionality:** Ensure `MaterialApp` correctly injects RTL properties.
2. **Padding/Margin:** Convert `margin: EdgeInsets.only(left: X, right: Y)` to `EdgeInsetsDirectional.only(start: X, end: Y)`.
3. **Icons:** Apply `matchTextDirection: true` for arrows (`Icons.arrow_forward`, `Icons.push_pin`).
4. **Typography:** Verify that Google Fonts (or system fonts) support Arabic correctly (Cairo or Almarai fonts).

### Phase D: Testing & Validation
- Run the Flutter tests and visually check the alignment of components (e.g., Monthly Targets flex grids).
- Confirm API errors render in Arabic on the frontend screen based on `Accept-Language` headers.

---

**Execution:** We will start with *Phase A*, configuring the root mechanics, creating `.arb` files, modifying `main.dart`, and then slowly swapping strings starting with the newly created `AdminDashboardPage` and `InternDashboard`.
