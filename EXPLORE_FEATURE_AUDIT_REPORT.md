# Larnity App: Explore Feature Technical Audit & Static UI Report

> **Target Directory**: `lib/src/features/explore`  
> **Date**: September 2026  
> **Audited By**: Antigravity Assistant  

---

## Executive Summary

The `explore` feature is intended as the primary discovery, search, onboarding, and notification hub for Larnity. While foundational scaffolding exists, the feature has significant discrepancies between data models, services, and the UI layer:
1. **Unconnected Backend Services**: A comprehensive Supabase notification data source exists (`NotificationDataSource`) with full CRUD and real-time streaming, but the corresponding Riverpod provider file is **empty (0 bytes)**, and the notification screen is **100% static/mocked**.
2. **Explore Screen Data Query Defect**: `ExploreScreen` queries only groups created by the *currently authenticated user* (`getGroupsByUser(userId: userId)`) rather than querying all public/explore groups from the database.
3. **Hardcoded / Mock UI Elements**: Multiple screens and widgets feature hardcoded member counts (`"1 Members"`, `"0 Members"`), hardcoded plan prices (`₹999`), stubbed payment buttons, placeholder share dialogs, and dead links.
4. **Dead / Sample Code**: `dummy_2.dart` is a stray 286-line file containing a standalone Flutter Quill sample application with its own `main()` entrypoint.

---

## File Structure Overview

```
lib/src/features/explore/
├── data/
│   ├── datasource/
│   │   └── notification_datasource.dart       # Supabase CRUD & real-time stream (Unused)
│   └── models/
│       └── notification_model.dart            # Notification data model & enums
├── domain/
│   └── category.dart                          # Hardcoded static list of 22 categories
├── presentation/
│   ├── provider/
│   │   └── notification_provider.dart         # EMPTY FILE (0 bytes)
│   ├── state/
│   │   ├── cubit/
│   │   │   └── explore_group_provider.dart    # Expansion state provider
│   │   └── state/
│   │       └── explore_group_state.dart       # State class (Redundant / Unused)
│   ├── view/
│   │   ├── explore_screen.dart                # Main explore feed & search
│   │   ├── group_details_screen.dart          # Group landing & mock payment sheet
│   │   ├── notification_screen.dart           # 100% Mocked notification list
│   │   └── dummy_2.dart                       # Dead code (Quill editor sample)
│   └── widgets/
│       ├── explore_groups_widget.dart         # Hero section, search bar, category chips
│       ├── group_card.dart                    # Group card in explore list
│       └── footer_widget.dart                 # Static footer with empty callbacks
```

---

## Detailed Audit: Services & Data Layer

### 1. `data/datasource/notification_datasource.dart`
- **Status**: Implemented with Supabase, but **completely disconnected** from UI.
- **Backend Table**: `Notifications`
- **Capabilities**:
  - `createNotification({required NotificationModel notification})`
  - `getNotificationsByUser({required String recipientId, ...})`
  - `getUnreadNotificationsByUser({required String recipientId})`
  - `getNotificationsByType({required String recipientId, required NotificationType type})`
  - `getGroupNotifications({required String recipientId, required String groupId})`
  - `markAsRead({required String notificationId})`
  - `markAllAsRead({required String recipientId})`
  - `getUnreadCount({required String recipientId})`
  - `deleteNotification({required String notificationId})`
  - `deleteAllNotifications({required String recipientId})`
  - `subscribeToUserNotifications(String recipientId)` (Real-time Supabase channel stream)
- **Issues**:
  - Neither `ExploreScreen`, `NotificationScreen`, nor `explore_nested_route.dart` invokes any of these methods.
  - No error handling or retry policies connected to user-facing feedback.

### 2. `presentation/provider/notification_provider.dart`
- **Status**: **Critical Bug / Incomplete File**.
- **File Size**: 0 bytes (completely empty).
- **Impact**: Any state management needed for notification feeds, unread badges, or real-time subscriptions has not been hooked into Riverpod.

### 3. `domain/category.dart`
- **Status**: **Static Data Source**.
- **Content**: Static Dart list of 22 categories (`List<Category> categories`) with hardcoded names and `HugeIcons` stroke icons.
- **Static vs Dynamic**: Categories are not synced with database taxonomy or categories existing on the `Group` table.

---

## Detailed Audit: Screen by Screen

---

### Screen 1: `ExploreScreen`
**File**: `lib/src/features/explore/presentation/view/explore_screen.dart`

#### Purpose
The central marketplace and discoverability screen for browsing communities and groups.

#### Dynamic Elements
- **Search filtering**: Client-side filtering by matching search text against `group.name`, `group.description`, and `group.category`.
- **Category filtering**: Filters cached groups when a category chip is tapped.
- **Group list rendering**: Renders a list of `GroupCard` widgets when groups are present.
- **Loading & Empty states**: Shows loading indicator and empty message.

#### Static / Broken / Hardcoded Elements
| Line # | UI Element / Code | Current Implementation | Issue & Action Needed |
|---|---|---|---|
| **Lines 43–48** | `didChangeDependencies` Data Fetch | `ref.read(groupProvider.notifier).getGroupsByUser(userId: userId);` | **Critical Defect**: Only fetches groups *owned* by the logged-in user! It fails to fetch public groups available to explore across the platform. |
| **Lines 106–108** | SliverAppBar expansion | `expandedHeight: isExpanded ? 1.5.sh : 0.6.sh` | Hardcoded screen-height proportion. Overflow risks on small device viewports. |
| **Lines 198–200** | Footer Widget | `// SliverToBoxAdapter(child: FooterWidget())` | Commented out; not rendered. |
| **Paging** | Pagination / Infinite Scroll | `filteredGroups[index]` | No backend pagination or limit/offset support; will fail at scale. |

---

### Screen 2: `GroupDetailsScreen`
**File**: `lib/src/features/explore/presentation/view/group_details_screen.dart`

#### Purpose
The public landing page for a selected group before a user joins or subscribes.

#### Dynamic Elements
- Reads `selectedGroup` from `groupProvider`.
- Displays dynamic group thumbnail, icon, group name, description, privacy (`Public`/`Private`), and monthly price.
- Dynamic CTA: Toggles between `"Enter Group"` (if user is creator/member) and `"Join from ₹{monthlyPrice}"` (if non-member).
- Dynamic URL slug link: `https://www.larnity.com/group/${selectedGroup.slug}`.

#### Static / Hardcoded / Mock Elements
| Line # | UI Element / Code | Current Implementation | Issue & Action Needed |
|---|---|---|---|
| **Line 166** | Member Count | `Text("1 Members", style: AppTextStyles.overLine())` | **Hardcoded string**: Always displays `"1 Members"`. Needs actual member count from `group_members` table. |
| **Line 195** | Creator Info | `Text(selectedGroup.userId ?? "Unknown Creator")` | **Raw UUID**: Renders the raw user UUID (e.g. `d7a31b...`) as the creator display name rather than fetching the creator's user profile name/avatar. |
| **Lines 249–256** | Share Button | `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share functionality would go here')))` | **Mock stub**: Does not trigger native sharing or copy-to-clipboard. |
| **Lines 329–353** | `_showPlanSelectionSheet` | `_showPaymentSheet(context, planName: 'Lifetime', amountINR: 999);` | **Hardcoded plan**: Hardcoded single plan `'Lifetime'`, amount `₹999`, and subtitle `'One-time payment, access forever'`, completely ignoring actual group subscription tiers. |
| **Lines 413–440** | Promo Code Section | `TextField` with `AppButton(label: 'Apply', onPressed: () {})` | **Static stub**: The `Apply` button has an empty callback `onPressed: () {}`. |
| **Lines 444–474** | Payment Gateway Selector | Toggles between `'Paymintro'` and `'Cashfree'` | UI state only; no gateway SDK initialization or checkout session creation. |
| **Lines 479–481** | Total Amount | `Text('₹${amountINR.toStringAsFixed(0)}')` | Hardcoded based on static `999` INR parameter. |
| **Lines 485–494** | Pay Securely Button | `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Redirecting to $method secure payment...')))` | **Fake action**: Only displays a SnackBar; does not integrate with Paymintro, Cashfree, or Razorpay SDKs. |

---

### Screen 3: `NotificationScreen`
**File**: `lib/src/features/explore/presentation/view/notification_screen.dart`

#### Purpose
Displays incoming user notifications, system updates, and group activity.

#### Dynamic Elements
- **None**: This screen is 100% static mock UI.

#### Static / Hardcoded / Mock Elements
| Line # | UI Element / Code | Current Implementation | Issue & Action Needed |
|---|---|---|---|
| **Line 55–57** | "Mark all as read" | Plain `Text("Mark all as read")` without `onTap` or `GestureDetector` | **Dead UI**: Visual button without any interaction or API trigger. |
| **Lines 59–89** | Filter Dropdown | `AppDropdown` with single hardcoded item `AppDropdownItem(value: "all", label: 'All Groups')` | **Static Filter**: Cannot filter by individual user groups or notification types. |
| **Line 138** | Notification List Count | `itemCount: 5` | **Hardcoded repetition**: Renders 5 duplicate cards. |
| **Lines 111–131** | Notification Card Content | - Title: `"🎉Group Created"`<br>- Body: `"You’ve successfully created the group \"sifat\"..."`<br>- Timestamp: `"5 days ago"`<br>- Group tag: `"in sifat"` | **Hardcoded test content**: Hardcoded strings referencing a specific developer test group (`"sifat"`). |
| **Lines 114–117** | Delete Notification Icon | `HugeIcon(icon: HugeIconsStrokeRounded.delete02, color: AppColors.red)` | **Dead UI**: No `onTap` / delete action handler. |
| **Integration** | Service Connection | No reference to `NotificationDataSource` | **Missing Integration**: Completely ignores existing Supabase data source. |

---

### Screen 4: `dummy_2.dart`
**File**: `lib/src/features/explore/presentation/view/dummy_2.dart`

#### Purpose & Audit Findings
- **Status**: **Unused / Dead Scratch Code** (286 lines).
- Contains a standalone `MainApp` with `void main() => runApp(const MainApp())`, an embedded `QuillSimpleToolbar`, and experimental delta JSON dumpers.
- Has no connection to the explore feature or router.
- **Recommendation**: Safe to delete.

---

## Detailed Audit: Shared Explore Widgets

### 1. `ExploreGroupsWidget`
**File**: `lib/src/features/explore/presentation/widgets/explore_groups_widget.dart`

- **Dynamic Aspects**:
  - Checks if user has an active package via `packageProvider` and `packageSubscriptionProvider`.
  - Dynamically updates primary CTA label: `"Manage your package"` vs `"Create your own group"`.
  - Reads and updates `groupProvider.selectedCategory`.
- **Static Aspects**:
  - Primary (first 5) and Secondary (remaining 17) category splitting is based on static compile-time constants in `category.dart`.
  - Header text and descriptions are static strings from `AppStrings`.

### 2. `GroupCard`
**File**: `lib/src/features/explore/presentation/widgets/group_card.dart`

- **Dynamic Aspects**:
  - Displays dynamic thumbnail, title, description, category, and lifetime price.
  - Tap navigates to `groupDetails` after setting `selectedGroup` in Riverpod.
- **Static Aspects**:
  - **Line 26**: `final memberCount = "0"; // This would come from actual data in a real implementation` — Hardcoded to `"0"`.
  - Fallback group icon (`Icons.group`) when image fails or is null.

### 3. `FooterWidget`
**File**: `lib/src/features/explore/presentation/widgets/footer_widget.dart`

- **Dynamic Aspects**: None.
- **Static Aspects**:
  - All legal links (Terms, Privacy Policy, Refund Policy, About Us, Contact Us, Listing Charges) have empty callbacks (`..onTap = () {}`).
  - Contact number (`AppStrings.supportNumber`) and Address are static text without dialing or map links.
  - Social media icons (Facebook, Twitter, Instagram, YouTube) are static without launch URLs.

---

## Associated Shell & Navigation Static References

**File**: `lib/src/core/router/view/explore_nested_route.dart`
- **Lines 81–89**: Notifications popover in AppBar has a static `"Mark all as read"` rich text with `..onTap = () {}`.
- **Line 124**: `"See all notifications(0)"` has hardcoded count `(0)`.
- **Lines 184–204**: EndDrawer has a hardcoded group dropdown item:
  ```dart
  AppDropdownItem(
    value: 'sifat',
    child: Row(children: [..., Text("Sifat")]),
  )
  ```
  This is hardcoded to a developer test account (`"sifat"`).

---

## Prioritized Action & Remediation Plan

| Priority | Component | Defect | Recommended Remediation |
|---|---|---|---|
| 🚨 **P0** | `ExploreScreen` | Only fetches current user's groups (`getGroupsByUser`) | Change fetch call to `getExploreGroups()` / `getPublicGroups()` in `GroupDataSource` and `GroupProvider`. |
| 🚨 **P0** | `notification_provider.dart` | File is empty (0 bytes) | Implement `NotificationNotifier` / `AsyncNotifier` consuming `NotificationDataSource`. |
| 🚨 **P0** | `NotificationScreen` | Entire screen is hardcoded mock data | Connect to `notification_provider` and display real user notifications with swipe-to-delete and mark-as-read. |
| 🟡 **P1** | `GroupDetailsScreen` | Hardcoded payment sheet (₹999) & static member count | Replace mock payment modal with dynamic tier selector and real payment gateway integration (Cashfree/Paymintro). Fetch real member count. |
| 🟡 **P1** | `GroupCard` | Member count is hardcoded to `0` | Add `memberCount` to `GroupModel` or aggregate count query in group datasource. |
| 🟢 **P2** | `explore_nested_route.dart` | Hardcoded group `"sifat"` in drawer | Populate drawer groups dynamically from `groupState.groups`. |
| 🟢 **P2** | `FooterWidget` | Stubbed onTap handlers | Integrate `url_launcher` to open external policy and contact links. |
| 🧹 **P3** | `dummy_2.dart` | Stray Quill sample file | Remove from project. |
