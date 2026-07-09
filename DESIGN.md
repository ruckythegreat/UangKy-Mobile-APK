---
name: UangKy
description: Sharp, minimal personal finance notebook — ink structure, peach accent, numbers-first.
colors:
  peach: "#FFCC99"
  ink-primary: "#1C1917"
  ink-secondary: "#44403C"
  ink-muted: "#57534E"
  ink-focus: "#57534E"
  scaffold: "#F6F4F1"
  card: "#FFFFFF"
  surface-muted: "#ECE8E3"
  surface-glass: "#E6FFFFFF"
  border-soft: "#22000000"
  income-green: "#15803D"
  expense-red: "#B91C1C"
  chart-green: "#22C55E"
  chart-red: "#EF4444"
typography:
  display:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "28px"
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: "-0.5px"
  headline:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 800
    lineHeight: 1.25
    letterSpacing: "-0.3px"
  title:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: "normal"
  body:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: "normal"
  label:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "11px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "normal"
rounded:
  sm: "8px"
  md: "12px"
  lg: "14px"
  xl: "16px"
spacing:
  xs: "6px"
  sm: "8px"
  md: "12px"
  lg: "14px"
  xl: "16px"
  screen: "20px"
components:
  button-primary:
    backgroundColor: "{colors.ink-primary}"
    textColor: "{colors.peach}"
    rounded: "{rounded.lg}"
    padding: "14px 18px"
  button-primary-hover:
    backgroundColor: "{colors.ink-secondary}"
    textColor: "{colors.peach}"
    rounded: "{rounded.lg}"
    padding: "14px 18px"
  button-accent:
    backgroundColor: "{colors.peach}"
    textColor: "{colors.ink-primary}"
    rounded: "{rounded.lg}"
    padding: "14px 18px"
  card-default:
    backgroundColor: "{colors.card}"
    textColor: "{colors.ink-primary}"
    rounded: "{rounded.lg}"
    padding: "14px 16px"
  input-default:
    backgroundColor: "{colors.card}"
    textColor: "{colors.ink-primary}"
    rounded: "{rounded.lg}"
    padding: "14px 16px"
  nav-bottom:
    backgroundColor: "{colors.card}"
    textColor: "{colors.ink-muted}"
    rounded: "{rounded.lg}"
    height: "60px"
---

# Design System: UangKy

## 1. Overview

**Creative North Star: "The Pocket Notebook"**

UangKy should feel like a competent pocket notebook you trust with real money — not a gamified app, not a corporate bank portal, not a SaaS dashboard. The interface disappears into the task: log a transaction, check a balance, scan a chart, move on. Visual personality is sharp and minimal; warmth arrives through the peach accent on deliberate moments (primary actions, nav selection, brand logo), never through decorative scaffolding.

The system rejects generic SaaS finance aesthetics (cream hero metrics, gradient accents, eyebrow kickers, identical icon-card grids), gamified reward loops, cold institutional banking UI, and neon fintech energy. Hierarchy does the work — ink weight and spacing carry meaning before color does.

**Key Characteristics:**

- **Numbers-first** — balances and amounts use the heaviest type weights; decoration never competes with data.
- **Ink + peach pairing** — dark ink (`#1C1917`) structures the UI; peach (`#FFCC99`) accents selection and brand, not backgrounds.
- **Tonal flatness** — depth via surface steps (scaffold → card → ink panel), not shadow stacks.
- **Tactile confidence** — filled buttons, 14–16px corners, w700–w800 headings; controls feel pressable, not tentative.
- **Material 3 native** — system sans (Roboto / SF Pro), standard navigation and form patterns; familiarity earns trust.
- **Indonesian copy** — direct, precise labels; no English filler in primary flows.

## 2. Colors: The Pocket Ledger Palette

A restrained product palette: warm-neutral surfaces, ink structure, peach as the sole brand accent, semantic green/red for money direction only.

### Primary

- **Warm Peach Accent** (`#FFCC99`): Primary action labels on ink buttons, nav indicator tint, balance amounts on dark panels, brand logo moments. Used sparingly — if peach covers more than ~10% of a screen, pull back.
- **Ledger Ink** (`#1C1917`): Primary buttons, balance hero card background, selected nav icons, progress indicators, page titles. The authoritative voice of the system.

### Secondary

- **Stone Secondary** (`#44403C`): Section headers ("Buku", "Arus kas"), secondary emphasis text, hover state on ink buttons.
- **Warm Stone Muted** (`#57534E`): Subtitles, helper text, unselected nav labels. ≥4.5:1 on scaffold (`#F6F4F1`) and card.

### Tertiary

- **Income Forest** (`#15803D`): Positive amounts, income type selection, income chart bars. Pair with "+" prefix or "Pemasukan" label — never red/green alone for color-blind users.
- **Expense Brick** (`#B91C1C`): Negative amounts, expense type selection, error states. Distinct from chart red; used for semantic "outflow" not decoration.

### Neutral

- **Off-White Linen** (`#F6F4F1`): Scaffold / app background. Near-neutral with minimal chroma — not a saturated cream wash.
- **Pure Card** (`#FFFFFF`): Cards, inputs, bottom navigation bar.
- **Muted Surface** (`#ECE8E3`): `surfaceContainerHighest`, chart area backgrounds, subtle panel differentiation.
- **Glass List** (`#E6FFFFFF`): List row backgrounds (ledger items, transaction rows) — 90% white overlay for slight separation without a second card layer.
- **Soft Border** (`#22000000`): 13% black hairline on cards and inputs. Preferred over shadows for edge definition.

### Chart (data viz only)

- **Chart Green** (`#22C55E`) / **Chart Red** (`#EF4444`): `fl_chart` bar colors only. Do not use for UI chrome.

### Named Rules

**The Peach Accent Rule.** Peach appears on primary button labels (on ink), nav indicators, balance figures on dark panels, and brand moments. It is forbidden as a page background, gradient wash, or card fill.

**The One Ink Voice Rule.** Ledger Ink (`#1C1917`) is the single dark structural color. Do not introduce navy, charcoal gradients, or secondary dark hues.

## 3. Typography

**Display Font:** Roboto (Android) / SF Pro (iOS) / system-ui (web)
**Body Font:** Same family — one sans throughout
**Label/Mono Font:** None — data uses the body family at heavier weights

**Character:** Tight, confident, and utilitarian. Headings run w800 with slight negative tracking; body stays regular weight. No display/body pairing — the single family carries everything, matching product-register best practice.

### Hierarchy

- **Display** (w800, 28px / `headlineMedium`, line-height 1.2, -0.5px tracking): Splash screen app name only.
- **Headline** (w800, 22px / `titleLarge`, line-height 1.25, -0.3px tracking): Page titles — "Beranda", "Buku", "Jadwal", "Laporan", form screen titles.
- **Title** (w700, 14px / `titleSmall`, line-height 1.3): Section headers within a page — "Buku", "Arus kas", "Transaksi terakhir".
- **Body** (w400–w600, 14px / `bodyMedium`, line-height 1.5): Subtitles, descriptions, form helper text, transaction metadata. Prose blocks cap at 65–75ch when present.
- **Label** (w600, 11–12px / `labelSmall`, normal tracking): Form field labels, nav bar labels (11px), chart axis labels, version strings.
- **Data** (w700–w800, 14–26px): Currency amounts — `formatIdr()` output. Balance hero uses 26px w700 in peach on ink panel.

### Named Rules

**The Weight-Not-Size Rule.** Emphasis on numbers and headings comes from font weight (w700–w800), not oversized display type. Balance hero maxes at 26px; page titles stay at `titleLarge`.

**The System Sans Rule.** No custom font imports. Roboto / SF Pro / system-ui only. Display fonts in labels or data are prohibited.

## 4. Elevation

Depth is conveyed through **tonal layering**, not shadows. The surface stack reads: scaffold (`#F6F4F1`) → glass list rows (`#E6FFFFFF`) or card (`#FFFFFF`) → ink panel (`#1C1917`) for focal data. Borders (`#22000000` at ~90% opacity) define card edges at elevation 0.

The codebase sets `elevation: 0` on cards app-wide. One exception exists on the dashboard logo tile (soft ambient shadow, 6% ink, 12px blur) — treat this as legacy, not a pattern to spread. New surfaces ship flat.

### Shadow Vocabulary

No standard shadow vocabulary. Shadows are **not part of the design system**. If a focal element needs emphasis, use an ink panel, a border, or weight — not `box-shadow`.

### Named Rules

**The Flat-By-Default Rule.** Cards, inputs, and list rows are flat at rest. `elevation: 0` everywhere. Depth = surface color step + 1px border.

**The No-Gradient-Scaffold Rule.** The shell's peach-to-muted gradient wrapper is a known exception. New screens should not add decorative background gradients; the scaffold color alone is sufficient.

## 5. Components

Tactile and confident — controls feel pressable with filled backgrounds, generous padding, and consistent 14px corner radius.

### Buttons

- **Shape:** Gently rounded (14px / `rounded.lg`). Full-width on mobile for primary flows ("Catat transaksi", "Simpan").
- **Primary (ink):** Ledger Ink background (`#1C1917`), Warm Peach label (`#FFCC99`), w600 15px, padding 14×18px. Default for "Catat transaksi" FAB-area button and form submit.
- **Accent (peach):** Warm Peach background, Ledger Ink label and icon. Used inside the balance hero card ("Tambah catatan") — inverted polarity from primary.
- **Hover / Focus:** Ink buttons shift to Stone Secondary (`#44403C`). Material ripple on tap. No custom shadow on press.
- **Icon buttons:** `IconButton` with outlined Material icons (settings, back, delete). 22px nav icons.

### Chips / Segments

- **Type toggle (income/expense):** 16px radius tiles. Selected income → Income Forest fill; selected expense → Expense Brick fill; unselected → Glass List (`#E6FFFFFF`). w700 label.
- **SegmentedButton (chart range):** Material 3 `SegmentedButton` — 7h / 14h / 30h filters. Inherits theme colors.
- **ActionChip (ledger type suggestions):** 12px label in dialog; standard Material chip styling.

### Cards / Containers

- **Corner Style:** 14px (`rounded.lg`) standard; 16px (`rounded.xl`) for balance hero and transaction type tiles.
- **Background:** Pure Card (`#FFFFFF`) with Soft Border hairline. List rows use Glass List instead of nested cards.
- **Shadow Strategy:** None (see Elevation). Border-only edge definition.
- **Border:** `BorderSide(color: borderSoft @ 90% opacity)` — 1px.
- **Internal Padding:** 14–18px for content cards; 16px screen gutter.

### Inputs / Fields

- **Style:** Filled white background, 14px radius, Soft Border outline, 16×14px content padding.
- **Focus:** Border shifts to Warm Stone Focus (`#57534E`, 1.5px). No glow, no shadow.
- **Error:** Material error color = Expense Brick (`#B91C1C`). Field-level `errorText` on inputs and dropdowns; SnackBar only for secondary feedback (floating, 12px radius).
- **Labels:** `labelSmall` w800 above field groups in transaction form.

### Navigation

- **Bottom NavigationBar:** 60px height, Pure Card background, peach indicator at 65% opacity. Selected: Ledger Ink icon + label (11px w600). Unselected: Warm Stone Muted (`#57534E`). Four destinations: Beranda, Buku, Jadwal, Laporan.
- **AppBar:** Transparent, zero elevation, w800 title. Back arrow on pushed routes (settings, add transaction, ledger detail).
- **FAB pattern:** No floating FAB — "Catat transaksi" is a full-width `FilledButton` placed above the nav bar in `ShellScreen`.

### Balance Hero (signature component)

- **Container:** Ledger Ink (`#1C1917`) panel, 16px radius, 18px padding.
- **Label:** "Total saldo" — 13px peach at 88% opacity.
- **Amount:** 26px w700 Warm Peach — the most prominent number on the home screen.
- **CTA:** Accent peach button with ink icon/label inside the panel.

### Charts

- **Bar chart:** `fl_chart` BarChart with Chart Green / Chart Red bars. Muted surface background. Range selector via SegmentedButton.
- **Color-blind safety:** Bars labeled by date axis; do not rely on color alone to convey meaning.

## 6. Do's and Don'ts

### Do:

- **Do** use Ledger Ink (`#1C1917`) for primary actions and structural panels; peach only for accent labels, indicators, and brand moments.
- **Do** set `elevation: 0` on all cards and rely on surface color steps + 1px borders for depth.
- **Do** render currency amounts at w700–w800; the number is the hero, not the container around it.
- **Do** pair income/expense colors with text labels ("Pemasukan" / "Pengeluaran", +/- prefixes) for color-blind accessibility.
- **Do** keep corner radius consistent at 14px (16px for hero panels and type toggles only).
- **Do** use the full-width "Catat transaksi" button above the nav bar — never a floating FAB that obscures content.
- **Do** respect `prefers-reduced-motion`: crossfade or instant state changes, never gate content visibility on animation.

### Don't:

- **Don't** use generic SaaS finance dashboard patterns: cream/sand body backgrounds as the primary brand move, hero-metric card templates, gradient accents, small uppercase eyebrow kickers above every section, or identical icon+heading+text card grids.
- **Don't** gamify the UI — no coins, streaks, mascots, reward loops, or playful badges.
- **Don't** adopt corporate bank aesthetics — dense institutional tables, navy/gold palettes, cold formal copy.
- **Don't** use neon fintech styling — dark mode with electric accents, crypto-bro energy, glassmorphism cards.
- **Don't** spread peach as a background wash, gradient fill, or page tint. The shell gradient is a known exception, not a pattern to extend.
- **Don't** add side-stripe borders (`border-left` > 1px colored accent) on cards, list items, or alerts.
- **Don't** use gradient text (`background-clip: text`) for headings or amounts.
- **Don't** nest cards inside cards — use Glass List rows on the scaffold surface instead.
- **Don't** import custom display fonts or use fluid `clamp()` heading scales — fixed Material type scale only.
- **Don't** add decorative motion — transitions convey state (150–250ms), not page-load choreography.
