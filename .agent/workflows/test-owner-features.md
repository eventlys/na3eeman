---
description: how to test owner features using the dev switcher
---

This workflow describes how to test different subscription tiers and owner account types using the built-in Developer Account Switcher.

### Prerequisites
1. Ensure the app is running in **Debug Mode** (`kDebugMode` must be true).
2. Navigate to the **Owner Dashboard**.

### Workflow Steps

1. **Locate the Dev Switcher Button**
   - In debug mode, a red floating action button with a developer icon ( ⚙️ ) will appear at the bottom right of the Owner Dashboard.

2. **Open the Account Switcher**
   - Tap the red button to reveal the mock account options.

3. **Choose a Mock Profile**
   - Select one of the variants:
     - **Male Salon Owner (Empire)**: High-tier enterprise features.
     - **Female Salon Owner (Elite)**: Premium features.
     - **Male Freelancer (Artisan)**: Free/Basic features.
     - **Expired Subscription**: Test the renewal banner and gated access UI.

4. **Verify UI Changes**
   - Observe how the **Subscription Banner** changes (Renewal Warning vs Expired vs None).
   - Check the **Quick Actions** and **Dynamic Widgets** (different tiers show different tools).
   - Open the **Subscription Details Modal** (tap the banner) to see the mock tier details.

5. **Test Feature Gating**
   - Try accessing gated features (e.g., Campaigns or Staff Management) under different tiers to ensure the `OwnerProvider` correctly handles access logic.

### Troubleshooting
- If the button doesn't appear, ensure you are in the `OwnerDashboardPage` and `kDebugMode` is active.
- If data doesn't update, verify that `AuthProvider` is correctly notifying listeners after a debug switch.
