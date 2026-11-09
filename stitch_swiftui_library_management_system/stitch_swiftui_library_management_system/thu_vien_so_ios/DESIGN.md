---
name: Thu Vien So iOS
colors:
  surface: '#f9f9fe'
  surface-dim: '#d9dade'
  surface-bright: '#f9f9fe'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f8'
  surface-container: '#ededf2'
  surface-container-high: '#e8e8ed'
  surface-container-highest: '#e2e2e7'
  on-surface: '#1a1c1f'
  on-surface-variant: '#464554'
  inverse-surface: '#2e3034'
  inverse-on-surface: '#f0f0f5'
  outline: '#777586'
  outline-variant: '#c7c4d7'
  surface-tint: '#5148d7'
  primary: '#2a14b4'
  on-primary: '#ffffff'
  primary-container: '#4338ca'
  on-primary-container: '#c1beff'
  inverse-primary: '#c3c0ff'
  secondary: '#bb0112'
  on-secondary: '#ffffff'
  secondary-container: '#e02928'
  on-secondary-container: '#fffbff'
  tertiary: '#00451a'
  on-tertiary: '#ffffff'
  tertiary-container: '#005f26'
  on-tertiary-container: '#60dd7c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e3dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#100069'
  on-primary-fixed-variant: '#372abf'
  secondary-fixed: '#ffdad6'
  secondary-fixed-dim: '#ffb4ab'
  on-secondary-fixed: '#410002'
  on-secondary-fixed-variant: '#93000b'
  tertiary-fixed: '#7ffc97'
  tertiary-fixed-dim: '#62df7d'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005320'
  background: '#f9f9fe'
  on-background: '#1a1c1f'
  surface-variant: '#e2e2e7'
typography:
  large-title:
    fontFamily: Public Sans
    fontSize: 34px
    fontWeight: '700'
    lineHeight: 41px
    letterSpacing: 0.37px
  title-1:
    fontFamily: Public Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: 0.36px
  title-2:
    fontFamily: Public Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.26px
  title-3:
    fontFamily: Public Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 25px
    letterSpacing: -0.45px
  headline:
    fontFamily: Public Sans
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: -0.43px
  body:
    fontFamily: Public Sans
    fontSize: 17px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: -0.43px
  callout:
    fontFamily: Public Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 21px
    letterSpacing: -0.31px
  subheadline:
    fontFamily: Public Sans
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: -0.23px
  footnote:
    fontFamily: Public Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: -0.08px
  caption-1:
    fontFamily: Public Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0px
  caption-2:
    fontFamily: Public Sans
    fontSize: 11px
    fontWeight: '400'
    lineHeight: 13px
    letterSpacing: 0.07px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system targets administrative staff, librarians, and patrons using native iOS devices within a Vietnamese institutional context. The aesthetic is strictly rooted in modern Apple Human Interface Guidelines (HIG), synthesizing clean Cupertino native ergonomics with tailored library operations. The emotional tone is orderly, reassuring, authoritative, and frictionless.

The core visual style is **Corporate / Modern Cupertino**:
- Continuous rounded corners (`.continuous` corner curves) matching Apple hardware.
- Native multi-tier grouped styling with prominent visual differentiation between the system canvas, inset grouped cards, and raised modals.
- Authentic iOS navigation patterns: Large collapsible navigation titles transitioning smoothly to inline titles, native standard segmented controls, interactive action sheets, and detented modal bottom sheets (`.presentationDetents([.medium, .large])`).
- Pure Vietnamese localization throughout standard metadata, statuses, and contextual actions.

## Colors

The color architecture directly mirrors iOS system palettes while supporting specialized institutional circulation states:

- **Primary (`#4338CA`)**: Indigo 700. Drives primary actions, active tab items, key badge fills, and interactive navigation elements.
- **Secondary / Overdue (`#DC2626`)**: Critical red for "Quá hạn" (overdue books), punitive sanctions, and destructive actions.
- **Tertiary / Success (`#16A34A`)**: Balanced emerald green indicating "Đã trả" (returned), "Sẵn sàng" (available), and successful transaction/refund confirmations.
- **Warning / Financial (`#EA580C`)**: Dynamic burnt orange signaling "Tiền cọc" (security deposits), fine processing, or "Chờ xử lý" (pending reservations).
- **Neutral Canvas (`#F2F2F7`)**: iOS standard grouped background (`UIColor.systemGroupedBackground`), paired with pure `#FFFFFF` for grouped table rows and content cards.
- **Subtle Stroke & Separator (`#E5E5EA`)**: Standard iOS separator gray (`UIColor.separator`) used at hairline thicknesses (`0.5pt` or `1px`) for subtle card borders and list dividers.

## Typography

Typography relies on **Public Sans** to authentically emulate the optical metrics, diacritic balance, and structural density of Apple's San Francisco (SF Pro) type family, providing complete support for Vietnamese tone markers and accents (hỏi, ngã, nặng, sắc, huyền).

### Typographic Hierarchy & Application Rules
- **Large Title (34pt Bold)**: Used exclusively for top-level navigation screens (e.g., "Thư viện", "Mượn trả", "Độc giả") during resting scroll state.
- **Title 2 / Title 3 (20–22pt Semibold)**: Section headers, modal sheets, and circulation summary card titles.
- **Headline (17pt Semibold)**: Book titles in list rows, action sheet actions, and table view cell primary labels.
- **Body (17pt Regular)**: Reader information, metadata descriptions, and default inputs.
- **Subheadline (15pt Regular)**: Author names, publication years, and callout information.
- **Footnote / Caption 1 (12–13pt Medium)**: ISBN strings, Dewey decimal call numbers (DDC), status tags, and timestamps.

## Layout & Spacing

The layout follows Apple's standard Inset Grouped Table View conventions:
- **Canvas Margins**: Default `16pt` horizontal margin on compact devices (iPhone), scaling to `20pt` or centered column constraints (`672pt` max width) on iPad/regular widths.
- **Group Insets**: Content blocks, forms, and lists are wrapped in inset groups with `16pt` horizontal margins from the screen edge.
- **Vertical Spacing Rhythm**:
  - `space-xs (4pt)`: Micro gaps between badge text and status icons.
  - `space-sm (8pt)`: Vertical stacking between book title and author metadata.
  - `space-md (12pt)`: Padding inside list items, input fields, and compact status pills.
  - `space-lg (16pt)`: Standard content cell padding and group section headers.
  - `space-xl (24pt)`: Separation between disparate table groups or navigation control bars.

## Elevation & Depth

Visual hierarchy does not use diffuse Android-style drop shadows. Depth is achieved via **Tonal Layers and Native Inset Surfaces**:

1. **Base Tier (Level 0)**: `#F2F2F7` (System Grouped Background). The infinite background canvas.
2. **Surface Tier (Level 1)**: `#FFFFFF` (Secondary System Grouped Background). Inset grouped cards, list cells, search fields, and segmented control containers. Borders are rendered via a subtle `0.5pt` hairline stroke of `#E5E5EA`.
3. **Elevated Modal Tier (Level 2)**: `#FFFFFF` inside native modal bottom sheets (`UISheetPresentationController`) or floating dialogs. Includes an ambient, ultra-soft shadow: `Y: 10px`, `Blur: 24px`, `#000000` at 8% opacity.
4. **Chrome & Bars**: Translucent thin material backdrop blur (`.ultraThinMaterial`) applied to Navigation Bars and Tab Bars, permitting underlying catalog items to bleed through when scrolling.

## Shapes

The design system implements native Apple squircle geometry (`.continuous` corner curve):
- **Standard Cards and Inset Groups**: `12pt` to `16pt` continuous corner radius.
- **Buttons and Inputs**: `10pt` to `12pt` continuous corner radius.
- **Badges and Segmented Control Selectors**: Fully rounded or `8pt` continuous radius for segmented items.
- **Modal Sheets**: Native top-edge continuous curve (`16pt` to `20pt`).

## Components

### 1. Inset Grouped Cards & Table Views
- **Container**: White `#FFFFFF` surface placed on `#F2F2F7` with `12pt` continuous corners and a `0.5pt` border in `#E5E5EA`.
- **Row Dividers**: Inset `0.5pt` line starting at `16pt` from the left edge (or aligned with label text), leaving the right edge flush.
- **Selection State**: Instant native press highlight `#E5E5EA` at 60% opacity.

### 2. Segmented Controls
- **Track**: `#E5E5EA` background with `8pt` corner radius and `2pt` inner padding.
- **Active Segment**: White `#FFFFFF` thumb with subtle 4% black shadow and `6pt` corner radius.
- **Labels**: 13pt Semibold, transitioning from `#6B7280` to Indigo `#4338CA` when selected. Typical options: *"Tất cả"*, *"Đang mượn"*, *"Quá hạn"*, *"Đã lưu"*.

### 3. Native Buttons
- **Primary Action (SwiftUI `.borderedProminent`)**: Solid `#4338CA` background, `#FFFFFF` text, `12pt` continuous corner radius, `16pt` horizontal and `12pt` vertical padding.
- **Secondary Action (SwiftUI `.bordered`)**: Tinted `#EEF2FF` surface with `#4338CA` label.
- **Destructive Action**: `#DC2626` text or fill (e.g., *"Hủy phiếu mượn"*, *"Báo mất sách"*).

### 4. Status Chips & Badges
- **Quá hạn (Overdue)**: `#FEE2E2` fill, `#DC2626` text and border stroke.
- **Đã trả / Sẵn có (Returned / Available)**: `#DCFCE7` fill, `#16A34A` text.
- **Tiền cọc / Phí phạt (Deposit / Fee)**: `#FFEDD5` fill, `#EA580C` text.
- **Đang mượn (Borrowed)**: `#E0E7FF` fill, `#4338CA` text.

### 5. Input Fields & Search Bars
- **Cupertino Search Bar**: `#767680` at 12% opacity fill, `10pt` corner radius, integrated SF-style search glyph, and placeholder *"Tìm kiếm theo tên sách, tác giả hoặc mã ISBN..."*.
- **Form Fields**: Clean tabular rows inside grouped tables with right-aligned values or inline editing fields.

### 6. Modal Bottom Sheets & Action Sheets
- **Detented Sheet**: Rounded top sheet with native drag indicator (`Capsule` measuring `36pt × 5pt` in `#D1D5DB`).
- **Action Sheet**: Standard iOS action popover for quick operations: *"Gia hạn sách"*, *"Xác nhận trả sách"*, *"In phiếu mượn"*.