# CFPV — Design Phase

> **Project:** CFPV (Cross-Platform Food & Beverage Application)
> **Status:** Draft Design
> **Design System Source:** DESIGN.md (Starbucks-inspired)
> **Specification Source:** specs/specification-phase.md

---

## Table of Contents

1. [Design Overview & Model](#1-design-overview--model)
2. [Screen Flow Diagram](#2-screen-flow-diagram)
3. [Splash & Auth Screens](#3-splash--auth-screens)
4. [Onboarding Screen](#4-onboarding-screen)
5. [Tab-Root Screens](#5-tab-root-screens)
6. [Product Screens](#6-product-screens)
7. [Order Screens](#7-order-screens)
8. [Profile Sub-Screens](#8-profile-sub-screens)
9. [Component Library](#9-component-library)
10. [Micro-Interactions & Animations](#10-micro-interactions--animations)
11. [Design Tokens Summary](#11-design-tokens-summary)

---

## 1. Design Overview & Model

### 1.1 Design Identity

CFPV follows a **Warm Café** visual identity inspired by the Starbucks design system. The app communicates warmth, premium simplicity, and approachability through:

- **Warm cream canvas** (`#f2f0eb`) instead of cold white — gives the entire app a café-atmosphere warmth
- **Four-tier green system** — each green serves a distinct surface role, never interchangeable
- **Full-pill buttons** — 50px radius universal, with `scale(0.95)` active press as the signature micro-interaction
- **Color-block page rhythm** — Cream → White → Dark-green feature band → Cream → Dark-green footer
- **SoDoSans typeface** (substitute: Inter) with tight `-0.01em` tracking throughout
- **Whisper-soft layered shadows** — never single heavy drop shadows
- **Frap floating CTA** — 56px circular Green Accent button, the signature elevation element

### 1.2 Screen Model

The application spans **19 screens** organized in two authentication zones:

```
┌──────────────────────────────────────────┐
│          UNAUTHENTICATED ZONE            │
│                                          │
│  Splash → Onboarding → Login            │
│                        → Register        │
│                        → Forgot Password  │
│                                          │
│  Navigation: Full-screen, push/pop      │
│  No tab bar visible                      │
└──────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────┐
│           AUTHENTICATED ZONE             │
│                                          │
│  5-Tab Navigation:                      │
│  Home | Menu | Cart | Rewards | Profile  │
│                                          │
│  Tab-bar visible on root screens only    │
│  Hidden on Checkout, Confirmation,       │
│  and deep sub-screens                    │
└──────────────────────────────────────────┘
```

### 1.3 Canvas Layout Model

Every screen follows one of three layout templates:

**Template A — Cream Canvas (Default)**
```
┌─────────────────────────────────────┐
│  Status Bar                          │
├─────────────────────────────────────┤
│  App Bar (if applicable)             │
├─────────────────────────────────────┤
│                                     │
│  Neutral Warm (#f2f0eb) background  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  White Card (12px radius)    │  │
│  │  Layered shadow              │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  White Card                   │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  Full-width Pill CTA         │  │
│  └───────────────────────────────┘  │
│                                     │
├─────────────────────────────────────┤
│  Tab Bar  [🏠] [📋] [🛒] [⭐] [👤] │
└─────────────────────────────────────┘
```

**Template B — House Green Feature Band**
```
┌─────────────────────────────────────┐
│  Status Bar                          │
├─────────────────────────────────────┤
│  App Bar                             │
├─────────────────────────────────────┤
│  House Green (#1E3932) band          │
│  ┌────────────────────────────┐      │
│  │ White heading (h1)        │      │
│  │ White body text           │      │
│  │ Product photography       │      │
│  │ CTA: White-filled pill    │      │
│  └────────────────────────────┘      │
├─────────────────────────────────────┤
│  Cream canvas section                │
│  ┌──────────────────────────────┐   │
│  │ White Card content           │   │
│  └──────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  Tab Bar or Footer                   │
└─────────────────────────────────────┘
```

**Template C — Full-Screen Form**
```
┌─────────────────────────────────────┐
│  Status Bar                          │
├─────────────────────────────────────┤
│  Back Arrow + "Screen Title"         │
├─────────────────────────────────────┤
│  Neutral Warm background             │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  Floating Label Input 1      │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  Floating Label Input 2      │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  Floating Label Input 3      │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  Full-width Pill CTA         │  │
│  └───────────────────────────────┘  │
│                                     │
│  [Link: "Already have account?"]    │
└─────────────────────────────────────┘
```

---

## 2. Screen Flow Diagram

```
                          ┌──────────────────────┐
                          │  1. SPLASH / LOADING  │
                          │  (auto-transition)    │
                          └───────┬───────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
           ┌─────── ▼ ───────┐         ┌─────── ▼ ────────┐
           │  2. ONBOARDING  │         │  3. LOGIN        │
           │  (first launch) │─────►   │                  │
           └─────────────────┘         │ - phone/email    │
                                       │ - password       │
                    ┌─────────────────► │ - "Login" CTA    │
                    │                  └───┬───┬───────────┘
                    │                      │   │
           ┌─────── ▼ ────────┐    ┌────── ▼ ──────┐
           │  4. REGISTRATION │    │  5. FORGOT    │
           │                  │    │  PASSWORD     │
           │ - name, phone,   │    │               │
           │   email, pass    │    │ - phone + OTP │
           │ - OTP verify     │    │ - new password│
           └───────┬──────────┘    └───────┬───────┘
                   │                       │
                   └─────── ALL ───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │    MAIN TAB BAR        │
              │ [Home][Menu][Cart]     │
              │ [Rewards][Profile]     │
              └────────────────────────┘
                        │
        ┌───────────────┼───────────────────┐
        │               │                   │
        ▼               ▼                   ▼
┌──────────────┐ ┌──────────────┐ ┌─────────────────┐
│  6. HOME     │ │  7. MENU    │ │  10. CART       │
│              │ │  Categories  │ │                 │
│ - greeting   │ │             │ │ - item list     │
│ - hero       │ │ - tiles     │ │ - quantity      │
│ - quick act. │ │ 2-col grid  │ │ - subtotal      │
│ - Frap CTA   │ └──────┬──────┘ │ - "Checkout"   │
└──────────────┘        │        └───────┬─────────┘
                        ▼                │
                ┌──────────────┐         │
                │ 8. PRODUCT   │         │
                │ LIST         │         │
                │              │         ▼
                │ - subcats    │ ┌─────────────────┐
                │ - cards      │ │  11. CHECKOUT   │
                └──────┬──────┘ │                 │
                       ▼        │ - store select  │
                ┌──────────────┐│ - order summary │
                │ 9. PRODUCT   ││ - notes input   │
                │ DETAIL       ││ - payment pick  │
                │              ││ - "Place Order" │
                │ - size pick  │└───────┬─────────┘
                │ - qty        │        │
                │ - "Add to    │        ▼
                │   Order" CTA │ ┌─────────────────┐
                └──────────────┘ │  12. ORDER      │
                                 │  CONFIRMATION   │
┌────────────────┐              │                 │
│ 15. REWARDS    │              │ - checkmark ✓   │
│                │              │ - order ID      │
│ - points hero  │              │ - ETA           │
│ - history list │              │ - summary       │
└────────────────┘              └───┬───┬─────────┘
                                   │   │
┌────────────────┐                 │   │
│ 16. PROFILE    │◄────────────────┘   │
│                │                     │
│ - avatar/name  │              ┌──────▼──────┐
│ - menu rows    │              │ 13. ORDER   │
│                │              │ HISTORY     │
│ → Edit Profile │              │             │
│ → Order History│              │ - list      │
│ → Settings     │              │ - reorder   │
│ → Logout       │              └──────┬──────┘
└──┬──┬──┬───────┘                     │
   │  │  │                      ┌──────▼──────┐
   │  │  │                      │ 14. ORDER   │
   │  │  │                      │ DETAIL      │
   │  │  │                      │             │
   │  │  │                      │ - items     │
   │  │  │                      │ - timeline  │
   │  │  │                      │ - reorder   │
   │  │  │                      └─────────────┘
   │  │  │
   │  │  └────► 19. CHANGE     │  17. EDIT      │ 18. SETTINGS
   │  │          PASSWORD       │  PROFILE       │
   │  │                        │                │
   │  │                        │ - avatar edit  │ - toggles
   │  └────► 18. SETTINGS     │ - name/email   │ - change pass
   │                           │ - save         │ - delete acct
   │                           └────────────────┘
   └────► 17. EDIT PROFILE
```

---

## 3. Splash & Auth Screens

### 3.1 Splash / Loading Screen (SC-01)

```
┌─────────────────────────────────────┐
│                                     │
│  [Status Bar: transparent, white    │
│   text]                                      │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│           ┌───────────┐             │
│           │           │             │
│           │   CFPV    │             │
│           │   LOGO    │             │
│           │  (brand   │             │
│           │   mark)   │             │
│           │           │             │
│           └───────────┘             │
│                                     │
│          [Brand Name]               │
│       CFPV Coffee & Tea             │
│                                     │
│                                     │
│          (  )  (  )  (  )           │
│        Loading indicator            │
│         (pulsing dots)              │
│                                     │
│                                     │
│                                     │
│         v1.0.0                      │
│                                     │
├─────────────────────────────────────┤
│  Background: Neutral Warm #f2f0eb   │
│  Logo: Starbucks Green #006241      │
│  Text: Text Black Soft rgba(0,0,0,  │
│        0.58) at 14px weight 400     │
│  Duration: ~1.5s or until token     │
│            validation completes     │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Logo: Starbucks Green (#006241)
- Version label: Text Black Soft (rgba(0,0,0,0.58))
- Loading dots: Green Accent (#00754A)

TYPOGRAPHY:
- Brand name: SoDoSans 24px 600, Text Black (rgba(0,0,0,0.87))
- Version: SoDoSans 13px 400, Text Black Soft

BEHAVIOR:
- On appear: check secure storage for JWT token
- Token valid → auto-navigate to Home (SC-06)
- Token missing/expired → navigate to Onboarding (first launch) or Login (returning)
- Loading dots pulse on 1s interval (opacity 0.3 → 1.0)
- Fade-out transition to next screen: 300ms ease-out

COMPONENT HIERARCHY:
[SafeArea]
  └── [Stack]
      ├── [Container(color: #f2f0eb)]
      └── [Center]
          └── [Column(mainAxis: center)]
              ├── [SizedBox(w: 120, h: 120)]
              │   └── [AppLogo(color: #006241)]
              ├── [SizedBox(h: 16)]
              ├── [Text("CFPV") style: soDoSans H1 Green]
              ├── [SizedBox(h: 4)]
              ├── [Text("Coffee & Tea") style: soDoSans body Soft]
              ├── [Spacer(flex: 2)]
              └── [Column]
                  ├── [LoadingDots(color: #00754A)]
                  └── [Text("v1.0.0") style: soDoSans micro Soft]
```

### 3.2 Login Screen (SC-02)

```
┌─────────────────────────────────────┐
│  [Status Bar: Neutral Warm]         │
├─────────────────────────────────────┤
│                                     │
│                                     │
│          ┌─────────────────┐        │
│          │                 │        │
│          │   CFPV LOGO     │        │
│          │   (small)       │        │
│          │                 │        │
│          └─────────────────┘        │
│                                     │
│    Welcome Back                     │
│    Sign in to your account          │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Phone number or email       │  │ ← Floating label
│   │                             │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Password                     │  │ ← Floating label
│   │                             │  │
│   │                         [👁] │  │
│   └──────────────────────────────┘  │
│                                     │
│      [Forgot password?]             │
│                                     │
│   ┌──────────────────────────────┐  │
│   │         Sign In              │  │ ← 50px pill, #00754A
│   └──────────────────────────────┘  │
│                                     │
│                                     │
│    Don't have an account?           │
│         [Create one]                │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  Background: Neutral Warm #f2f0eb   │
│  Card container: transparent        │
│  (no card — inputs float on canvas) │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Input border: #d6dbde (default), #00754A (focus)
- Floating label: Text Black Soft (13px, weight 600)
- Input text: Text Black (16px, weight 400)
- Primary CTA: Green Accent (#00754A) filled, white text
- Link text: Green Accent (#00754A), weight 600
- "Forgot password?" link: Text Black Soft (#00754A on hover)

TYPOGRAPHY:
- "Welcome Back": SoDoSans H1 (24px, 600, #006241 Starbucks Green)
- "Sign in to your account": SoDoSans body (16px, 400, Text Black Soft)
- Input labels: SoDoSans Small (14px, 600, Text Black, -0.01em)
- CTA: SoDoSans Button Label (16px, 600, #ffffff)
- Links: SoDoSans Small (14px, 600, #00754A)

COMPONENT HIERARCHY:
[SafeArea]
  └── [SingleChildScrollView]
      └── [Padding(16px)]
          └── [Column(crossAxisAlignment: center)]
              ├── [SizedBox(h: 48)]
              ├── [AppLogo(small) w: 64, h: 64]
              ├── [SizedBox(h: 32)]
              ├── [Text("Welcome Back") style: h1Green]
              ├── [SizedBox(h: 4)]
              ├── [Text("Sign in to your account") style: bodySoft]
              ├── [SizedBox(h: 32)]
              ├── [FloatingLabelInput(
              │     label: "Phone number or email",
              │     keyboardType: TextInputType.emailAddress,
              │     validator: required + phone/email pattern
              │   )]
              ├── [SizedBox(h: 16)]
              ├── [FloatingLabelInput(
              │     label: "Password",
              │     obscureText: true,
              │     suffixIcon: EyeToggle
              │   )]
              ├── [SizedBox(h: 8)]
              ├── [Align(right)]
              │   └── [TextButton("Forgot password?")]
              ├── [SizedBox(h: 24)]
              ├── [PrimaryPillButton("Sign In")]
              ├── [Spacer]
              ├── [Row]
              │   ├── [Text("Don't have an account?")]
              │   └── [TextButton("Create one")]
              └── [SizedBox(h: 32)]

INTERACTIVE STATES:
- Input focus: border shifts to 2px #00754A, label animates to -12px above border
- Input valid: subtle #d4e9e2 tint background (33% opacity)
- Input invalid: subtle #c82014 tint background (5% opacity), red border, error text below
- CTA press: transform scale(0.95), transition 0.2s ease
- CTA disabled: opacity 0.5, no press feedback
- Loading: CTA shows circular loading indicator, inputs disabled
```

### 3.3 Registration Screen (SC-03)

```
┌─────────────────────────────────────┐
│  [Status Bar: Neutral Warm]         │
│  [← Back]                           │
├─────────────────────────────────────┤
│                                     │
│    Create Account                   │
│    Join the CFPV family             │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Full name                   │  │
│   │                             │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Phone number                │  │
│   │ (+84)                       │  │ ← +84 prefix added
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Email (optional)            │  │
│   │                             │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Password                    │  │
│   │                         [👁] │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Confirm password            │  │
│   │                         [👁] │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │      Create Account         │  │
│   └──────────────────────────────┘  │
│                                     │
│    Already have an account?         │
│         [Sign in]                   │
│                                     │
├─────────────────────────────────────┤
│  Password requirements shown below  │
│  password field when focused:       │
│  "• At least 8 characters          │
│   • 1 uppercase, 1 number"         │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Inputs: Floating label style per DESIGN.md
- CTA: Green Accent (#00754A)
- Links: Green Accent (#00754A)
- Error text: Red (#c82014)

TYPOGRAPHY:
- "Create Account": SoDoSans H1 (24px, 600, #006241)
- "Join the CFPV family": SoDoSans body (16px, 400, Text Black Soft)
- Input labels: SoDoSans Small (14px, 600, -0.01em)
- CTA: SoDoSans Button Label (16px, 600, #ffffff)

OTP VERIFICATION FLOW (inline, same screen):
After tapping "Create Account" with valid form:
1. API call to send OTP
2. Inputs collapse / shift up
3. OTP input appears:
   ┌────────────────────────────────┐
   │ [_] [_] [_] [_] [_] [_]       │ ← 6 digit boxes
   │ Enter verification code        │
   │ Sent to +84 xxx xxx xxx        │
   │ [Resend code in 30s]           │
   └────────────────────────────────┘
4. Auto-submit on 6th digit entry
5. On success → auto-navigate to Home
6. On failure → shake animation + error message + reset

COMPONENT HIERARCHY:
[SafeArea]
  └── [SingleChildScrollView]
      └── [Padding(16px)]
          └── [Column]
              ├── [BackButton]  // ← chevron, #00754A
              ├── [SizedBox(h: 16)]
              ├── [Text("Create Account") style: h1Green]
              ├── [Text("Join the CFPV family") style: bodySoft]
              ├── [SizedBox(h: 32)]
              ├── [FloatingLabelInput("Full name")]
              ├── [SizedBox(h: 16)]
              ├── [FloatingLabelInput(
              │     "Phone number",
              │     prefix: "+84",
              │     keyboardType: phone
              │   )]
              ├── [SizedBox(h: 16)]
              ├── [FloatingLabelInput("Email (optional)", keyboardType: email)]
              ├── [SizedBox(h: 16)]
              ├── [FloatingLabelInput("Password", obscure: true)]
              ├── [PasswordRequirementsHint]
              ├── [SizedBox(h: 16)]
              ├── [FloatingLabelInput("Confirm password", obscure: true)]
              ├── [SizedBox(h: 32)]
              ├── [PrimaryPillButton("Create Account")]
              ├── [Spacer]
              ├── [Row]
              │   ├── [Text("Already have an account?")]
              │   └── [TextButton("Sign in")]
              └── [SizedBox(h: 32)]
```

### 3.4 Forgot Password Screen (SC-04)

```
┌─────────────────────────────────────┐
│  [Status Bar: Neutral Warm]         │
│  [← Back]                           │
├─────────────────────────────────────┤
│                                     │
│    Reset Password                   │
│    We'll send you a reset code      │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Phone number                │  │ ← Floating label
│   │ (+84)                       │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │       Send OTP               │  │
│   └──────────────────────────────┘  │
│                                     │
│  ──── After OTP sent ────           │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ [_] [_] [_] [_] [_] [_]     │  │ ← 6-digit OTP
│   └──────────────────────────────┘  │
│    Enter OTP code                   │
│    Sent to +84 xxx xxx xxx          │
│    [Resend OTP in 30s]              │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ New password                │  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ New password                │  │
│   │                         [👁] │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Confirm new password        │  │
│   │                         [👁] │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │      Reset Password         │  │
│   └──────────────────────────────┘  │
│                                     │
│         [Back to Sign In]           │
│                                     │
├─────────────────────────────────────┤
│  Flow:                              │
│  1. Enter phone → Send OTP          │
│  2. Enter OTP + new password        │
│  3. Submit → success → redirect     │
│     to Login with toast             │
└─────────────────────────────────────┘

COLORS/TYPOGRAPHY: Same pattern as Login and Registration.
```

---

## 4. Onboarding Screen (SC-05)

```
┌─────────────────────────────────────┐
│  [Status Bar: transparent, white    │
│   text on hero image]                        │
├─────────────────────────────────────┤
│                                     │
│                                     │
│   ┌─────────────────────────────┐   │
│   │                             │   │
│   │     Full-bleed hero         │   │
│   │     illustration /          │   │
│   │     product photography     │   │
│   │     (coral/sage/amber       │   │
│   │      warm background)       │   │
│   │                             │   │
│   └─────────────────────────────┘   │
│                                     │
│                                     │
│        Browse & Order               │ ← Slide 1 headline
│     Explore our full menu of        │
│     handcrafted beverages and       │
│     fresh food.                     │
│                                     │
│                                     │
│         (●)  (○)  (○)              │ ← Page indicator (3 dots)
│                                     │
│          [Skip]     [Next →]        │ ← Skip left, Next right
│                                     │
├─────────────────────────────────────┤
│                                     │
│  Slide 2: "Earn Rewards"            │
│  Slide 3: "Fast & Easy Pickup"      │
│                                     │
│  On slide 3: [✓ Get Started] CTA    │
│  replaces [Next →]                  │
│                                     │
└─────────────────────────────────────┘

COLORS:
- Canvas: Hero images with warm backgrounds (coral, sage, amber)
- Text: White (#ffffff) over hero images
- Page indicator: Active = White, Inactive = White at 40% opacity
- Skip button: White, weight 400
- Next button: White-filled pill, Green Accent text
- Get Started: Green Accent (#00754A) filled pill, white text

TYPOGRAPHY:
- Headline (slide title): SoDoSans Hero Large (28px, 600, -0.16px)
- Body: SoDoSans Body Large (19px, 400, 1.75 line height)
- Skip: SoDoSans Small (14px, 400)
- Next/Get Started: SoDoSans Button Label (16px, 600)

BEHAVIOR:
- PageView with 3 slides, PageController
- Swipe to advance; dots update
- Skip → Login screen immediately
- Get Started → Register screen

COMPONENT HIERARCHY:
[Stack]
  ├── [PageView]
  │   ├── [OnboardingSlide(
  │   │     image: "assets/onboarding/order.png",
  │   │     title: "Browse & Order",
  │   │     body: "Explore our full menu..."
  │   │   )]
  │   ├── [OnboardingSlide(
  │   │     image: "assets/onboarding/rewards.png",
  │   │     title: "Earn Rewards",
  │   │     body: "Collect points..."
  │   │   )]
  │   └── [OnboardingSlide(
  │         image: "assets/onboarding/pickup.png",
  │         title: "Fast & Easy Pickup",
  │         body: "Order ahead..."
  │       )]
  └── [Positioned(bottom)]
      └── [Padding(16px)]
          └── [Column]
              ├── [PageIndicator(dotCount: 3, activeIndex)]
              ├── [SizedBox(h: 24)]
              └── [Row]
                  ├── [TextButton("Skip")]
                  ├── [Spacer]
                  └── [PrimaryPillButton(
                        isLastPage ? "✓  Get Started" : "Next →"
                      )]
```

---

## 5. Tab-Root Screens

### 5.1 Home Screen (SC-06)

```
┌─────────────────────────────────────┐
│  [Status Bar: transparent]          │
├─────────────────────────────────────┤
│  App Bar:                           │
│  ┌─────────────────────────────────┐│
│  │ ☰        Good morning, Thao!  ⭐││ ← Star = points
│  │                                  ││     badge
│  │ Subtitle: 450★ balance         🛒││
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  Neutral Warm (#f2f0eb) canvas      │
│                                     │
│  ┌─────────────────────────────┐    │
│  │   HERO BANNER               │    │ ← Swipable banner
│  │   ┌─────────────────────┐   │    │   (PageView)
│  │   │ Summer Drinks      │   │    │
│  │   │ New! Mango Passion │   │    │
│  │   │ [Order Now →]      │   │    │
│  │   └─────────────────────┘   │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌──────┐ ┌──────┐ ┌──────┐       │ ← Quick action cards
│  │Order │ │ Menu │ │Reward│       │   3 cards in a row
│  │Again │ │      │ │      │       │
│  │  📋  │ │  📋  │ │  📋  │       │
│  └──────┘ └──────┘ └──────┘       │
│                                     │
│  Featured Items                     │ ← Section header
│   ┌────┐ ┌────┐ ┌────┐ ┌────┐     │   Horizontal scroll
│   │    │ │    │ │    │ │    │     │
│   │ ☕  │ │ 🥤 │ │ 🥐 │ │ 🥪 │     │
│   │Name │ │Name│ │Name│ │Name│     │
│   │Price│ │Price│ │... │ │... │     │
│   └────┘ └────┘ └────┘ └────┘     │
│                                     │
│  Categories                         │ ← Section header
│  Beverages  Food  Merchandise       │   Horizontal chips
│                                     │
│                                     │
├─────────────────────────────────────┤
│                    [🛒] Frap CTA    │ ← 56px circular,
│  Tab Bar [🏠][📋][🛒][⭐][👤]    │    bottom-right
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- App bar: White (#ffffff) with 3-layer shadow stack
- Section headers: Starbucks Green (#006241), H2 weight 400
- Hero banner: House Green (#1E3932) feature band style
- Quick action cards: White (#ffffff), 12px radius, whisper shadows
- Featured items card: White, 12px radius
- Frap CTA: Green Accent (#00754A), 56px circle
- Points badge: Gold (#cba258) star icon

TYPOGRAPHY:
- Greeting: SoDoSans H1 (24px, 600, Text Black)
- Points badge: SoDoSans Small (14px, 600, Text Black)
- Section headers: SoDoSans H2 (24px, 400, Text Black)
- Featured item name: SoDoSans body (16px, 600, Text Black)
- Featured item price: SoDoSans Small (14px, 400, Text Black Soft)
- Frap icon: white shopping-bag icon

COMPONENT HIERARCHY:
[Scaffold]
  ├── appBar: [HomeAppBar(
  │     greeting: "Good morning, Thao!",
  │     pointsBadge: 450,
  │     cartBadge: 3
  │   )]
  ├── body: [SingleChildScrollView]
  │   └── [Column]
  │       ├── [HeroBanner(height: 180)]  // PageView
  │       ├── [SizedBox(h: 24)]
  │       ├── [QuickActionsRow]
  │       │   ├── [QuickActionCard("Order Again", icon)]
  │       │   ├── [QuickActionCard("Menu", icon)]
  │       │   └── [QuickActionCard("Rewards", icon)]
  │       ├── [SizedBox(h: 32)]
  │       ├── [SectionHeader("Featured Items")]
  │       ├── [SizedBox(h: 12)]
  │       ├── [HorizontalProductScroll(items: featured)]
  │       ├── [SizedBox(h: 32)]
  │       ├── [SectionHeader("Categories")]
  │       ├── [CategoryChipsRow(categories)]
  │       └── [SizedBox(h: 32)]
  ├── floatingActionButton: [FrapCTA(onTap: → /menu)]
  └── bottomNavigationBar: [CFPVTabBar(currentIndex: 0)]

INTERACTIVE STATES:
- Hero banner: swipeable, dot indicator, tap → promo detail
- Quick action cards: tap → respective screen, scale(0.95) on press
- Featured items: tap → Product Detail, scale(0.95) on press
- Frap button: scale(0.95) + ambient shadow fades on press
```

### 5.2 Menu — Category List Screen (SC-07)

```
┌─────────────────────────────────────┐
│  [Status Bar: transparent]          │
├─────────────────────────────────────┤
│  App Bar:                           │
│  ┌─────────────────────────────────┐│
│  │     Menu                   🛒  ││ ← Cart badge (3)
│  │          🔍 Search             ││ ← Search bar (optional MVP)
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  Neutral Warm (#f2f0eb) canvas      │
│                                     │
│  Featured / Promo Banner            │ ← Optional, top
│  ┌─────────────────────────────┐    │
│  │ New: Summer Menu →          │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌────────────────────┐ ┌──────────┐│ ← 2-column grid
│  │                    │ │          ││
│  │    ☕ Beverages    │ │   🥪     ││
│  │                    │ │   Food   ││
│  │                    │ │          ││
│  └────────────────────┘ └──────────┘│
│                                     │
│  ┌────────────────────┐ ┌──────────┐│
│  │                    │ │          ││
│  │   🎁 Merchandise  │ │   🏠     ││
│  │                    │ │  At Home ││
│  │                    │ │          ││
│  └────────────────────┘ └──────────┘│
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│                    [🛒] Frap CTA    │
│  Tab Bar [🏠][📋][🛒][⭐][👤]    │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Category tiles: White (#ffffff), 12px radius
- Image: full-bleed photography within tile
- Label: SoDoSans 16/600, Text Black
- Search bar bg: Neutral Cool (#f9f9f9), 12px radius
- Search icon: Text Black Soft
- Promo banner: House Green (#1E3932), white text

TYPOGRAPHY:
- Screen title: SoDoSans H1 (24px, 600, Text Black)
- Category label: SoDoSans body (16px, 600, Text Black)
- Search hint: SoDoSans Small (14px, 400, Text Black Soft)
- Promo text: SoDoSans body (16px, 400, White)

TILE DIMENSIONS:
- Width: ~167px (2-column with 16px gap on 360px screen)
- Height: ~160px (image: 120px + label: 40px)

COMPONENT HIERARCHY:
[Scaffold]
  ├── appBar: [MenuAppBar(cartBadge: 3)]
  ├── body: [SingleChildScrollView]
  │   └── [Padding(outerGutter: 16)]
  │       └── [Column]
  │           ├── [PromoBanner?]  // conditional, post-MVP likely
  │           ├── [SizedBox(h: 16)]
  │           └── [GridView.count(crossAxisCount: 2)]
  │               └── [CategoryTile(
  │                     image: url,
  │                     name: "Beverages",
  │                     onTap: → /menu/category/:id
  │                   ) × N]
  ├── floatingActionButton: [FrapCTA]
  └── bottomNavigationBar: [CFPVTabBar(currentIndex: 1)]
```

### 5.3 Cart Screen (SC-10)

```
┌─────────────────────────────────────┐
│  [Status Bar: transparent]          │
├─────────────────────────────────────┤
│  App Bar:                           │
│  ┌─────────────────────────────────┐│
│  │     Cart (3 items)             ││
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  Neutral Warm (#f2f0eb) canvas      │
│                                     │
│  Store: [Cửa hàng CFPV Quận 1  ▼]  │ ← Store selector
│                                     │
│  ┌─────────────────────────────┐    │ ← Cart item card
│  │ ┌────┐                     │    │   (White, 12px radius)
│  │ │    │  Caffè Latte        │    │
│  │ │  ☕ │  Grande             │    │
│  │ │    │  55,000₫            │    │
│  │ └────┘                     │    │
│  │         [−]  2  [+]  [🗑]  │    │ ← Quantity stepper + delete
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ┌────┐                     │    │
│  │ │    │  Chicken Sandwich   │    │
│  │ │ 🥪 │                      │    │
│  │ │    │  49,000₫            │    │
│  │ └────┘                     │    │
│  │         [−]  1  [+]  [🗑]  │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─────────────────────────────      │ ← Hairline separator
│  Subtotal             165,000₫      │
│  Tax (10%)            16,500₫       │
│  Total              181,500₫        │
│                                     │
│  ┌──────────────────────────────┐   │
│  │          Checkout            │   │ ← 50px pill, full-width
│  └──────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  Tab Bar [🏠][📋][🛒][⭐][👤]    │
└─────────────────────────────────────┘

┌─── Empty Cart State ────────────────┐
│  (shown when no items)              │
│                                     │
│       ┌─────────────────┐           │
│       │                 │           │
│       │   🛒 (large     │           │ ← Illustration
│       │    empty cart   │           │
│       │    icon)        │           │
│       │                 │           │
│       └─────────────────┘           │
│                                     │
│    Your cart is empty               │
│    Looks like you haven't added     │
│    anything to your order yet.      │
│                                     │
│   ┌──────────────────────────────┐  │
│   │      Browse Menu             │  │ ← Green Accent pill
│   └──────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Item cards: White (#ffffff), 12px radius, whisper shadow
- Store selector: White card, 12px radius, chevron-down icon
- Quantities: Text Black, weight 600
- Price: Text Black, weight 600 (line total)
- Delete button: Red (#c82014)
- Subtotal/tax: Text Black Soft, weight 400
- Total: Text Black, weight 600 (bolder, larger 18px)
- Checkout CTA: Green Accent (#00754A) filled pill

COMPONENT HIERARCHY:
[Scaffold]
  ├── appBar: [AppBar(title: "Cart (3 items)")]
  ├── body: [Column]
  │   ├── [StoreSelector(
  │   │     selectedStore: "Cửa hàng CFPV Quận 1",
  │   │     onTap: → store picker modal
  │   │   )]
  │   ├── [Expanded]
  │   │   └── [ListView]
  │   │       └── [CartItemCard(
  │   │             image, name, variant, unitPrice,
  │   │             quantity, onIncrement, onDecrement, onDelete
  │   │           ) × N]
  │   └── [BottomSummary]
  │       ├── [Divider]
  │       ├── [PriceRow("Subtotal", "165,000₫")]
  │       ├── [PriceRow("Tax (10%)", "16,500₫")]
  │       ├── [PriceRow.total("Total", "181,500₫")]
  │       ├── [SizedBox(h: 16)]
  │       └── [PrimaryPillButton.fullWidth("Checkout")]
  ├── floatingActionButton: null  // Frap hidden on Cart
  └── bottomNavigationBar: [CFPVTabBar(currentIndex: 2)]
```

### 5.4 Rewards Screen (SC-15)

```
┌─────────────────────────────────────┐
│  [Status Bar: translucent, light]   │
├─────────────────────────────────────┤
│  App Bar:                           │
│  ┌─────────────────────────────────┐│
│  │     Rewards                     ││
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│ ← House Green feature
│  │  HOUSE GREEN BAND              ││    band (#1E3932)
│  │                                 ││
│  │         ⭐                      ││ ← Gold star icon
│  │                                 ││
│  │       450                       ││ ← White, 48px, weight 600
│  │                                 ││
│  │       points                    ││ ← Text White Soft, 16px
│  │                                 ││
│  │   1★ per 10,000₫               ││ ← Text White Soft, 14px
│  │                                 ││
│  └─────────────────────────────────┘│
│                                     │
│  Recent Activity                    │ ← Section header
│  ─────────────────────────────      │ ← White card section
│  ┌─────────────────────────────┐    │
│  │ Jun 7   Order #CFPV-...  15★│   │
│  │         Caffè Latte          │   │
│  │         Balance: 450★       │   │
│  ├─────────────────────────────┤    │
│  │ Jun 6   Order #CFPV-...  15★│   │
│  │         Chicken Sandwich    │   │
│  │         Balance: 435★       │   │
│  ├─────────────────────────────┤    │
│  │ Jun 5   Welcome Bonus   50★│   │
│  │         Balance: 420★       │   │
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│  Tab Bar [🏠][📋][🛒][⭐][👤]    │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Hero band: House Green (#1E3932)
- Points number: White (#ffffff)
- Star icon: Gold (#cba258)
- Section header: Starbucks Green (#006241), H2
- History rows: White cards, hairline separators (#e7e7e7)
- Points earned: Green Accent (#00754A)
- Points redeemed: Gold (#cba258)

TYPOGRAPHY:
- Screen title: SoDoSans H1 (24px, 600, Text Black)
- Points number: SoDoSans Display (48px, 600, White, -0.16px)
- "points" label: SoDoSans body (16px, 400, Text White Soft)
- "1★ per 10,000₫": SoDoSans Small (14px, 400, Text White Soft)
- "Recent Activity": SoDoSans H2 (24px, 400, Text Black)
- History item date: SoDoSans Small (14px, 600, Text Black)
- History item desc: SoDoSans body (16px, 400, Text Black)
- History item points: SoDoSans Small (14px, 700, #00754A)
- History item balance: SoDoSans Micro (13px, 400, Text Black Soft)

POST-MVP COMPONENTS (not rendered in MVP):
- Redeemable items grid (Gold-outlined pill: "150★ item")
- Tier progress card (House Green, Gold accents)
- Tier badge (Bronze/Silver/Gold)

COMPONENT HIERARCHY:
[Scaffold]
  ├── appBar: [AppBar(title: "Rewards")]
  ├── body: [SingleChildScrollView]
  │   └── [Column]
  │       ├── [PointsHero(
  │       │     balance: 450,
  │       │     earnRate: "1★ per 10,000₫",
  │       │     backgroundColor: #1E3932
  │       │   )]
  │       ├── [SizedBox(h: 32)]
  │       ├── [SectionHeader("Recent Activity")]
  │       ├── [SizedBox(h: 12)]
  │       └── [PointsHistoryList(transactions)]
  ├── floatingActionButton: [FrapCTA]
  └── bottomNavigationBar: [CFPVTabBar(currentIndex: 3)]
```

### 5.5 Profile Screen (SC-16)

```
┌─────────────────────────────────────┐
│  [Status Bar: transparent]          │
├─────────────────────────────────────┤
│  App Bar:                           │
│  ┌─────────────────────────────────┐│
│  │     Profile                     ││
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  Neutral Warm (#f2f0eb) canvas      │
│                                     │
│  ┌─────────────────────────────┐    │ ← Profile header card
│  │                             │    │   (White, 12px radius)
│  │      ┌─────────┐            │    │
│  │      │         │            │    │
│  │      │  Avitar │            │    │ ← Circle, 72px
│  │      │   📷    │            │    │
│  │      │         │            │    │
│  │      └─────────┘            │    │
│  │                             │    │
│  │      Nguyen Thao            │    │ ← SoDoSans 24px, 600
│  │      thao.nguyen@email.com  │    │ ← SoDoSans 14px, 400
│  │      +84 123 456 789        │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │ ← Menu rows card
│  │  📋  Order History       ›  │    │
│  ├─────────────────────────────┤    │
│  │  ⭐  Rewards              ›  │    │
│  ├─────────────────────────────┤    │
│  │  ⚙  Settings              ›  │    │
│  ├─────────────────────────────┤    │
│  │  ❓  Help & Support        ›  │    │ ← Post-MVP
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │                               │  │
│  │       Log Out               │  │ ← 50px pill, outlined
│  │                               │  │   (Text Black outline)
│  └─────────────────────────────┘  │
│                                     │
├─────────────────────────────────────┤
│  Tab Bar [🏠][📋][🛒][⭐][👤]    │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Profile header: White (#ffffff), 12px radius
- Avatar: 72px circle with 2px #00754A border
- Camera overlay: 50% opacity black circle with white camera icon
- Name: Text Black, weight 600
- Email/phone: Text Black Soft, weight 400
- Menu rows: White card, hairline separators
- Row icons: Text Black Soft
- Chevron: Text Black Soft
- Logout button: Outlined, Text Black border, Text Black text

COMPONENT HIERARCHY:
[Scaffold]
  ├── appBar: [AppBar(title: "Profile")]
  ├── body: [SingleChildScrollView]
  │   └── [Padding(16)]
  │       └── [Column]
  │           ├── [ProfileHeaderCard(
  │           │     avatarUrl, name, email, phone,
  │           │     onAvatarTap: → edit
  │           │   )]
  │           ├── [SizedBox(h: 16)]
  │           ├── [MenuCard]
  │           │   ├── [MenuRow(
  │           │   │     icon: "📋", label: "Order History",
  │           │   │     onTap: → /profile/orders
  │           │   │   )]
  │           │   ├── [Divider]
  │           │   ├── [MenuRow(
  │           │   │     icon: "⭐", label: "Rewards",
  │           │   │     onTap: → /rewards
  │           │   │   )]
  │           │   ├── [Divider]
  │           │   ├── [MenuRow(
  │           │   │     icon: "⚙", label: "Settings",
  │           │   │     onTap: → /profile/settings
  │           │   │   )]
  │           │   └── [Divider]
  │           │   └── [MenuRow(
  │           │         icon: "❓", label: "Help & Support",
  │           │         onTap: → post-MVP
  │           │       )]
  │           ├── [SizedBox(h: 24)]
  │           └── [OutlinedPillButton(
  │                 "Log Out",
  │                 textColor: Text Black,
  │                 borderColor: Text Black
  │               )]
  ├── floatingActionButton: [FrapCTA]
  └── bottomNavigationBar: [CFPVTabBar(currentIndex: 4)]
```

---

## 6. Product Screens

### 6.1 Product List Screen (SC-08)

```
┌─────────────────────────────────────┐
│  [Status Bar: transparent]          │
├─────────────────────────────────────┤
│  App Bar:                           │
│  ┌─────────────────────────────────┐│
│  │  ←  Beverages              🛒  ││ ← Back + category name
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  Subcategories:                     │ ← Horizontal scroll
│  [All] [Hot Coffees] [Iced]        │    chips
│  [Frappuccino] [Tea]               │
│                                     │
│  ┌──────┐ ┌──────┐                 │ ← 2-column scrolling grid
│  │      │ │      │                 │
│  │ ☕    │ │ ☕    │                 │
│  │Caffè │ │Latte │                 │
│  │Latte │ │Macch.│                 │
│  │55,000│ │55,000│                 │
│  └──────┘ └──────┘                 │
│                                     │
│  ┌──────┐ ┌──────┐                 │
│  │      │ │      │                 │
│  │ ☕    │ │ ☕    │                 │
│  │Mocha │ │Americ│                 │
│  │59,000│ │49,000│                 │
│  └──────┘ └──────┘                 │
│                                     │
│  ┌──────┐ ┌──────┐                 │
│  │      │ │      │                 │
│  │ ...  │ │ ...  │                 │ ← Infinite scroll
│  └──────┘ └──────┘                 │
│                                     │
├─────────────────────────────────────┤
│                    [🛒] Frap CTA    │
│  Tab Bar [🏠][📋][🛒][⭐][👤]    │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Product cards: White (#ffffff), 12px radius, whisper shadows
- Product image: square, soft drop shadow around glass
- Name: SoDoSans 16/600, Text Black
- Price: SoDoSans 14/400, Text Black Soft
- Sale price: Green Accent (#00754A), 14/600
- Subcategory chip (active): Green Accent fill, white text
- Subcategory chip (inactive): White fill, Text Black Soft text, 1px #d6dbde border
- Out-of-stock: 50% opacity overlay on image, "Sold out" badge

PRODUCT CARD DIMENSIONS:
- Width: ~167px (2-column with 16px gap)
- Image height: ~120px
- Card internal padding: 0px (full-bleed image), label below in 8px padding

COMPONENT HIERARCHY:
[Scaffold]
  ├── appBar: [BackAppBar(title: categoryName, cartBadge: n)]
  ├── body: [Column]
  │   ├── [SubcategoryChipsRow(
  │   │     items: ["All", "Hot Coffees", "Iced", ...],
  │   │     selectedIndex: 0,
  │   │     scrollable: true
  │   │   )]
  │   └── [Expanded]
  │       └── [GridView.count(crossAxisCount: 2)]
  │           └── [ProductCard(
  │                 image, name, price, isAvailable,
  │                 onTap: → /menu/product/:id
  │               ) × N]
  ├── floatingActionButton: [FrapCTA]
  └── bottomNavigationBar: [CFPVTabBar(currentIndex: 1)]
```

### 6.2 Product Detail Screen (SC-09)

```
┌─────────────────────────────────────┐
│  [Status Bar: light content]        │
├─────────────────────────────────────┤
│  ← Back                         🛒  │ ← Back chevron + cart
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │   HOUSE GREEN BAND             ││ ← #1E3932
│  │                                 ││
│  │  Menu / Beverages / Caffè Latte││ ← Breadcrumb, 14/400 white
│  │                                 ││
│  │      Caffè Latte               ││ ← SoDoSans 32/700 uppercase
│  │                                 ││
│  │     ┌─────────────────┐        ││
│  │     │                 │        ││
│  │     │   Product       │        ││ ← Product photo
│  │     │   Photography   │        ││    centered
│  │     │                 │        ││
│  │     └─────────────────┘        ││
│  │                                 ││
│  │   [☕ Tall] [☕ Grande] [☕ Venti]││ ← Size selector
│  │     Tall      Grande    Venti  ││    Cup icon + name
│  │     355ml     473ml     591ml  ││    Fluid ounce
│  │                                 ││
│  └─────────────────────────────────┘│
│                                     │
│  Cream canvas section               │
│  ┌─────────────────────────────┐    │ ← White card
│  │  Our signature espresso     │    │    Description
│  │  with steamed milk...       │    │
│  │                             │    │
│  │  Calories: 150  Sugar: 12g │    │ ← Nutritional summary
│  │  Fat: 7g                   │    │    with info icon tooltip
│  │                             │    │
│  │  ── Nutrition & Ingredients│    │ ← Expandable accordion
│  │  → (expands section below) │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │ ← Bottom action bar
│  │  [−]  1  [+]    55,000₫    │    │    Qty stepper + price
│  │  ┌─────────────────────────┐│    │
│  │  │     Add to Order       ││    │ ← 50px pill, #00754A
│  │  └─────────────────────────┘│    │
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│                    [🛒] Frap CTA    │
│  Tab Bar [🏠][📋][🛒][⭐][👤]    │
└─────────────────────────────────────┘

┌─── Nutrition Expandable ────────────┐
│  When expanded:                     │
│  ┌─────────────────────────────┐    │
│  │ Ingredients                 │    │
│  │ Espresso, milk, ice...      │    │
│  │                             │    │
│  │ Nutrition                   │    │
│  │ Calories          150       │    │
│  │ Total Fat         7g        │    │
│  │ Sodium            100mg     │    │
│  │ Total Carbs       15g       │    │
│  │  — Dietary Fiber  0g       │    │
│  │  — Sugars         12g      │    │
│  │ Protein           8g       │    │
│  │ Caffeine          150mg    │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘

COLORS:
- Hero band: House Green (#1E3932)
- Breadcrumb: White, 14/400
- Product title: White, SoDoSans 32/700 uppercase, -0.16px tracking
- Size selector: White text, active = 2px #00754A ring around cup icon
- Description card: White (#ffffff), 12px radius
- Nutrition expandable: White card, 12px radius
- Qty stepper buttons: Circular 32px, 1px #d6dbde border
- Quantity number: 16/700 Text Black
- Price: Text Black, weight 600, 18px
- "Add to Order": Green Accent (#00754A) filled, white text, 50px pill

SIZE SELECTOR DETAIL:
- 4 cup icons in a horizontal row: Tall, Grande, Venti, Trenta
- Active state: `2px solid #00754A` circular ring around icon
- Icon: cup silhouette
- Label below icon: size name (16/700 White), fluid-ounce (13/400 Text White Soft)
- No ring on inactive; same typography
- Container padding: 16px internal

COMPONENT HIERARCHY:
[Scaffold]
  ├── appBar: [TransparentBackBar(cartBadge: 3)]
  ├── body: [SingleChildScrollView]
  │   └── [Column]
  │       ├── [ProductHeroBand(
  │       │     backgroundColor: #1E3932
  │       │   )]
  │       │   ├── [Breadcrumb("Menu / Beverages / Caffè Latte")]
  │       │   ├── [SizedBox(h: 16)]
  │       │   ├── [Text("CAFFÈ LATTE") style: productTitleWhite]
  │       │   ├── [SizedBox(h: 16)]
  │       │   ├── [ProductImage(image: url, height: 200)]
  │       │   ├── [SizedBox(h: 24)]
  │       │   └── [SizeSelector(
  │       │         sizes: variants,
  │       │         selectedId: variantId,
  │       │         onSelect: → updatePrice
  │       │       )]
  │       ├── [SizedBox(h: 0)]  // Segues into cream section
  │       ├── [Padding(16)]
  │       │   └── [Column]
  │       │       ├── [DescriptionCard(text)]
  │       │       ├── [SizedBox(h: 8)]
  │       │       ├── [NutritionSummary(cal, sugar, fat)]
  │       │       ├── [SizedBox(h: 8)]
  │       │       └── [ExpandableNutritionTable(
  │       │             ingredients, nutrients
  │       │           )]
  │       └── [SizedBox(h: 100)]  // Bottom action bar clearance
  ├── bottomSheet: [ProductActionBar(
  │     quantity, price,
  │     onDecrement, onIncrement,
  │     onAddToCart
  │   )]
  ├── floatingActionButton: [FrapCTA]
  └── bottomNavigationBar: [CFPVTabBar(currentIndex: 1)]
```

---

## 7. Order Screens

### 7.1 Checkout Screen (SC-11)

```
┌─────────────────────────────────────┐
│  [Status Bar: light content]        │
├─────────────────────────────────────┤
│  ← Checkout                         │
├─────────────────────────────────────┤
│  Neutral Warm (#f2f0eb) canvas      │
│                                     │
│  Pickup Store                       │ ← Section header
│  ┌─────────────────────────────┐    │ ← Store selector card
│  │ Cửa hàng CFPV Quận 1       │    │    (White, 12px radius)
│  │ 123 Nguyễn Huệ, Quận 1     │    │
│  │                             ›    │ ← Chevron
│  └─────────────────────────────┘    │
│                                     │
│  Order Summary                      │ ← Section header
│  ┌─────────────────────────────┐    │ ← White card
│  │ 1x Caffè Latte (Grande)     │    │
│  │                       55,000₫│   │
│  ├─────────────────────────────┤    │
│  │ 1x Chicken Sandwich         │    │
│  │                       49,000₫│   │
│  └─────────────────────────────┘    │
│                                     │
│  Order Notes                        │ ← Section header
│  ┌─────────────────────────────┐    │
│  │ Extra hot, less ice...     │    │ ← Text area (max 500 chars)
│  └─────────────────────────────┘    │
│                                     │
│  Payment Method                     │ ← Section header
│  ┌─────────────────────────────┐    │
│  │ ○ MoMo                      │    │ ← Radio button + logo
│  │   Pay with MoMo wallet      │    │
│  ├─────────────────────────────┤    │
│  │ ● VNPay                     │    │ ← Selected state
│  │   Pay with ATM/Visa/Master  │    │
│  └─────────────────────────────┘    │
│                                     │
│  // Post-MVP: Rewards redemption toggle appears here      │
│  ─────────────────────────────      │
│  Subtotal             104,000₫      │
│  Tax (10%)            10,400₫       │
│  Total              114,400₫        │
│                                     │
│  ┌──────────────────────────────┐   │
│  │        Place Order          │   │ ← 50px pill, full-width
│  └──────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  Tab Bar: HIDDEN during checkout    │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Section headers: Starbucks Green (#006241), H2 (24/400)
- Cards: White (#ffffff), 12px radius
- Store card: White, chevron in Text Black Soft
- Payment cards: White, radio button in Green Accent (selected) / #d6dbde (unselected)
- Payment logo: full-color MoMo / VNPay logos
- Selection highlight: Green Accent border on selected payment card
- Notes text area: White bg, 1px #d6dbde border, 12px radius, #00754A on focus
- Total line: Text Black, weight 600, 18px
- "Place Order": Green Accent (#00754A) filled, white text

COMPONENT HIERARCHY:
[Scaffold]
  ├── appBar: [BackAppBar(title: "Checkout")]
  ├── body: [SingleChildScrollView]
  │   └── [Padding(16)]
  │       └── [Column]
  │           ├── [SectionHeader("Pickup Store")]
  │           ├── [StoreSelectionCard(
  │           │     name: "Cửa hàng CFPV Quận 1",
  │           │     address: "123 Nguyễn Huệ, Quận 1",
  │           │     onTap: → store picker modal
  │           │   )]
  │           ├── [SizedBox(h: 24)]
  │           ├── [SectionHeader("Order Summary")]
  │           ├── [OrderSummaryCard(items)]
  │           ├── [SizedBox(h: 24)]
  │           ├── [SectionHeader("Order Notes")]
  │           ├── [NotesTextArea(maxLength: 500)]
  │           ├── [SizedBox(h: 24)]
  │           ├── [SectionHeader("Payment Method")]
  │           ├── [PaymentMethodSelector(
  │           │     methods: [
  │           │       {id: "momo", label: "MoMo", desc: "Pay with MoMo wallet"},
  │           │       {id: "vnpay", label: "VNPay", desc: "Pay with ATM/Visa/Master"}
  │           │     ],
  │           │     selected: "vnpay"
  │           │   )]
  │           └── [SizedBox(h: 100)]
  ├── bottomSheet: [CheckoutSummaryBar(
  │     subtotal, tax, total,
  │     onPlaceOrder: → submit order
  │   )]
  └── bottomNavigationBar: null  // Hidden
```

### 7.2 Order Confirmation Screen (SC-12)

```
┌─────────────────────────────────────┐
│  [Status Bar: dark content]         │
├─────────────────────────────────────┤
│                                     │
│                                     │
│           ┌─────────────────┐       │
│           │                 │       │
│           │     ✓ (green)   │       │ ← Animated checkmark
│           │     circle      │       │    in Green Accent
│           │                 │       │
│           └─────────────────┘       │
│                                     │
│      Order Confirmed!               │ ← SoDoSans 24/600, Green
│                                     │
│      Your order is being prepared   │
│                                     │
│   ┌─────────────────────────────┐   │ ← White card
│   │  Order #CFPV-20240607-0123 │   │
│   │  Cửa hàng CFPV Quận 1      │   │
│   │  Estimated pickup: 10 min  │   │
│   └─────────────────────────────┘   │
│                                     │
│   ┌─────────────────────────────┐   │ ← Order summary card
│   │ 1x Caffè Latte (Grande)     │   │
│   │                         55k │   │
│   │ 1x Chicken Sandwich         │   │
│   │                         49k │   │
│   ├─────────────────────────────┤   │
│   │ Total                114,400₫│  │
│   │ Payment:   VNPay ✓          │   │
│   └─────────────────────────────┘   │
│                                     │
│   ┌─────────────────────────────┐   │ ← Order progress
│   │  ● ─── ○ ─── ○  ─── ○      │   │
│   │Order Ready  │Prepd │  Picked│   │
│   │Placed    for  │      Up    │   │
│   │            pickup│          │    │
│   └─────────────────────────────┘   │
│                                     │
│   ┌─────────────────────────────┐   │
│   │     View Order             │   │ ← Outlined pill
│   └─────────────────────────────┘   │
│                                     │
│   ┌─────────────────────────────┐   │
│   │     Back to Menu           │   │ ← Green Accent filled pill
│   └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  Tab Bar: HIDDEN during checkout    │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Checkmark: Green Accent (#00754A), animated draw
- "Order Confirmed!": Starbucks Green (#006241), 24/600
- Subtitle: Text Black Soft (rgba(0,0,0,0.58)), 16/400
- Cards: White (#ffffff), 12px radius
- Order ID: Text Black, 16/600
- Store/ETA: Text Black Soft, 14/400
- Progress dots: Active = Green Accent (#00754A), Inactive = #d6dbde
- "View Order": Outlined pill, Text Black border
- "Back to Menu": Green Accent filled pill, white text

ANIMATION:
- Checkmark: draw animation (0.6s stroke-dashoffset)
- Cards: slide up with staggered 100ms delay each
- Duration: ~1s total animation before user can interact

COMPONENT HIERARCHY:
[Scaffold]
  ├── body: [SingleChildScrollView]
  │   └── [Padding(16)]
  │       └── [Column(crossAxisAlignment: center)]
  │           ├── [SizedBox(h: 48)]
  │           ├── [AnimatedCheckmark(size: 80)]
  │           ├── [SizedBox(h: 24)]
  │           ├── [Text("Order Confirmed!") style: h1Green]
  │           ├── [Text("Your order is being prepared") style: bodySoft]
  │           ├── [SizedBox(h: 32)]
  │           ├── [ConfirmationInfoCard(order)]
  │           ├── [SizedBox(h: 16)]
  │           ├── [OrderSummaryCard(order)]
  │           ├── [SizedBox(h: 16)]
  │           ├── [OrderProgressBar(status)]
  │           ├── [SizedBox(h: 32)]
  │           ├── [OutlinedPillButton("View Order")]
  │           ├── [SizedBox(h: 12)]
  │           └── [PrimaryPillButton("Back to Menu")]
  └── bottomNavigationBar: null  // Hidden
```

### 7.3 Order History Screen (SC-13)

```
┌─────────────────────────────────────┐
│  [Status Bar: transparent]          │
├─────────────────────────────────────┤
│  ← Profile                          │
├─────────────────────────────────────┤
│  Neutral Warm (#f2f0eb)             │
│                                     │
│  Today                              │ ← Date separator
│  ┌─────────────────────────────┐    │ ← White card row
│  │ Cửa hàng CFPV Quận 1       │    │
│  │ #CFPV-20240607-0123        │    │
│  │ Jun 7, 2026 · 08:30        │    │
│  │                 114,400₫   │    │
│  │ Completed              [🔄]│    │ ← Status badge + reorder
│  └─────────────────────────────┘    │
│                                     │
│  Yesterday                          │ ← Date separator
│  ┌─────────────────────────────┐    │
│  │ Cửa hàng CFPV Quận 1       │    │
│  │ #CFPV-20240606-0098        │    │
│  │ Jun 6, 2026 · 12:15        │    │
│  │                  55,000₫   │    │
│  │ Completed              [🔄]│    │
│  └─────────────────────────────┘    │
│                                     │
│  Earlier                            │ ← Date separator
│  ┌─────────────────────────────┐    │
│  │ Cửa hàng CFPV Quận 1       │    │
│  │ #CFPV-20240605-0075        │    │
│  │ Jun 5, 2026 · 09:00        │    │
│  │                  89,000₫   │    │
│  │ Completed              [🔄]│    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ...                         │    │ ← More items paginated
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│  Tab Bar [🏠][📋][🛒][⭐][👤]    │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Date separators: Starbucks Green (#006241), 14/600 SoDoSans
- Order rows: White (#ffffff), 12px radius, whisper shadow
- Store/order ID: Text Black, 16/600
- Date/time: Text Black Soft, 13/400
- Price: Text Black, weight 600, 16px
- Status badge "Completed": Green Accent (#00754A) filled, white text, 8px radius
- Status badge "Cancelled": Red (#c82014) filled, white text
- Reorder icon: Green Accent (#00754A) circular icon

COMPONENT HIERARCHY:
[Scaffold]
  ├── appBar: [BackAppBar(title: "Order History")]
  ├── body: [ListView]
  │   └── [DateGroupedList]
  │       ├── ["Today"]
  │       │   └── [OrderHistoryRow(order, onReorder)] × N
  │       ├── ["Yesterday"]
  │       │   └── [OrderHistoryRow] × N
  │       └── ["Earlier"]
  │           └── [OrderHistoryRow] × N
  ├── floatingActionButton: [FrapCTA]
  └── bottomNavigationBar: [CFPVTabBar(currentIndex: 4)]

┌─── OrderHistoryRow Detail ──────────┐
│  [InkWell(onTap: → detail)]         │
│    └── [Padding(16)]                │
│        └── [Row]                    │
│            ├── [Column(flex: 1)]    │
│            │   ├── [Text(storeName) │
│            │   │     style: bold]   │
│            │   ├── [Text(orderCode) │
│            │   │     style: soft]   │
│            │   └── [Text(dateTime)  │
│            │         style: micro]  │
│            └── [Column]             │
│                ├── [Text(price)     │
│                │     style: bold]   │
│                ├── [SizedBox(h: 4)] │
│                └── [StatusBadge(    │
│                      label: "Completed",
│                      color: #00754A
│                    )]               │
│  [ReorderButton(onTap)]             │
└─────────────────────────────────────┘
```

### 7.4 Order Detail Screen (SC-14)

```
┌─────────────────────────────────────┐
│  [Status Bar: transparent]          │
├─────────────────────────────────────┤
│  ← Order History                    │
├─────────────────────────────────────┤
│  Neutral Warm (#f2f0eb)             │
│                                     │
│  ┌─────────────────────────────┐    │ ← Order header card
│  │ #CFPV-20240607-0123         │    │
│  │ Cửa hàng CFPV Quận 1        │    │
│  │ Jun 7, 2026 · 08:30        │    │
│  │                             │    │
│  │ Payment: VNPay ● Completed  │    │ ← Green dot
│  │ Status: Ready for pickup    │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │ ← Items card
│  │ 1x Caffè Latte (Grande)     │    │
│  │                        55k │    │
│  ├─────────────────────────────┤    │
│  │ 1x Chicken Sandwich         │    │
│  │                        49k │    │
│  ├─────────────────────────────┤    │
│  │ Subtotal           104,000₫│    │
│  │ Tax (10%)           10,400₫│    │
│  │ Total              114,400₫│    │
│  └─────────────────────────────┘    │
│                                     │
│  Order Status                       │ ← Section header
│  ┌─────────────────────────────┐    │ ← Timeline card
│  │ ● Order Placed   08:30 AM  │    │
│  │ ● Confirmed      08:31 AM  │    │
│  │ ● Preparing      08:35 AM  │    │
│  │ ○ Ready for Pickup   —     │    │ ← Current = pulsing
│  │ ○ Completed            —   │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌──────────────────────────────┐   │
│  │      Reorder                │   │ ← Green Accent pill
│  └──────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  Tab Bar: HIDDEN on Order Detail    │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Header card: White (#ffffff), 12px radius
- Items card: White (#ffffff)
- Status timeline: Hairline connections between dots
  - Completed step: Green Accent dot + line
  - Current step: Green Accent dot, pulsing
  - Future step: #d6dbde dot + line
- Timeline text: Text Black (16/400) — completed, Text Black Soft (14/400) — future
- "Reorder": Green Accent filled pill, white text
- Section header: Starbucks Green (#006241), H2

TIMELINE COMPONENT:
```
 ● ─── ● ─── ● ─── ○ ─── ○
Order Confirmed  Preparing   Ready    Completed
                for
              pickup
```
- Dot size: 12px
- Line width: 2px
- Vertical layout with text beside each dot

COMPONENT HIERARCHY:
[Scaffold]
  ├── appBar: [BackAppBar(title: "Order Detail")]
  ├── body: [SingleChildScrollView]
  │   └── [Padding(16)]
  │       └── [Column]
  │           ├── [OrderHeaderCard(order)]
  │           ├── [SizedBox(h: 16)]
  │           ├── [OrderItemsCard(items, totals)]
  │           ├── [SizedBox(h: 24)]
  │           ├── [SectionHeader("Order Status")]
  │           ├── [SizedBox(h: 12)]
  │           ├── [OrderTimeline(statuses)]
  │           ├── [SizedBox(h: 32)]
  │           └── [PrimaryPillButton("Reorder")]
  └── bottomNavigationBar: null  // Hidden
```

---

## 8. Profile Sub-Screens

### 8.1 Edit Profile Screen (SC-17)

```
┌─────────────────────────────────────┐
│  [Status Bar: transparent]          │
├─────────────────────────────────────┤
│  ← Profile                          │
├─────────────────────────────────────┤
│  Neutral Warm (#f2f0eb)             │
│                                     │
│       ┌──────────────┐              │ ← Avatar with camera
│       │              │  📷         │    overlay (editable)
│       │   Avatar     │              │
│       │   120px      │              │
│       │              │              │
│       └──────────────┘              │
│       Tap to change photo           │ ← Text Black Soft, 14px
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Full name                   │  │ ← Floating label
│   │ Nguyen Thao                 │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Email address               │  │
│   │ thao.nguyen@email.com       │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Phone number                │  │ ← Read-only, gray bg
│   │ +84 123 456 789             │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │      Save Changes           │  │ ← Green Accent pill
│   └──────────────────────────────┘  │
│                                     │
│                [Cancel]             │ ← Text link
│                                     │
├─────────────────────────────────────┤
│  Tab Bar: HIDDEN on Edit Profile    │
└─────────────────────────────────────┘

COLORS/TYPOGRAPHY: Same form patterns as Registration (floating label inputs).
Phone field: Neutral Cool (#f9f9f9) background with #d6dbde border to indicate read-only.
```

### 8.2 Settings Screen (SC-18)

```
┌─────────────────────────────────────┐
│  [Status Bar: transparent]          │
├─────────────────────────────────────┤
│  ← Profile                          │
├─────────────────────────────────────┤
│  Neutral Warm (#f2f0eb)             │
│                                     │
│  Notifications                      │ ← Section header (H2)
│  ┌─────────────────────────────┐    │ ← White card
│  │ Order updates        [●───] │    │ ← Toggle ON (Green)
│  ├─────────────────────────────┤    │
│  │ Rewards & points     [●───] │    │
│  ├─────────────────────────────┤    │
│  │ Promotions & offers  [○───] │    │ ← Toggle OFF (gray)
│  └─────────────────────────────┘    │
│                                     │
│  Account                            │ ← Section header (H2)
│  ┌─────────────────────────────┐    │ ← White card
│  │ Change Password          ›  │    │
│  ├─────────────────────────────┤    │
│  │ Delete Account            ›  │    │ ← Red text (post-MVP)
│  └─────────────────────────────┘    │
│                                     │
│  App Version 1.0.0                  │ ← Bottom, Text Black Soft
│                                     │
├─────────────────────────────────────┤
│  Tab Bar: HIDDEN on Settings        │
└─────────────────────────────────────┘

COLORS:
- Canvas: Neutral Warm (#f2f0eb)
- Section headers: Starbucks Green (#006241), H2
- Cards: White (#ffffff), 12px radius
- Toggle ON: Green Accent (#00754A) track, white thumb
- Toggle OFF: #d6dbde track, white thumb
- "Delete Account": Red (#c82014) text
- Chevrons: Text Black Soft
- App version: Text Black Soft, 13px

TOGGLE SWITCH DETAIL:
- Height: 30px
- Track width: 50px
- Thumb: 24px circle, white
- Active track: Green Accent (#00754A)
- Inactive track: #d6dbde
```

### 8.3 Change Password Screen (SC-19)

```
┌─────────────────────────────────────┐
│  [Status Bar: transparent]          │
├─────────────────────────────────────┤
│  ← Settings                         │
├─────────────────────────────────────┤
│  Neutral Warm (#f2f0eb)             │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Current password            │  │ ← Floating label
│   │                         [👁] │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ New password                │  │
│   │                         [👁] │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │ Confirm new password        │  │
│   │                         [👁] │  │
│   └──────────────────────────────┘  │
│                                     │
│   ┌──────────────────────────────┐  │
│   │      Update Password        │  │ ← Green Accent pill
│   └──────────────────────────────┘  │
│                                     │
├─────────────────────────────────────┤
│  Tab Bar: HIDDEN on Change Password │
└─────────────────────────────────────┘

COLORS/TYPOGRAPHY: Same form patterns as auth screens.
```

---

## 9. Component Library

### 9.1 Button Variants

```
┌─────────────────────────────────────────────────────┐
│  BUTTON VARIANTS                                     │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────────────────────────────┐            │
│  │  Primary Filled (Green Accent)      │            │
│  │  ┌──────────────────────────┐       │            │
│  │  │     Explore Menu        │       │            │
│  │  └──────────────────────────┘       │            │
│  │  bg: #00754A, text: #ffffff         │            │
│  │  border: 1px #00754A               │            │
│  │  50px pill, 7px 16px padding        │            │
│  │  Font: 16px, 600, -0.01em          │            │
│  │  Active: scale(0.95), 0.2s ease    │            │
│  └──────────────────────────────────────┘            │
│                                                      │
│  ┌──────────────────────────────────────┐            │
│  │  Full-width Primary                  │            │
│  │  ┌──────────────────────────────────┐│            │
│  │  │         Checkout                ││            │
│  │  └──────────────────────────────────┘│            │
│  │  Same as Primary Filled but         │            │
│  │  width: 100% (match parent)        │            │
│  └──────────────────────────────────────┘            │
│                                                      │
│  ┌──────────────────────────────────────┐            │
│  │  Primary Outlined (Green)            │            │
│  │  ┌──────────────────────────┐       │            │
│  │  │      Start an Order     │       │            │
│  │  └──────────────────────────┘       │            │
│  │  bg: transparent, text: #00754A     │            │
│  │  border: 1px #00754A               │            │
│  │  Same radius/padding/scale          │            │
│  └──────────────────────────────────────┘            │
│                                                      │
│  ┌──────────────────────────────────────┐            │
│  │  Green-on-Green Inverted             │            │
│  │  ┌──────────────────────────┐       │            │
│  │  │     See Spring Menu     │       │            │
│  │  └──────────────────────────┘       │            │
│  │  bg: #ffffff, text: #00754A        │            │
│  │  border: 1px #ffffff               │            │
│  │  Used on House Green bands          │            │
│  └──────────────────────────────────────┘            │
│                                                      │
│  ┌──────────────────────────────────────┐            │
│  │  Outlined on Dark                    │            │
│  │  ┌──────────────────────────┐       │            │
│  │  │     Learn More          │       │            │
│  │  └──────────────────────────┘       │            │
│  │  bg: transparent, text: #ffffff     │            │
│  │  border: 1px #ffffff               │            │
│  │  Used on House Green bands          │            │
│  └──────────────────────────────────────┘            │
│                                                      │
│  ┌──────────────────────────────────────┐            │
│  │  Dark Outlined (Sign In)             │            │
│  │  ┌──────────────────────────┐       │            │
│  │  │        Sign In          │       │            │
│  │  └──────────────────────────┘       │            │
│  │  bg: transparent, text: rgba(0,0,0  │            │
│  │               0.87)                 │            │
│  │  border: 1px rgba(0,0,0,0.87)      │            │
│  │  14px, 600                          │            │
│  └──────────────────────────────────────┘            │
│                                                      │
│  ┌──────────────────────────────────────┐            │
│  │  Floating Frap CTA                   │            │
│  │         ┌─────┐                     │            │
│  │         │  🛒  │                     │            │
│  │         └─────┘                     │            │
│  │  56px circle, #00754A fill          │            │
│  │  White icon centered                │            │
│  │  Shadow: 0 0 6px rgba(0,0,0,0.24)  │            │
│  │          + 0 8px 12px rgba(0,0,0,  │            │
│  │                   0.14)             │            │
│  │  Fixed bottom-right, -0.8rem offset │            │
│  │  Active: ambient shadow fades       │            │
│  └──────────────────────────────────────┘            │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 9.2 Card Variants

```
┌─────────────────────────────────────────────────────┐
│  CARD VARIANTS                                       │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Content Card (default)                              │
│  ┌──────────────────────────────────────────┐        │
│  │  12px border-radius                      │        │
│  │  bg: #ffffff                             │        │
│  │  Shadow: 0 0 0.5px rgba(0,0,0,0.14)    │        │
│  │         0 1px 1px rgba(0,0,0,0.24)     │        │
│  │  Padding: 16px (--space-3)              │        │
│  └──────────────────────────────────────────┘        │
│                                                      │
│  Category Tile                                       │
│  ┌──────────────────────┐                            │
│  │  12px border-radius   │                            │
│  │  bg: #ffffff          │                            │
│  │  Image: full-bleed    │                            │
│  │  Label overlay bottom  │                            │
│  │  Height: ~160px       │                            │
│  └──────────────────────┘                            │
│                                                      │
│  Product Card                                        │
│  ┌──────────────────────┐                            │
│  │  12px border-radius   │                            │
│  │  bg: #ffffff          │                            │
│  │  Image: square,       │                            │
│  │  soft drop shadow     │                            │
│  │  Name + price below   │                            │
│  │  Padding: 0/8px       │                            │
│  └──────────────────────┘                            │
│                                                      │
│  Rewards Status Card (post-MVP)                      │
│  ┌──────────────────────┐                            │
│  │  House Green (#1E3932)│                            │
│  │  12px radius          │                            │
│  │  Color header ring   │                            │
│  │  Level badge + title  │                            │
│  │  Benefits list        │                            │
│  └──────────────────────┘                            │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 9.3 Input Variants

```
┌─────────────────────────────────────────────────────┐
│  INPUT VARIANTS                                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Floating Label Input                                │
│  ┌────────────────────────────────┐                  │
│  │  Label animates above border   │                  │
│  │  Default: label inside 1.6rem  │                  │
│  │  Active: label above 1.3rem    │                  │
│  │  Border: 1px #d6dbde           │                  │
│  │  Focus: 2px #00754A            │                  │
│  │  Valid bg: rgba(#d4e9e2, 33%)  │                  │
│  │  Invalid bg: rgba(#c82014, 5%) │                  │
│  │  Padding: 12px field           │                  │
│  │  Transition: 0.3s cubic-       │                  │
│  │    bezier(0.32,2.32,0.61,0.27) │                  │
│  └────────────────────────────────┘                  │
│                                                      │
│  OTP Input (6-digit)                                │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐                    │
│  │_ │ │_ │ │_ │ │_ │ │_ │ │_ │                    │
│  └──┘ └──┘ └──┘ └──┘ └──┘ └──┘                    │
│  48×56px each, #d6dbde border                       │
│  Filled: #00754A border + text                      │
│  Auto-advance on digit entry                        │
│                                                      │
│  Numeric Stepper                                     │
│     [−]    2    [+]                                  │
│  ┌────┐ ┌────┐ ┌────┐                               │
│  │ −  │ │  2 │ │ +  │                               │
│  └────┘ └────┘ └────┘                               │
│  32×32px circular buttons                            │
│  1px #d6dbde border                                  │
│  Count: 16/700 Text Black centered                   │
│                                                      │
│  Toggle Switch                                       │
│  [●────]  ON (Green Accent)                         │
│  [○────]  OFF (#d6dbde)                             │
│  Height: 30px, Track: 50px                          │
│  Thumb: 24px white circle                           │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 9.4 Navigation Components

```
┌─────────────────────────────────────────────────────┐
│  NAVIGATION COMPONENTS                               │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Bottom Tab Bar                                      │
│  ┌──────────────────────────────────────────┐        │
│  │   🏠      📋      🛒      ⭐      👤      │        │
│  │  Home    Menu    Cart   Rewards  Profile  │        │
│  └──────────────────────────────────────────┘        │
│  Height: 56px (iOS) / 50px (Android)                │
│  bg: #ffffff                                         │
│  Active: Green Accent (#00754A)                     │
│  Inactive: Text Black Soft (rgba(0,0,0,0.58))       │
│  Label: SoDoSans 11px 400                           │
│  Cart badge: Red dot with count                      │
│  Shadow: 0 -1px 3px rgba(0,0,0,0.06)               │
│                                                      │
│  App Bar (default)                                   │
│  ┌──────────────────────────────────────────┐        │
│  │  ← Title                     🛒    ⭐    │        │
│  └──────────────────────────────────────────┘        │
│  Height: 56px                                       │
│  bg: #ffffff                                         │
│  Title: SoDoSans 18px 600 Text Black                │
│  Back chevron: Green Accent (#00754A)               │
│  Icons: Text Black Soft                         │
│                                                      │
│  Subcategory Chips (horizontal scroll)              │
│  ┌──────────┐ ┌──────────┐ ┌───────┐ ┌───┐        │
│  │  All     │ │Hot Coffee│ │ Iced │ │...│        │
│  └──────────┘ └──────────┘ └───────┘ └───┘        │
│  Active: Green Accent fill, white text              │
│  Inactive: White fill, Text Black Soft border       │
│  Radius: 50px pill                                  │
│  Height: 32px                                       │
│  Padding: 12px horizontal                          │
│                                                      │
│  Product Size Selector                               │
│  (☕)    (☕●)    (☕)    (☕)                         │
│  Tall   Grande  Venti  Trenta                       │
│  Active: green ring 2px #00754A                     │
│  Labels: White 16/700, fluid-ounce 13/400           │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 9.5 Feedback & Status Components

```
┌─────────────────────────────────────────────────────┐
│  FEEDBACK & STATUS COMPONENTS                          │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Status Badge                                        │
│  ┌──────────────┐  ┌──────────────┐                 │
│  │  Completed   │  │  Cancelled   │                 │
│  └──────────────┘  └──────────────┘                 │
│  #00754A fill       #c82014 fill                    │
│  White text 12px    White text 12px                 │
│  8px radius         8px radius                      │
│  Padding: 4px 8px   Padding: 4px 8px               │
│                                                      │
│  Order Status Timeline                               │
│  ●────●────●────○────○                              │
│  Completed dots: Green Accent                       │
│  Current dot: Green Accent + pulsing                │
│  Future dots: #d6dbde                                │
│  Lines: 2px, same color as previous dot             │
│                                                      │
│  Loading State (Skeleton)                            │
│  ┌──────────────────────────────┐                   │
│  │ ░░░░░░░░░░░░░░░░░░░░░░░░░░ │                   │
│  │ ░░░░░░░░░░░░                 │                   │
│  └──────────────────────────────┘                   │
│  Shimmer animation: animate opacities               │
│  Base: Neutral Cool (#f9f9f9)                       │
│                                                      │
│  Empty State                                         │
│  ┌──────────────────────────────┐                   │
│  │  Large centered illustration │                   │
│  │  Headline text              │                   │
│  │  Body text explaining       │                   │
│  │  CTA button to resolve      │                   │
│  └──────────────────────────────┘                   │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

## 10. Micro-Interactions & Animations

### 10.1 Universal Button Feedback

| Trigger | Effect | Duration |
|---------|--------|----------|
| Touch down | `transform: scale(0.95)` | Immediate |
| Touch up | `transform: scale(1.0)` | 0.2s ease |
| Disabled | `opacity: 0.5`, no interaction | Instant |

### 10.2 Screen Transitions

| Transition | Use | Detail |
|------------|-----|--------|
| Fade | Splash → next screen | 300ms ease-out |
| Slide right → left | Push navigation (forward) | 350ms standard curve |
| Slide left → right | Pop navigation (back) | 350ms standard curve |
| Fade + slide up | Modal presentation | 400ms ease-out |
| None | Tab switch | Instant; tab bar stays on screen |

### 10.3 Component Animations

| Component | Animation | Detail |
|-----------|-----------|--------|
| Floating label input | Label translates up and scales down | 0.3s cubic-bezier(0.32, 2.32, 0.61, 0.27) — springy overshoot |
| Checkbox/radio | Icon scales with spring curve | Same cubic-bezier as above |
| Accordion (nutrition) | Height expands/collapses | 300ms cubic-bezier(0.25, 0.46, 0.45, 0.94) |
| Image fade-in | Opacity on load | 0.3s ease-in |
| Snackbar (add to cart) | Slides up from bottom | 300ms ease-out, auto-dismiss after 2s |
| Frap CTA press | Scale + shadow collapse | 0.2s ease; ambient shadow → 0 |
| Order confirmation | Checkmark draw animation | 0.6s stroke-dashoffset |
| Order confirmation cards | Slide up staggered (100ms delay each) | 400ms ease-out |
| Toast on success/error | Slide down from top | 300ms ease-out, dismiss after 3s |
| Page indicator dot | Scale active dot (×1.3) | 200ms ease |
| Skeleton shimmer | Linear gradient sweep | 1.5s infinite loop |
| Status badge pulse (current) | Opacity 0.6 → 1.0 | 1s infinite loop |
| Pull-to-refresh | Circular spinner in Green Accent | Rotates 360° over 800ms |

### 10.4 Page Transition Flow (Checkout → Confirmation)

```
1. User taps "Place Order"
2. CTA shows loading spinner (replaces text)
3. All inputs become disabled
4. API call: POST /api/v1/orders
5. On success → payment redirect (MoMo/VNPay webview)
6. Payment completes → redirect back to app
7. API call: POST /api/v1/orders/:id/confirm-payment
8. On payment success:
   a. Full-screen fade to white (200ms)
   b. Checkmark draw animation (600ms)
   c. Cards slide up staggered (100ms apart)
   d. User can now interact
```

---

## 11. Design Tokens Summary

### 11.1 Color Tokens

```dart
// GREEN SYSTEM
CFPVColors.starbucksGreen  = Color(0xFF006241);  // H1, brand headings
CFPVColors.greenAccent     = Color(0xFF00754A);  // CTAs, Frap button
CFPVColors.houseGreen      = Color(0xFF1E3932);  // Feature bands, footer
CFPVColors.greenUplift     = Color(0xFF2B5148);  // Decorative accents
CFPVColors.greenLight      = Color(0xFFD4E9E2);  // Form valid tint

// WARM NEUTRAL SYSTEM
CFPVColors.neutralWarm     = Color(0xFFF2F0EB);  // Page canvas
CFPVColors.ceramic         = Color(0xFFEDEBE9);  // Zone separators
CFPVColors.neutralCool     = Color(0xFFF9F9F9);  // Dropdown bg, utility
CFPVColors.white           = Color(0xFFFFFFFF);  // Card bg, modals
CFPVColors.black           = Color(0xFF000000);  // Auth bar CTA

// TEXT COLORS
CFPVColors.textBlack       = Color.fromRGBO(0, 0, 0, 0.87);     // Primary text
CFPVColors.textBlackSoft   = Color.fromRGBO(0, 0, 0, 0.58);     // Secondary text
CFPVColors.textWhite       = Color.fromRGBO(255, 255, 255, 1);   // Text on dark
CFPVColors.textWhiteSoft   = Color.fromRGBO(255, 255, 255, 0.70);// Secondary on dark
CFPVColors.rewardsGreen    = Color(0xFF33433D);  // Rewards text only

// ACCENT
CFPVColors.gold            = Color(0xFFCBA258);  // Rewards only
CFPVColors.goldLight       = Color(0xFFDFC49D);  // Rewards bg
CFPVColors.red             = Color(0xFFC82014);  // Error / destructive
CFPVColors.yellow          = Color(0xFFFBBC05);  // Warning (legacy)

// BORDERS
CFPVColors.inputBorder     = Color(0xFFD6DBDE);  // Input default
CFPVColors.hairline        = Color(0xFFE7E7E7);  // Card separators
```

### 11.2 Typography Tokens

```dart
CFPVTypography.display      = TextStyle(fontFamily: 'SoDoSans', fontSize: 80, fontWeight: 600, height: 1.2, letterSpacing: -0.16);
CFPVTypography.jumbo        = TextStyle(fontFamily: 'SoDoSans', fontSize: 58, fontWeight: 600, height: 1.2, letterSpacing: -0.16);
CFPVTypography.heroLarge    = TextStyle(fontFamily: 'SoDoSans', fontSize: 45, fontWeight: 600, height: 1.2, letterSpacing: -0.16);
CFPVTypography.h1           = TextStyle(fontFamily: 'SoDoSans', fontSize: 24, fontWeight: 600, height: 36/24, letterSpacing: -0.16);
CFPVTypography.h2           = TextStyle(fontFamily: 'SoDoSans', fontSize: 24, fontWeight: 400, height: 36/24, letterSpacing: -0.16);
CFPVTypography.bodyLarge    = TextStyle(fontFamily: 'SoDoSans', fontSize: 19, fontWeight: 400, height: 1.75, letterSpacing: -0.16);
CFPVTypography.body         = TextStyle(fontFamily: 'SoDoSans', fontSize: 16, fontWeight: 400, height: 1.5, letterSpacing: -0.01em);
CFPVTypography.small        = TextStyle(fontFamily: 'SoDoSans', fontSize: 14, fontWeight: 400, height: 1.5, letterSpacing: -0.01em);
CFPVTypography.smallBold    = TextStyle(fontFamily: 'SoDoSans', fontSize: 14, fontWeight: 600, height: 1.5, letterSpacing: -0.01em);
CFPVTypography.micro        = TextStyle(fontFamily: 'SoDoSans', fontSize: 13, fontWeight: 400, height: 1.5, letterSpacing: -0.01em);
CFPVTypography.buttonLabel  = TextStyle(fontFamily: 'SoDoSans', fontSize: 16, fontWeight: 600, height: 1.2, letterSpacing: -0.01em);
CFPVTypography.buttonSmall  = TextStyle(fontFamily: 'SoDoSans', fontSize: 14, fontWeight: 600, height: 1.2, letterSpacing: -0.01em);

// Substitute fonts (SoDoSans is proprietary):
// Use Inter or Manrope as open-source substitute
// See DESIGN.md §3 for fallback chain
```

### 11.3 Spacing Tokens

```dart
CFPVSpacing.space1  = 4.0;   // --space-1: tightest inline padding
CFPVSpacing.space2  = 8.0;   // --space-2: small gap
CFPVSpacing.space3  = 16.0;  // --space-3: default, card padding, outer gutter
CFPVSpacing.space4  = 24.0;  // --space-4: section inner spacing
CFPVSpacing.space5  = 32.0;  // --space-5: major between-section
CFPVSpacing.space6  = 40.0;  // --space-6: large gaps
CFPVSpacing.space7  = 48.0;  // --space-7: section-to-section
CFPVSpacing.space8  = 56.0;  // --space-8: very large, Frap height
CFPVSpacing.space9  = 64.0;  // --space-9: widest section padding
```

### 11.4 Elevation Tokens

```dart
CFPVElevation.card        = [
  BoxShadow(offset: Offset(0, 0), blurRadius: 0.5, color: Color.fromRGBO(0, 0, 0, 0.14)),
  BoxShadow(offset: Offset(0, 1), blurRadius: 1, color: Color.fromRGBO(0, 0, 0, 0.24)),
];

CFPVElevation.nav        = [
  BoxShadow(offset: Offset(0, 1), blurRadius: 3, color: Color.fromRGBO(0, 0, 0, 0.1)),
  BoxShadow(offset: Offset(0, 2), blurRadius: 2, color: Color.fromRGBO(0, 0, 0, 0.06)),
  BoxShadow(offset: Offset(0, 0), blurRadius: 2, color: Color.fromRGBO(0, 0, 0, 0.07)),
];

CFPVElevation.frapBase    = BoxShadow(offset: Offset(0, 0), blurRadius: 6, color: Color.fromRGBO(0, 0, 0, 0.24));

CFPVElevation.frapAmbient = BoxShadow(offset: Offset(0, 8), blurRadius: 12, color: Color.fromRGBO(0, 0, 0, 0.14));
```

### 11.5 Radius Tokens

```dart
CFPVRadius.card          = 12.0;   // Cards, modals
CFPVRadius.button        = 50.0;   // All buttons (pill)
CFPVRadius.circular      = 999.0;  // Icons, Frap, avatar
CFPVRadius.input         = 4.0;    // Input fields, outlined selectors
```

---

*End of Design Phase Document*
*Generated: June 7, 2026*
*Next: Implementation Phase (Flutter + NestJS)*
