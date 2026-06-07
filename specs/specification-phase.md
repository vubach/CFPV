# CFPV — Specification Phase

> **Project:** CFPV (Cross-Platform Food & Beverage Application)
> **Status:** Draft Specification
> **Target Market:** Vietnam (primary)
> **App Model:** Single-brand F&B chain (Starbucks-inspired)

---

## Table of Contents

1. [Product Analysis](#1-product-analysis)
2. [Functional Requirements](#2-functional-requirements)
3. [Non-Functional Requirements](#3-non-functional-requirements)
4. [Screen Inventory](#4-screen-inventory)
5. [Mobile Navigation Specification](#5-mobile-navigation-specification)
6. [Data Model Proposal](#6-data-model-proposal)
7. [API Inventory](#7-api-inventory)
8. [Risks and Open Questions](#8-risks-and-open-questions)
9. [Recommended MVP Scope Validation](#9-recommended-mvp-scope-validation)

---

## 1. Product Analysis

### 1.1 Project Summary

CFPV is a cross-platform mobile application for a single-brand Food & Beverage chain operating in Vietnam. The app enables customers to browse the menu, customize and order beverages and food items, earn and redeem loyalty points, manage their profile, and view order history. The app is inspired by the Starbucks mobile experience — from its warm cream-and-green visual identity to its ordering and rewards flow.

**Platforms:** Android, iOS  
**Frontend:** Flutter (Riverpod, GoRouter, Dio)  
**Backend:** NestJS (Modular Monolith)  
**Database:** PostgreSQL  
**Cache:** Redis  
**Payments:** VNPay, MoMo  
**Notifications:** Firebase Cloud Messaging (FCM)  
**Auth:** JWT (Access Token: 15 min, Refresh Token: 30 days)

### 1.2 Business Goals

| Goal | Description | Success Metric |
|------|-------------|----------------|
| **Increase digital orders** | Enable customers to browse, customize, and order via mobile, reducing in-store queue friction | ≥30% of total orders placed via app within 6 months of launch |
| **Build loyalty & retention** | Implement a points-based rewards program that incentivizes repeat visits | ≥40% monthly active user retention at 3 months |
| **Reduce checkout friction** | Integrated VNPay and MoMo payments for fast, local-optimized checkout | ≤90 second average checkout completion time |
| **Brand consistency** | Deliver a warm, premium brand experience consistent with the physical café environment | App Store rating ≥4.5 stars |
| **Data-driven menu decisions** | Capture ordering preferences, popular items, and customization patterns to inform menu strategy | Analytics pipeline operational at launch |

### 1.3 User Personas

#### Persona 1: Thao — The Daily Regular

| Attribute | Detail |
|-----------|--------|
| **Age** | 25–34 |
| **Occupation** | Office professional in Ho Chi Minh City |
| **Tech Comfort** | High — uses mobile apps daily for food delivery, banking, and transport |
| **Behavior** | Visits the café 4–5 times per week before work or during lunch. Usually orders the same drink (iced latte) but occasionally tries seasonal specials. |
| **Pain Points** | Waiting in line during morning rush. Forgetting loyalty card. Not knowing when new menu items launch. |
| **Needs** | Fast reordering of saved favorites. Push notifications for promotions. Easy loyalty point tracking. |
| **MVP Relevance** | Core user — will use Menu, Cart, Checkout, Rewards, and Profile daily |

#### Persona 2: Minh — The Rewards Hunter

| Attribute | Detail |
|-----------|--------|
| **Age** | 22–30 |
| **Occupation** | University student / part-time worker |
| **Tech Comfort** | High — heavy user of MoMo, ShopeeFood, and social media |
| **Behavior** | Visits 1–2 times per week, usually with friends. Orders based on what earns the most points or current promotions. Shares rewards progress on social media. |
| **Pain Points** | Unclear how many points earned per order. Slow to reach reward thresholds. |
| **Needs** | Clear points-per-order visibility. Push notifications when points are earned or about to expire. Ability to redeem points easily at checkout. |
| **MVP Relevance** | Heavy Rewards feature user — will engage with Points Balance and checkout redemption |

#### Persona 3: Chi — The Weekend Browser

| Attribute | Detail |
|-----------|--------|
| **Age** | 28–45 |
| **Occupation** | Parent, works in retail |
| **Tech Comfort** | Moderate — comfortable with familiar apps but wary of new payment methods |
| **Behavior** | Visits on weekends with family. Browses the menu slowly, reads descriptions and nutrition info. Sometimes orders for pickup while running errands. |
| **Pain Points** | Menu too large to browse easily on mobile. Unsure about nutritional content. Prefers to pay by bank transfer or VNPay rather than credit card. |
| **Needs** | Clear category browsing. High-quality product photos with descriptions. Simple, trusted payment flow. |
| **MVP Relevance** | Secondary user — values Menu browsing experience and simple checkout |

#### Persona 4: Lan — The Manager

| Attribute | Detail |
|-----------|--------|
| **Age** | 30–50 |
| **Occupation** | Café/store manager |
| **Tech Comfort** | Low–moderate — uses apps for operational tasks but not an everyday app user |
| **Behavior** | Manages store operations. Needs visibility into orders. Coordinates with kitchen during rush. |
| **Pain Points** | No insight into mobile order volume before it hits the kitchen. Difficult to communicate stockouts to the app. |
| **Needs** | Order management dashboard (backend only). Real-time order notifications. Ability to mark items as sold out. |
| **MVP Relevance** | Backend-facing only in MVP; no manager-facing mobile screen required |

### 1.4 User Journeys

#### Journey A: Morning Commute Order (Thao)

```
1. Opens app → Home Screen
2. Taps "Menu" tab
3. Selects "Beverages" → "Hot Coffees"
4. Taps "Caffè Latte"
5. Selects size: Grande
6. Taps "Add to Order"
7. Taps cart icon (top-right) → Cart Screen
8. Reviews order → Taps "Checkout"
9. Selects store for pickup
10. Selects payment: MoMo
11. Confirms order → Order Confirmation screen
12. Receives FCM notification when order is ready
```

#### Journey B: First-Time Registration + First Order (Chi)

```
1. Downloads app → Onboarding screen
2. Taps "Create account" → Registration form
3. Enters phone number, name, email, password
4. Receives OTP → verifies phone
5. Account created → redirected to Home
6. Browses "Menu" → "Food" → "Sandwiches"
7. Taps "Chicken & Avocado Sandwich"
8. Reads description and calories
9. Taps "Add to Order" with quantity 1
10. Goes to Cart → Checkout
11. Selects VNPay → Completes payment
12. Order Confirmation screen shown
13. Receives push notification: Order confirmed
14. Receives push notification: Order ready for pickup
```

#### Journey C: Rewards Redemption (Minh)

> **MVP scope note:** Points balance viewing and transaction history only (steps 1-2). Full redemption (steps 3-10) is post-MVP.

```
1. Opens app → Rewards tab
2. Checks Points Balance: 450 points
3. Browses "Redeemable items" in Rewards screen          ← Post-MVP
4. Sees "Free Tall Brewed Coffee — 150★"                 ← Post-MVP
5. Taps "Redeem" → adds to cart with 0 VND cost          ← Post-MVP
6. Can redeem another item (300 points remaining)        ← Post-MVP
7. Adds a paid item to fill the order                    ← Post-MVP
8. Checkout → points auto-applied at payment screen      ← Post-MVP
9. Confirms order                                        ← Post-MVP
10. FCM notification: "You earned 15★ for this order!"   ← Post-MVP
```

---

## 2. Functional Requirements

### 2.1 Authentication

| ID | Requirement | Priority | MVP |
|----|-------------|----------|-----|
| AUTH-01 | User can register with phone number, name, email, and password | P0 | ✅ |
| AUTH-02 | User receives OTP via SMS for phone verification during registration | P0 | ✅ |
| AUTH-03 | User can log in with phone/email + password | P0 | ✅ |
| AUTH-04 | User can request password reset via email/phone OTP | P0 | ✅ |
| AUTH-05 | JWT access token stored in mobile secure storage | P0 | ✅ |
| AUTH-06 | JWT refresh token rotates automatically on expiry | P0 | ✅ |
| AUTH-07 | User remains logged in across app restarts (refresh token ≤30 days) | P0 | ✅ |
| AUTH-08 | User can log out, which clears stored tokens | P0 | ✅ |
| AUTH-09 | App blocks access to authenticated screens when no valid token exists | P0 | ✅ |
| AUTH-10 | User can log in with biometrics (fingerprint / Face ID) after initial login | P1 | ❌ |

### 2.2 Menu

| ID | Requirement | Priority | MVP |
|----|-------------|----------|-----|
| MENU-01 | Main Menu screen displays category tiles (e.g., Beverages, Food, Merchandise) | P0 | ✅ |
| MENU-02 | Categories are fetched from the API and cached in Redis | P0 | ✅ |
| MENU-03 | Tapping a category navigates to Product List filtered by that category | P0 | ✅ |
| MENU-04 | Product List shows product cards with image, name, and price | P0 | ✅ |
| MENU-05 | Products are paginated (cursor or offset-based) | P0 | ✅ |
| MENU-06 | User can search products by name | P1 | ❌ |
| MENU-07 | User can filter products by subcategory (e.g., Hot Coffees, Iced Drinks within Beverages) | P1 | ❌ |
| MENU-08 | Featured/promotional items appear at the top of the menu | P2 | ❌ |
| MENU-09 | Out-of-stock items are visually distinguished and non-interactive | P1 | ✅ |

### 2.3 Product Detail

| ID | Requirement | Priority | MVP |
|----|-------------|----------|-----|
| PDP-01 | Product Detail screen shows product image, name, description, and base price | P0 | ✅ |
| PDP-02 | User can select a size where applicable (Tall, Grande, Venti) | P0 | ✅ |
| PDP-03 | Price updates reactively when size is changed | P0 | ✅ |
| PDP-04 | Nutritional info (calories, sugar, fat) is displayed | P1 | ✅ |
| PDP-05 | User can increment/decrement quantity (numeric stepper) | P0 | ✅ |
| PDP-06 | "Add to Order" button adds the product to the cart | P0 | ✅ |
| PDP-07 | Product customization beyond size (milk, add-ins, syrups) is available | P2 | ❌ |
| PDP-08 | Rewards cost pill ("XXX★ item") is shown for redeemable products | P1 | ❌ |
| PDP-09 | Related/recommended products are shown below the product detail | P2 | ❌ |
| PDP-10 | Full ingredients list and nutrition table are accessible | P1 | ✅ |

### 2.4 Cart

| ID | Requirement | Priority | MVP |
|----|-------------|----------|-----|
| CART-01 | Cart icon in the app bar shows item count badge | P0 | ✅ |
| CART-02 | Cart Screen displays a list of cart items grouped by store | P0 | ✅ |
| CART-03 | Each cart item shows product image, name, size, quantity, and line price | P0 | ✅ |
| CART-04 | User can increment/decrement item quantity from cart | P0 | ✅ |
| CART-05 | User can remove an item from cart via swipe or delete button | P0 | ✅ |
| CART-06 | Cart displays subtotal, tax, and total | P0 | ✅ |
| CART-07 | Empty cart state shows illustration and "Browse Menu" CTA | P0 | ✅ |
| CART-08 | Cart persists across app restarts (until order is placed or explicitly cleared) | P0 | ✅ |
| CART-09 | User can apply a rewards redemption to cart items | P1 | ❌ |
| CART-10 | User can select pickup store from cart | P0 | ✅ |
| CART-11 | "Checkout" button navigates to Checkout screen | P0 | ✅ |

### 2.5 Checkout

| ID | Requirement | Priority | MVP |
|----|-------------|----------|-----|
| CHK-01 | Checkout Screen shows order summary (items, quantities, prices) | P0 | ✅ |
| CHK-02 | User selects pickup store before completing order | P0 | ✅ |
| CHK-03 | Payment method selection: VNPay, MoMo | P0 | ✅ |
| CHK-04 | User can add order notes (e.g., "Extra hot, less ice") | P1 | ✅ |
| CHK-05 | Points balance is displayed and user can choose to redeem | P1 | ❌ |
| CHK-06 | "Place Order" button submits the order and initiates payment | P0 | ✅ |
| CHK-07 | Order is created in "Pending Payment" status before payment confirmation | P0 | ✅ |
| CHK-08 | Payment redirects to the selected payment gateway (MoMo / VNPay webview) | P0 | ✅ |
| CHK-09 | Successful payment → Order Confirmation screen with order ID and estimated wait time | P0 | ✅ |
| CHK-10 | Failed payment → error message with retry option | P0 | ✅ |
| CHK-11 | Payment gateway server-side IPN/webhook confirms transaction; app polls or awaits FCM as fallback | P0 | ✅ |
| CHK-12 | User receives FCM notification when payment is confirmed | P0 | ✅ |
| CHK-13 | User receives FCM notification when order is ready for pickup | P0 | ✅ |

### 2.6 Rewards

| ID | Requirement | Priority | MVP |
|----|-------------|----------|-----|
| REW-01 | Rewards tab shows current points balance prominently | P0 | ✅ |
| REW-02 | Rewards screen shows points earned history (recent transactions) | P1 | ✅ |
| REW-03 | Reward point calculation: ~1 point per 10,000 VND spent (or equivalent) | P0 | ✅ |
| REW-04 | Points are credited after order completion (not at placement) | P0 | ✅ |
| REW-05 | Points can be redeemed at checkout for discounts or free items | P1 | ❌ |
| REW-06 | Points balance updates in real-time after qualifying events | P1 | ✅ |
| REW-07 | Rewards tiers (e.g., Bronze/Silver/Gold) with tier-specific benefits | P2 | ❌ |
| REW-08 | Progress bar toward next reward tier or milestone | P2 | ❌ |
| REW-09 | Push notification when points are earned ("You earned 15★") | P1 | ❌ |

### 2.7 Profile

| ID | Requirement | Priority | MVP |
|----|-------------|----------|-----|
| PRO-01 | Profile Screen shows user avatar, name, phone, email | P0 | ✅ |
| PRO-02 | User can edit name, email, and avatar | P1 | ✅ |
| PRO-03 | Order History screen shows list of past orders with date, total, status | P0 | ✅ |
| PRO-04 | Tapping a past order shows Order Detail (items, payment, store) | P0 | ✅ |
| PRO-05 | User can reorder from a past order (re-add all items to cart) | P1 | ✅ |
| PRO-06 | App Settings screen includes notification preferences (order updates, promotions) | P1 | ✅ |
| PRO-07 | User can change password | P1 | ✅ |
| PRO-08 | "Delete Account" option with confirmation flow | P1 | ❌ |
| PRO-09 | Support/FAQ link in the profile | P2 | ❌ |

---

## 3. Non-Functional Requirements

### 3.1 Performance

| ID | Requirement | Target |
|----|-------------|--------|
| PERF-01 | App cold start time (splash to interactive) | ≤3 seconds on mid-range device |
| PERF-02 | Menu screen load (API to rendered) | ≤1.5 seconds |
| PERF-03 | Product Detail screen load | ≤1 second |
| PERF-04 | Cart operations (add, remove, update) | ≤500ms round-trip |
| PERF-05 | Checkout submission | ≤2 seconds (excluding payment gateway redirect) |
| PERF-06 | Image loading | Progressive / lazy load; ≤1 second per image on 4G |
| PERF-07 | API response time (P95) | ≤500ms for read endpoints; ≤1s for write endpoints |
| PERF-08 | Background cache refresh | Menu/products refreshed in background; never block UI |
| PERF-09 | Scroll performance | 60fps on device; no jank on product lists |
| PERF-10 | Offline resilience | App displays cached menu when network is unavailable; cart operations work offline |

### 3.2 Security

| ID | Requirement | Implementation |
|----|-------------|----------------|
| SEC-01 | All API traffic over HTTPS only | Enforce TLS 1.2+; certificate pinning in production |
| SEC-02 | JWT tokens stored in platform secure storage | Flutter Secure Storage (Keychain on iOS, EncryptedSharedPreferences on Android) |
| SEC-03 | Access token expiry | 15 minutes |
| SEC-04 | Refresh token expiry | 30 days; rotates on each use |
| SEC-05 | Password hashing | bcrypt (cost factor ≥12) on the server |
| SEC-06 | OTP verification | Time-limited (5 min), rate-limited (3 attempts), account-locked after 5 failures |
| SEC-07 | Input validation | Server-side validation for all endpoints; sanitize against XSS and SQL injection |
| SEC-08 | Rate limiting | Per-IP and per-user rate limits on auth endpoints (5 req/min for OTP, 20 req/min for login) |
| SEC-09 | Payment data | Never store raw payment credentials on device or server; use gateway SDKs (MoMo, VNPay) |
| SEC-10 | IDOR prevention | All user-scoped endpoints verify resource ownership server-side |
| SEC-11 | Audit logging | All auth and payment events logged with timestamp, IP, user ID |
| SEC-12 | OWASP compliance | Follow OWASP Mobile Top 10; security review before each release |

### 3.3 Accessibility

| ID | Requirement | Standard |
|----|-------------|----------|
| A11Y-01 | All tappable elements have minimum touch target of 44×44px | WCAG 2.1 AA |
| A11Y-02 | All images have semantic alt text / accessibility labels | WCAG 2.1 AA |
| A11Y-03 | Color contrast ratio ≥4.5:1 for normal text, ≥3:1 for large text | WCAG 2.1 AA |
| A11Y-04 | Screen reader support (TalkBack on Android, VoiceOver on iOS) | Full semantic hierarchy |
| A11Y-05 | All interactive elements are keyboard/d-pad navigable | WCAG 2.1 AA |
| A11Y-06 | Form errors are announced via screen reader and visually indicated | WCAG 2.1 AA |
| A11Y-07 | Loading states are announced ("Loading menu items") | WCAG 2.1 AA |
| A11Y-08 | Dynamic content updates are announced to screen readers (live regions) | WCAG 2.1 AA |
| A11Y-09 | Text scaling respects device font size settings | Dynamic type support |
| A11Y-10 | Reduced motion preference respected (disable non-essential animations) | prefers-reduced-motion |

### 3.4 Scalability

| ID | Requirement | Detail |
|----|-------------|--------|
| SCALE-01 | Concurrent users | Support 10,000 concurrent mobile API sessions at launch |
| SCALE-02 | Order throughput | Support 100 orders/minute during peak hours |
| SCALE-03 | Data growth | Support 500,000 users and 5M orders within 12 months |
| SCALE-04 | Horizontal scaling | NestJS backend deployable behind load balancer with stateless auth |
| SCALE-05 | Caching layer | Redis caches menu, categories, and featured products; invalidated on data change |
| SCALE-06 | Database indexing | Index on: user_id, order_id, product_id, category_id, created_at, status |
| SCALE-07 | Read replicas | PostgreSQL read replicas for reporting and analytics queries |
| SCALE-08 | CDN | Product images served via CDN (Cloudflare or similar) |
| SCALE-09 | API pagination | All list endpoints return paginated results (default 20, max 50 per page) |
| SCALE-10 | Database connection pooling | Use PgBouncer or built-in pooling for connection management |

---

## 4. Screen Inventory

### 4.1 Splash / Loading Screen

| Field | Detail |
|-------|--------|
| **Purpose** | Brand loading screen; performs token validation and initial data fetch |
| **Components** | Brand logo (center), loading indicator, version label |
| **User Actions** | None (auto-transitions) |
| **Navigation Routes** | → Home (authenticated) or → Login (unauthenticated) |
| **Design Notes** | Neutral Warm (`#f2f0eb`) background; Starbucks Green logo |

### 4.2 Onboarding Screen (first launch only)

| Field | Detail |
|-------|--------|
| **Purpose** | Welcome flow for first-time users; highlight key app features |
| **Components** | Page indicator dots, illustration per slide, headline + subhead, "Next" / "Skip" buttons, "Get Started" CTA |
| **User Actions** | Swipe between slides; tap Skip to bypass; tap Next to advance; tap Get Started to navigate to Auth |
| **Navigation Routes** | → Login / Register |
| **Design Notes** | Cream page canvas; 50px pill "Get Started" CTA in Green Accent |

### 4.3 Login Screen

| Field | Detail |
|-------|--------|
| **Purpose** | Authenticate existing users via phone/email + password |
| **Components** | Brand logo, phone/email input (floating label), password input (floating label, show/hide toggle), "Login" CTA button, "Forgot password?" link, "Create account" link |
| **User Actions** | Enter credentials → tap Login; tap Forgot Password; tap Create Account to navigate to Register |
| **Navigation Routes** | → Home (on success); → Forgot Password; → Register |
| **Design Notes** | Neutral Warm page canvas; White card container; 50px pill Login CTA in Green Accent |

### 4.4 Registration Screen

| Field | Detail |
|-------|--------|
| **Purpose** | New user account creation with phone OTP verification |
| **Components** | Full name input, phone input, email input, password input, confirm password input, OTP verification field (after phone entry), "Register" CTA |
| **User Actions** | Fill form → tap Register → receive OTP → enter OTP → account created; tap "Already have account?" to go to Login |
| **Navigation Routes** | → OTP verification (inline or new screen) → Home (on success); → Login |
| **Design Notes** | OTP field: 6-digit input, auto-focus, auto-advance. Floating label inputs throughout. Form validated inline. |

### 4.5 Forgot Password Screen

| Field | Detail |
|-------|--------|
| **Purpose** | Allow users to reset their password via phone OTP |
| **Components** | Phone/email input, "Send OTP" button, OTP input (after send), new password input, confirm password input, "Reset Password" CTA |
| **User Actions** | Enter phone → request OTP → enter OTP → set new password → confirm → submit |
| **Navigation Routes** | → Login (on success) |
| **Design Notes** | Same form patterns as Registration; success toast before redirect |

### 4.6 Home Screen (authenticated landing)

| Field | Detail |
|-------|--------|
| **Purpose** | Authenticated landing screen featuring personalized content, promotions, and quick order entry |
| **Components** | Top app bar (greeting + rewards points badge + cart icon), hero banner (seasonal promotion, swipable), quick action cards ("Order Again", "Menu", "Rewards"), featured products horizontal scroll, category shortcuts, floating Frap CTA (56px circular, bottom-right) |
| **User Actions** | Tap hero banner to view promotion; tap "Order Again" to quick-reorder; tap featured product for detail; tap Frap button to jump directly to menu; tap cart icon to view cart |
| **Navigation Routes** | → Menu; → Product Detail; → Cart; → Rewards |
| **Design Notes** | Neutral Warm page canvas; White content cards (12px radius, whisper shadows); Frap floating button bottom-right in Green Accent; Starbucks Green headings |

### 4.7 Menu — Category List Screen

| Field | Detail |
|-------|--------|
| **Purpose** | Browse menu categories (Beverages, Food, Merchandise, etc.) |
| **Components** | Search bar (top, optional for MVP), category tiles (image + label, 2-column grid), featured/promotional banner (top), cart icon in app bar |
| **User Actions** | Tap category tile → navigate to Product List for that category; tap search bar to search products |
| **Navigation Routes** | → Product List (filtered by category); → Search Results (post-MVP) |
| **Design Notes** | Category tiles: White card (12px radius), full-bleed product photography, label in SoDoSans 16/600 Text Black; 2-column grid on mobile |

### 4.8 Product List Screen

| Field | Detail |
|-------|--------|
| **Purpose** | Display products within a selected category, with subcategory filtering |
| **Components** | Subcategory tabs/filters (horizontal scroll), product cards (image + name + price), infinite scroll / pagination indicator |
| **User Actions** | Scroll vertically through products; tap subcategory tab to filter; tap a product card → Product Detail |
| **Navigation Routes** | → Product Detail |
| **Design Notes** | Product cards: White card, product thumbnail (square), name in SoDoSans 16/600, price in SoDoSans 14/400 Text Black Soft; Green Accent price for sale items |

### 4.9 Product Detail Screen

| Field | Detail |
|-------|--------|
| **Purpose** | View product information, select size, set quantity, and add to cart |
| **Components** | Product image (hero), product name (h1), description, nutritional summary (calories, sugar, fat), size selector (horizontal row of 4 cup-icon buttons: Tall/Grande/Venti/Trenta), quantity stepper (`−` `+`), price display, "Add to Order" pill CTA, ingredients/nutrition expandable section, recommended products (horizontal scroll) |
| **User Actions** | Select size → price updates; adjust quantity; tap "Add to Order" → item added + snackbar confirmation; tap nutrition section → expand; tap recommended product → navigate to that PDP |
| **Navigation Routes** | → Cart (via cart icon); → Related Product PDP |
| **Design Notes** | House Green feature band for product header section; White card for detail section below; size selector: active state = green circular ring (`2px solid #00754A`) around selected cup icon; "Add to Order": 50px pill, Green Accent fill, white text, `scale(0.95)` on press |

### 4.10 Cart Screen

| Field | Detail |
|-------|--------|
| **Purpose** | Review and manage items before checkout |
| **Components** | Cart item list (image, name, size, options summary, quantity stepper, line price, delete button), empty cart state (illustration + "Browse Menu" CTA), store selector, subtotal/tax/total summary row, "Checkout" CTA, rewards redemption section (post-MVP) |
| **User Actions** | Swipe to delete item; tap `−`/`+` to adjust quantity; tap checkout → navigate to Checkout; tap store selector → choose pickup store; tap "Browse Menu" (empty state) → Menu screen |
| **Navigation Routes** | → Checkout; → Menu (empty state); → Product Detail (tap item) |
| **Design Notes** | White card for each item; subtotal/tax/total at bottom with hairline separators; "Checkout" 50px pill, full-width, Green Accent; Frap button hidden on Cart screen |

### 4.11 Checkout Screen

| Field | Detail |
|-------|--------|
| **Purpose** | Finalize order: select store, add notes, choose payment, and place order |
| **Components** | Store selector (current location or manual selection), order summary (collapsible or scrollable item list), order notes text area, payment method selector (MoMo, VNPay — radio buttons with logos), price breakdown (subtotal, tax, total), "Place Order" CTA button, rewards redemption toggle (post-MVP), loading overlay during submission |
| **User Actions** | Select store → confirm pickup location; add notes; select payment method; tap "Place Order" → payment flow; on success → Order Confirmation; on failure → error + retry |
| **Navigation Routes** | → Order Confirmation (success); → Order Failed retry (failure) |
| **Design Notes** | Neutral Warm page canvas; White cards for each section; Payment method cards with logo + radio button; "Place Order": 50px pill, full-width, Green Accent, white text |

### 4.12 Order Confirmation Screen

| Field | Detail |
|-------|--------|
| **Purpose** | Display order confirmation details and estimated pickup time after successful payment |
| **Components** | Success animation/checkmark icon, "Order Confirmed!" headline, order ID, estimated pickup time, store name and address, order summary (items, quantities, prices), payment method + status, progress indicator (Order Placed → Preparing → Ready), "View Order" button, "Back to Menu" button |
| **User Actions** | Tap "View Order" → Order History Detail; tap "Back to Menu" → Home/Menu |
| **Navigation Routes** | → Order History Detail; → Home/Menu |
| **Design Notes** | Green Accent checkmark animation; House Green progress band if status tracking shown; White card for order summary |

### 4.13 Order History Screen

| Field | Detail |
|-------|--------|
| **Purpose** | List past orders with status, date, and total |
| **Components** | Order list (scrollable, paginated), each row: order ID, date, store name, total, status badge (Completed, Cancelled), reorder button |
| **User Actions** | Tap an order → Order Detail; tap "Reorder" → re-add all items to cart and navigate to Cart |
| **Navigation Routes** | → Order Detail; → Cart (on reorder) |
| **Design Notes** | List with date separators for "Today", "Yesterday", "Earlier"; status badges colored: Completed = Green Accent, Cancelled = Red |

### 4.14 Order Detail Screen

| Field | Detail |
|-------|--------|
| **Purpose** | View full details of a specific past order |
| **Components** | Order header (order ID, date, time, store), order items list (image, name, size, quantity, line price), price breakdown, payment method + status, order status timeline (if applicable), "Reorder" CTA |
| **User Actions** | Tap "Reorder" → re-add items to cart → navigate to Cart; tap "Back" → Order History |
| **Navigation Routes** | → Cart (on reorder); → Order History (back) |
| **Design Notes** | White card for items; hairline separators; status timeline in House Green (if active) |

### 4.15 Rewards Screen

| Field | Detail |
|-------|--------|
| **Purpose** | Display points balance, earn rate, and recent reward transactions |
| **Components** | Points balance hero (large number + "★" star icon + "points" label), earn rate explanation (e.g., "1★ per 10,000₫"), points history list (date, description, points earned/redeemed, running balance), redeemable items grid (post-MVP), progress toward next tier (post-MVP), tier badge (post-MVP) |
| **User Actions** | Scroll through points history; (post-MVP) tap redeemable item to redeem; (post-MVP) tap tier card to view benefits |
| **Navigation Routes** | → Redeem flow (post-MVP); → Home/Menu |
| **Design Notes** | House Green feature band for points hero section; White card for history list; Starbucks Green for points number; Gold accents for tier/redeem section (post-MVP) |

### 4.16 Profile Screen

| Field | Detail |
|-------|--------|
| **Purpose** | User account management hub |
| **Components** | User avatar (editable), name, phone, email display, menu rows: Order History, Rewards, Settings, Help/FAQ, "Log Out" button |
| **User Actions** | Tap avatar to change photo; tap name/email to edit; tap any menu row → respective screen; tap "Log Out" → confirmation dialog → Login screen |
| **Navigation Routes** | → Edit Profile; → Order History; → Rewards; → Settings; → Help/FAQ; → Login (on logout) |
| **Design Notes** | Neutral Warm page canvas; White card sections; Menu rows with chevron-right icon |

### 4.17 Edit Profile Screen

| Field | Detail |
|-------|--------|
| **Purpose** | Edit user profile details |
| **Components** | Avatar with camera icon overlay, name input, email input, phone display (read-only), "Save Changes" CTA, "Cancel" link |
| **User Actions** | Tap avatar → camera/gallery picker; edit name and email; tap "Save Changes" → API call → success toast → back to Profile |
| **Navigation Routes** | → Profile (on save/cancel) |
| **Design Notes** | Same form patterns as Registration; floating label inputs; 50px pill Save CTA in Green Accent |

### 4.18 Settings Screen

| Field | Detail |
|-------|--------|
| **Purpose** | App preferences and account management |
| **Components** | Notification preferences toggles (Order updates, Rewards, Promotions), "Change Password" row, "Delete Account" row (post-MVP), App version label |
| **User Actions** | Toggle notification preferences; tap "Change Password" → change password flow; tap "Delete Account" → destructive confirmation |
| **Navigation Routes** | → Change Password; → Profile (back) |
| **Design Notes** | Toggle switches with Green Accent active state; hairline separators between rows |

### 4.19 Change Password Screen

| Field | Detail |
|-------|--------|
| **Purpose** | Allow authenticated user to change their password |
| **Components** | Current password input, new password input, confirm new password input, "Update Password" CTA |
| **User Actions** | Fill form → tap "Update Password" → validation → API call → success toast → back to Settings |
| **Navigation Routes** | → Settings (on success) |
| **Design Notes** | Same form patterns as other auth screens |

---

## 5. Mobile Navigation Specification

### 5.1 Bottom Tab Navigation

The app uses a 5-tab bottom navigation bar as its primary navigation structure. The tabs are persistent across authenticated sessions.

| Tab Icon | Label | Route | Screen | MVP |
|----------|-------|-------|--------|-----|
| 🏠 | Home | `/home` | Home Screen | ✅ |
| 📋 | Menu | `/menu` | Menu — Category List | ✅ |
| 🛒 | Cart | `/cart` | Cart Screen | ✅ |
| ⭐ | Rewards | `/rewards` | Rewards Screen | ✅ |
| 👤 | Profile | `/profile` | Profile Screen | ✅ |

**Tab Bar Visibility:**

- Tab bar is visible on all tab root screens: Home, Menu, Cart, Rewards, Profile
- Tab bar is **hidden** during checkout flow (Checkout Screen, Order Confirmation) to minimize distractions and prevent accidental navigation away from the payment flow
- Tab bar is **hidden** on deep sub-screens: Edit Profile, Settings, Change Password, Order Detail

**Tab Bar Design Notes:**
- Background: White (`#ffffff`)
- Active icon + label: Green Accent (`#00754A`)
- Inactive icon + label: Text Black Soft (`rgba(0,0,0,0.58)`)
- Height: ~56px (iOS) / ~50px (Android) adapting to platform conventions
- Label: SoDoSans 11px weight 400 (caption size)
- Floating Frap button (56px circular, Green Accent) overlays the tab bar at bottom-right on all screens except Cart and Checkout
- Cart tab icon shows badge with item count (red error dot or White-on-Red count badge)

### 5.2 Navigation Hierarchy

```
App Launch
├── [First Launch] → Onboarding
├── [No Token] → Login / Register / Forgot Password
└── [Valid Token] → Home

Main Tabs (authenticated)
├── Home (/home)
│   ├── → Product Detail (via featured product)
│   └── → Menu (via quick action)
├── Menu (/menu)
│   └── → Product List (/menu/category/:categoryId)
│       └── → Product Detail (/menu/product/:productId)
├── Cart (/cart)
│   ├── → Product Detail (tap item)
│   ├── → Checkout (/checkout)
│   │   └── → Order Confirmation (/order/:orderId/confirmation)
│   └── → Menu (empty state CTA)
├── Rewards (/rewards)
│   └── → Product Detail (redeemable item — post-MVP)
└── Profile (/profile)
    ├── → Edit Profile (/profile/edit)
    ├── → Order History (/profile/orders)
    │   └── → Order Detail (/profile/orders/:orderId)
    ├── → Settings (/profile/settings)
    │   └── → Change Password (/profile/settings/change-password)
    ├── → Rewards (/rewards)
    ├── → Help/FAQ (/profile/help — post-MVP)
    └── → Logout → Login
```

### 5.3 Route Definition (GoRouter)

| Route Pattern | Screen | Auth Required | Notes |
|---------------|--------|---------------|-------|
| `/` | Splash / Auth Check | No | Redirects based on auth state |
| `/onboarding` | Onboarding | No | First launch only |
| `/login` | Login | No | |
| `/register` | Registration | No | |
| `/register/verify-otp` | OTP Verification | No | Part of registration flow |
| `/forgot-password` | Forgot Password | No | |
| `/home` | Home Screen | Yes | Tab root |
| `/menu` | Menu — Category List | Yes | Tab root |
| `/menu/category/:categoryId` | Product List | Yes | |
| `/menu/product/:productId` | Product Detail | Yes | |
| `/cart` | Cart Screen | Yes | Tab root |
| `/checkout` | Checkout Screen | Yes | |
| `/order/:orderId/confirmation` | Order Confirmation | Yes | Post-payment |
| `/rewards` | Rewards Screen | Yes | Tab root |
| `/profile` | Profile Screen | Yes | Tab root |
| `/profile/edit` | Edit Profile | Yes | |
| `/profile/orders` | Order History | Yes | |
| `/profile/orders/:orderId` | Order Detail | Yes | |
| `/profile/settings` | Settings | Yes | |
| `/profile/settings/change-password` | Change Password | Yes | |
| `/profile/help` | Help/FAQ | Yes | Post-MVP |

### 5.4 Deep Links

Deep links enable push notifications to navigate directly to specific screens.

| Deep Link | Source | Destination | MVP |
|-----------|--------|-------------|-----|
| `cfpv://order/:orderId` | FCM — Order Confirmed notification | Order Detail | ✅ |
| `cfpv://order/:orderId/ready` | FCM — Order Ready notification | Order Detail | ✅ |
| `cfpv://rewards` | FCM — Reward Earned notification | Rewards Screen | ✅ |
| `cfpv://menu/product/:productId` | FCM — Promotion notification | Product Detail | ❌ |
| `cfpv://menu` | Universal link from marketing | Menu | ❌ |

---

## 6. Data Model Proposal

### 6.1 Entity Relationship Diagram (Text)

```
User 1──N Order
User 1──1 Cart
Cart 1──N CartItem
CartItem N──1 Product
Order 1──N OrderItem
OrderItem N──1 Product
Product N──1 Category
Product 1──N ProductVariant (sizes)
User 1──N RewardTransaction
User 1──N DeviceToken
```

### 6.2 Entity Definitions

#### User

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `phone` | VARCHAR(15) | ✅ | Unique; indexed |
| `email` | VARCHAR(255) | ❌ | Unique if provided |
| `full_name` | VARCHAR(100) | ✅ | |
| `password_hash` | VARCHAR(255) | ✅ | bcrypt hash |
| `avatar_url` | VARCHAR(500) | ❌ | CDN path |
| `phone_verified_at` | TIMESTAMP | ❌ | Null until OTP verified |
| `refresh_token_hash` | VARCHAR(255) | ❌ | Current valid refresh token |
| `notification_enabled` | BOOLEAN | ✅ | Default: true |
| `promotion_notification_enabled` | BOOLEAN | ✅ | Default: true |
| `created_at` | TIMESTAMP | ✅ | |
| `updated_at` | TIMESTAMP | ✅ | |

**Indexes:** `phone` (unique), `email` (unique), `created_at`

#### Category

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `name` | VARCHAR(100) | ✅ | e.g., "Beverages", "Food" |
| `slug` | VARCHAR(100) | ✅ | URL-friendly; unique |
| `description` | VARCHAR(500) | ❌ | |
| `image_url` | VARCHAR(500) | ❌ | Category thumbnail |
| `sort_order` | INTEGER | ✅ | Display order |
| `is_active` | BOOLEAN | ✅ | Default: true |
| `created_at` | TIMESTAMP | ✅ | |
| `updated_at` | TIMESTAMP | ✅ | |

**Indexes:** `slug` (unique), `sort_order`

#### Product

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `category_id` | UUID | ✅ | FK → Category |
| `name` | VARCHAR(200) | ✅ | |
| `slug` | VARCHAR(200) | ✅ | URL-friendly |
| `description` | TEXT | ❌ | |
| `image_url` | VARCHAR(500) | ❌ | Primary product image |
| `base_price` | DECIMAL(12,0) | ✅ | In VND; e.g., 55000 for 55,000₫ |
| `calories` | INTEGER | ❌ | |
| `sugar_grams` | DECIMAL(6,1) | ❌ | |
| `fat_grams` | DECIMAL(6,1) | ❌ | |
| `ingredients` | TEXT | ❌ | Free text or JSON array |
| `is_active` | BOOLEAN | ✅ | Default: true |
| `is_featured` | BOOLEAN | ✅ | Default: false |
| `is_redeemable` | BOOLEAN | ✅ | Can be redeemed with points |
| `reward_stars_cost` | INTEGER | ❌ | Null if not redeemable |
| `sort_order` | INTEGER | ✅ | |
| `created_at` | TIMESTAMP | ✅ | |
| `updated_at` | TIMESTAMP | ✅ | |

**Indexes:** `category_id`, `slug` (unique), `is_active`, `is_featured`, `sort_order`

#### ProductVariant (Size)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `product_id` | UUID | ✅ | FK → Product |
| `name` | VARCHAR(50) | ✅ | "Tall", "Grande", "Venti", "Trenta" |
| `sort_order` | INTEGER | ✅ | Display order |
| `price_adjustment` | DECIMAL(12,0) | ✅ | Added to base_price; 0 for default size |
| `volume_ml` | INTEGER | ❌ | e.g., 355, 473, 591, 887 |
| `is_default` | BOOLEAN | ✅ | Default: false; exactly one variant per product should be marked default |
| `is_active` | BOOLEAN | ✅ | Default: true |
| `created_at` | TIMESTAMP | ✅ | |

**Indexes:** `product_id`

#### ProductStore (store availability / stock status)

> **Note for MVP:** For a single-store launch, this entity can be simplified to an `is_available` boolean field directly on `Product`. The pivot table below is the full multi-store design.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `product_id` | UUID | ✅ | FK → Product |
| `store_id` | UUID | ✅ | FK → Store |
| `is_available` | BOOLEAN | ✅ | Default: true; staff toggle via admin |
| `updated_at` | TIMESTAMP | ✅ | |

**Indexes:** `product_id + store_id` (unique composite)

#### Cart

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `user_id` | UUID | ✅ | FK → User; unique (1 cart per user) |
| `store_id` | UUID | ❌ | Selected pickup store |
| `notes` | VARCHAR(500) | ❌ | Order-level notes |
| `created_at` | TIMESTAMP | ✅ | |
| `updated_at` | TIMESTAMP | ✅ | |

**Indexes:** `user_id` (unique)

#### CartItem

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `cart_id` | UUID | ✅ | FK → Cart |
| `product_id` | UUID | ✅ | FK → Product |
| `product_variant_id` | UUID | ❌ | FK → ProductVariant (null if no size) |
| `quantity` | INTEGER | ✅ | Min 1, Max 99 |
| `unit_price` | DECIMAL(12,0) | ✅ | Snapshot of price at add time |
| `created_at` | TIMESTAMP | ✅ | |

**Indexes:** `cart_id`, `product_id`

#### Order

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `order_code` | VARCHAR(20) | ✅ | Human-readable; e.g., "CFPV-20240607-1234" |
| `user_id` | UUID | ✅ | FK → User |
| `store_id` | UUID | ❌ | FK → Store (post-MVP) |
| `store_name` | VARCHAR(200) | ✅ | Denormalized store name |
| `status` | ENUM | ✅ | `pending_payment`, `confirmed`, `preparing`, `ready`, `completed`, `cancelled` |
| `subtotal` | DECIMAL(12,0) | ✅ | Sum of item prices before tax |
| `tax` | DECIMAL(12,0) | ✅ | VAT (10% or applicable rate) |
| `total` | DECIMAL(12,0) | ✅ | Final amount charged |
| `payment_method` | VARCHAR(20) | ✅ | `momo`, `vnpay` |
| `payment_status` | ENUM | ✅ | `pending`, `completed`, `failed`, `refunded` |
| `payment_transaction_id` | VARCHAR(200) | ❌ | Gateway transaction reference |
| `points_earned` | INTEGER | ✅ | Points awarded after completion |
| `points_redeemed` | INTEGER | ❌ | Points used (if any) |
| `notes` | VARCHAR(500) | ❌ | |
| `ordered_at` | TIMESTAMP | ✅ | |
| `confirmed_at` | TIMESTAMP | ❌ | |
| `ready_at` | TIMESTAMP | ❌ | |
| `completed_at` | TIMESTAMP | ❌ | |
| `cancelled_at` | TIMESTAMP | ❌ | |
| `created_at` | TIMESTAMP | ✅ | |
| `updated_at` | TIMESTAMP | ✅ | |

**Indexes:** `order_code` (unique), `user_id`, `status`, `created_at`, `ordered_at`

#### OrderItem

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `order_id` | UUID | ✅ | FK → Order |
| `product_id` | UUID | ✅ | FK → Product |
| `product_name` | VARCHAR(200) | ✅ | Denormalized at order time |
| `product_image_url` | VARCHAR(500) | ❌ | Denormalized |
| `variant_name` | VARCHAR(50) | ❌ | "Grande" (snapshot, null if N/A) |
| `quantity` | INTEGER | ✅ | |
| `unit_price` | DECIMAL(12,0) | ✅ | Snapshot price |
| `line_total` | DECIMAL(12,0) | ✅ | `unit_price × quantity` |

**Indexes:** `order_id`

#### Store

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `name` | VARCHAR(200) | ✅ | Store/branch name |
| `address` | VARCHAR(500) | ✅ | |
| `latitude` | DECIMAL(10,7) | ❌ | For map display (post-MVP) |
| `longitude` | DECIMAL(10,7) | ❌ | |
| `phone` | VARCHAR(15) | ❌ | |
| `opening_time` | TIME | ✅ | |
| `closing_time` | TIME | ✅ | |
| `is_active` | BOOLEAN | ✅ | |
| `created_at` | TIMESTAMP | ✅ | |

**Indexes:** `is_active`

#### DeviceToken

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `user_id` | UUID | ✅ | FK → User |
| `token` | VARCHAR(500) | ✅ | FCM registration token |
| `platform` | ENUM | ✅ | `android`, `ios` |
| `created_at` | TIMESTAMP | ✅ | |
| `updated_at` | TIMESTAMP | ✅ | |

**Indexes:** `user_id`, `token`

#### RewardTransaction

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | ✅ | Primary key |
| `user_id` | UUID | ✅ | FK → User |
| `order_id` | UUID | ❌ | FK → Order (null for manual adjustments) |
| `type` | ENUM | ✅ | `earned`, `redeemed`, `expired`, `adjusted` |
| `points` | INTEGER | ✅ | Positive for earned, negative for redeemed/expired |
| `balance_after` | INTEGER | ✅ | Running balance after this transaction |
| `description` | VARCHAR(500) | ❌ | e.g., "Order #CFPV-20240607-1234" |
| `created_at` | TIMESTAMP | ✅ | |

**Indexes:** `user_id`, `created_at`, `order_id`

### 6.3 Entity Relationships Summary

| From | To | Cardinality | Foreign Key |
|------|----|-------------|-------------|
| User | Cart | 1:1 | `Cart.user_id` |
| User | Order | 1:N | `Order.user_id` |
| User | RewardTransaction | 1:N | `RewardTransaction.user_id` |
| Cart | CartItem | 1:N | `CartItem.cart_id` |
| Order | OrderItem | 1:N | `OrderItem.order_id` |
| Product | CartItem | 1:N | `CartItem.product_id` |
| Product | OrderItem | 1:N | `OrderItem.product_id` |
| Product | ProductVariant | 1:N | `ProductVariant.product_id` |
| Category | Product | 1:N | `Product.category_id` |
| User | DeviceToken | 1:N | `DeviceToken.user_id` |

---

## 7. API Inventory

### 7.1 API Conventions

| Convention | Standard |
|------------|----------|
| **Base URL** | `/api/v1` |
| **Format** | JSON |
| **Authentication** | `Authorization: Bearer <access_token>` |
| **Pagination** | `?page=1&limit=20` (offset-based) or `?cursor=...` (cursor-based) |
| **Pagination Response** | `{ data: [...], meta: { page, limit, total, totalPages } }` |
| **Error Format** | `{ statusCode, message, error, timestamp, path }` |
| **HTTP Methods** | GET (read), POST (create), PUT/PATCH (update), DELETE (delete) |

### 7.2 Authentication Endpoints

#### POST `/api/v1/auth/register`

| Field | Detail |
|-------|--------|
| **Auth** | None |
| **Request** | `{ full_name, phone, email?, password }` |
| **Response** | `{ message: "OTP sent to phone" }` |
| **Notes** | Sends OTP via SMS; does not create verified user yet |

#### POST `/api/v1/auth/register/verify`

| Field | Detail |
|-------|--------|
| **Auth** | None |
| **Request** | `{ phone, otp }` |
| **Response** | `{ user: { id, full_name, phone, email }, tokens: { accessToken, refreshToken } }` |
| **Notes** | Creates and returns user + tokens on successful OTP verification |

#### POST `/api/v1/auth/login`

| Field | Detail |
|-------|--------|
| **Auth** | None |
| **Request** | `{ login: "phone_or_email", password }` |
| **Response** | `{ user: { id, full_name, phone, email, avatarUrl }, tokens: { accessToken, refreshToken } }` |

#### POST `/api/v1/auth/refresh`

| Field | Detail |
|-------|--------|
| **Auth** | None (uses refresh token) |
| **Request** | `{ refreshToken }` |
| **Response** | `{ accessToken, refreshToken }` |
| **Notes** | Issues new access + rotated refresh token |

#### POST `/api/v1/auth/forgot-password`

| Field | Detail |
|-------|--------|
| **Auth** | None |
| **Request** | `{ phone }` |
| **Response** | `{ message: "OTP sent to phone" }` |

#### POST `/api/v1/auth/forgot-password/verify`

| Field | Detail |
|-------|--------|
| **Auth** | None |
| **Request** | `{ phone, otp, newPassword }` |
| **Response** | `{ message: "Password updated successfully" }` |

#### POST `/api/v1/auth/logout`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `{ refreshToken }` |
| **Response** | `{ message: "Logged out" }` |
| **Notes** | Invalidates refresh token server-side |

### 7.3 Categories Endpoints

#### GET `/api/v1/categories`

| Field | Detail |
|-------|--------|
| **Auth** | Optional |
| **Request** | `?page=1&limit=20` |
| **Response** | `{ data: [{ id, name, slug, description, imageUrl, productCount, sortOrder }], meta }` |
| **Notes** | Only returns `is_active = true`; cached in Redis |

### 7.4 Products Endpoints

#### GET `/api/v1/products`

| Field | Detail |
|-------|--------|
| **Auth** | Optional |
| **Request** | `?categoryId=...&page=1&limit=20&search=...&subcategory=...` |
| **Response** | `{ data: [{ id, name, slug, description, imageUrl, basePrice, categoryId, calories, sugarGrams, fatGrams, isRedeemable, rewardStarsCost }], meta }` |
| **Notes** | `categoryId` is required; cached in Redis |

#### GET `/api/v1/products/featured`

| Field | Detail |
|-------|--------|
| **Auth** | Optional |
| **Request** | `?limit=10` |
| **Response** | `{ data: [{ id, name, slug, imageUrl, basePrice, ... }] }` |
| **Notes** | Returns `is_featured = true`; cached in Redis |

#### GET `/api/v1/products/:id`

| Field | Detail |
|-------|--------|
| **Auth** | Optional |
| **Request** | Path param: `:id` (UUID) |
| **Response** | `{ data: { id, name, slug, description, imageUrl, basePrice, calories, sugarGrams, fatGrams, ingredients, isRedeemable, rewardStarsCost, category: { id, name }, variants: [{ id, name, priceAdjustment, volumeMl, sortOrder }] } }` |

#### GET `/api/v1/products/:id/nutrition`

| Field | Detail |
|-------|--------|
| **Auth** | Optional |
| **Request** | Path param: `:id` (UUID) |
| **Response** | `{ data: { productId, calories, totalFat, saturatedFat, transFat, cholesterol, sodium, totalCarbs, dietaryFiber, sugars, protein, caffeine, ingredients } }` |

### 7.5 Cart Endpoints

#### GET `/api/v1/cart`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | None |
| **Response** | `{ data: { id, storeId, notes, items: [{ id, productId, productName, productImageUrl, variantId, variantName, quantity, unitPrice, lineTotal }], subtotal, taxEstimate, totalEstimate } }` |

#### POST `/api/v1/cart/items`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `{ productId, variantId?, quantity }` |
| **Response** | `{ data: { cartId, item: { id, productId, productName, variantName, quantity, unitPrice, lineTotal } } }` |
| **Notes** | If product already in cart, increases quantity |

#### PUT `/api/v1/cart/items/:itemId`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `{ quantity }` |
| **Response** | `{ data: { id, productId, quantity, unitPrice, lineTotal } }` |

#### DELETE `/api/v1/cart/items/:itemId`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | Path param: `:itemId` |
| **Response** | `{ message: "Item removed" }` |

#### PUT `/api/v1/cart/store`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `{ storeId }` |
| **Response** | `{ data: { storeId, storeName } }` |

#### PUT `/api/v1/cart/notes`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `{ notes }` |
| **Response** | `{ data: { notes } }` |

### 7.6 Order Endpoints

#### POST `/api/v1/orders`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `{ storeId, paymentMethod, notes? }` |
| **Response** | `{ data: { id, orderCode, status, subtotal, tax, total, paymentMethod, paymentStatus, paymentUrl } }` |
| **Notes** | `paymentUrl` redirects to MoMo/VNPay gateway; order created in `pending_payment` status |

#### POST `/api/v1/orders/:id/confirm-payment`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `{ transactionId, status: "completed" | "failed" }` |
| **Response** | `{ data: { id, status, paymentStatus } }` |
| **Notes** | **MVP note:** Called by the app after payment gateway redirects back. For V2, a proper server-side IPN webhook (VNPay IPN URL / MoMo webhook) should handle server-side confirmation to avoid race conditions if the user closes the browser mid-redirect. |

#### GET `/api/v1/orders`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `?page=1&limit=20&status=...` |
| **Response** | `{ data: [{ id, orderCode, storeName, status, total, orderedAt }], meta }` |

#### GET `/api/v1/orders/:id`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | Path param: `:id` |
| **Response** | `{ data: { id, orderCode, storeName, status, subtotal, tax, total, paymentMethod, paymentStatus, notes, pointsEarned, pointsRedeemed, items: [{ id, productName, productImageUrl, variantName, quantity, unitPrice, lineTotal }], statusTimeline: [{ status, timestamp }], orderedAt, confirmedAt, readyAt } }` |

#### POST `/api/v1/orders/:id/reorder`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | Path param: `:id` |
| **Response** | `{ data: { cartId, itemCount } }` |
| **Notes** | Adds all items from the order to the current user's cart (same products + quantities) |

### 7.7 Stores Endpoints

#### GET `/api/v1/stores`

| Field | Detail |
|-------|--------|
| **Auth** | Optional |
| **Request** | `?page=1&limit=50` |
| **Response** | `{ data: [{ id, name, address, phone, openingTime, closingTime, isActive }], meta }` |

### 7.8 Rewards Endpoints

#### GET `/api/v1/rewards/balance`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | None |
| **Response** | `{ data: { balance: 450, lifetimeEarned: 1200, lifetimeRedeemed: 750 } }` |

#### GET `/api/v1/rewards/transactions`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `?page=1&limit=20` |
| **Response** | `{ data: [{ id, type, points, balanceAfter, description, createdAt }], meta }` |

### 7.9 Profile Endpoints

#### GET `/api/v1/users/me`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | None |
| **Response** | `{ data: { id, fullName, phone, email, avatarUrl, phoneVerifiedAt } }` |

#### PUT `/api/v1/users/me`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `{ fullName?, email?, avatarUrl? }` |
| **Response** | `{ data: { id, fullName, phone, email, avatarUrl } }` |

#### PUT `/api/v1/users/me/password`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `{ currentPassword, newPassword }` |
| **Response** | `{ message: "Password updated" }` |

#### PUT `/api/v1/users/me/settings`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `{ notificationEnabled?, promotionNotificationEnabled? }` |
| **Response** | `{ data: { notificationEnabled, promotionNotificationEnabled } }` |

### 7.10 Notifications Endpoints

#### POST `/api/v1/notifications/device`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `{ token: "fcm_token_string", platform: "android" | "ios" }` |
| **Response** | `{ message: "Device registered" }` |
| **Notes** | Called on app launch and on token refresh. Backend persists token per user for FCM targeting. |

### 7.11 Uploads Endpoints

#### POST `/api/v1/uploads/avatar`

| Field | Detail |
|-------|--------|
| **Auth** | Bearer Token |
| **Request** | `multipart/form-data` — file field `avatar` (image/png, image/jpeg, max 5MB) |
| **Response** | `{ data: { url: "https://cdn.cfpv.com/avatars/uuid.jpg" } }` |
| **Notes** | Uploads directly to CDN; returns public URL that can be passed to `PUT /api/v1/users/me`. |

### 7.12 Authentication Requirements Summary

| Auth Level | Endpoints |
|------------|-----------|
| **No Auth** | Register, Register Verify, Login, Refresh Token, Forgot Password (both), Categories (GET), Products (GET), Stores (GET) |
| **Bearer Token Required** | Logout, Cart (all), Orders (all), Rewards (all), Profile (all), Notifications (all), Uploads |

---

## 8. Risks and Open Questions

### 8.1 Technical Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Payment gateway latency** | Users drop off during checkout if payment redirect is slow | Medium | Show loading states with progress animation; set timeout with retry logic |
| **OTP delivery delays** | SMS OTP may take 30+ seconds during Telco congestion in Vietnam | High | **MVP:** OTP is hardcoded to `131017` for development and testing. Post-MVP: integrate Twilio or VietGuys with resend timer (30s) and voice OTP fallback. |
| **Offline cart sync conflicts** | User adds items offline, then comes online — conflict with server cart state | Medium | Use last-write-wins for cart at item level; notify user of sync |
| **Image loading on slow networks** | Product images fail to load, degrading menu browsing experience | Medium | Implement progressive JPEG loading; use placeholder blur-up; CDN caching |
| **FCM delivery reliability** | Push notifications not delivered on some Chinese OEM Android devices (Xiaomi, Oppo) | High | Implement polling as fallback for critical notifications (order ready); test on top 10 Vietnam device models |

### 8.2 Business Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **User adoption low** | Customers prefer in-store ordering over app | Medium | Incentivize first order with welcome bonus points; in-store signage and barista prompting |
| **Rewards system abuse** | Users game the points system (fake orders, account farming) | Medium | Server-side validation of order completion; fraud detection on rapid-fire ordering; limit account per phone number |
| **Vietnamese payment preference shifts** | Users expect bank transfer or cash on delivery | Medium | Start with MoMo and VNPay (both widely adopted); add bank transfer in V2 if data supports |
| **Store operational readiness** | Stores not prepared for mobile order volume; long wait times anger users | Medium | Gradual store rollout; estimated wait time display; order throttling per store |

### 8.3 Open Questions

| # | Question | Impact | Decision Needed By |
|---|----------|--------|-------------------|
| Q1 | Should the app support multiple stores in the MVP (user selects pickup location), or a single store initially? | Affects Cart, Checkout, Store API | Spec sign-off |
| Q2 | What is the rewards earn rate? e.g., 1★ per 10,000₫, 1★ per 20,000₫, or percentage-based? | Affects Rewards logic, Order completion | ✅ **Decided: 1★ per 10,000₫** |
| Q3 | Should the Home screen hero banner be managed via CMS (admin dashboard) or hardcoded for MVP? | Affects backend scope | Before implementation |
| Q4 | Tax rate — is VAT 10% the standard, or different for F&B in Vietnam? | Affects Order total calculation | Before implementation |
| | *Spec placeholder:* MVP assumes **10% VAT** per Vietnam tax code for F&B. Adjust if actual applicable rate differs. | | |
| Q5 | What is the minimum order amount, if any? | Affects Checkout validation | Before implementation |
| Q6 | Should canceled orders refund points? | Affects Rewards logic | Before implementation |
| Q7 | Do we need a guest/checkout-without-account flow, or is registration required for all orders? | Affects Auth scope | Spec sign-off |
| Q8 | What is the expected average order value in VND? (Impacts points earn rate calibration) | Affects Rewards logic | Before implementation |

---

## 9. Recommended MVP Scope Validation

### 9.1 MVP Scope (as defined in `specs/mvp.md`)

| Feature | Included | Spec Coverage | Notes |
|---------|----------|---------------|-------|
| **Authentication** — Login, Register, Forgot Password | ✅ | Sections 2.1, 4.2–4.5, 7.2 | Fully specified |
| **Menu** — Categories, Product List, Product Detail | ✅ | Sections 2.2, 2.3, 4.7–4.9, 7.3, 7.4 | Fully specified; customization limited to size only |
| **Cart** | ✅ | Sections 2.4, 4.10, 7.5 | Fully specified |
| **Checkout** | ✅ | Sections 2.5, 4.11, 7.6 | Fully specified with MoMo + VNPay |
| **Rewards** — Points Balance only | ✅ | Sections 2.6, 4.15, 7.8 | Balance display + transaction history; redemption is post-MVP |
| **Profile** — User Profile + Order History | ✅ | Sections 2.7, 4.13, 4.14, 4.16, 4.17, 4.18, 4.19, 7.9 | Fully specified with settings and change password |

### 9.2 Post-MVP Items

| Feature | Moved To | Rationale |
|---------|----------|-----------|
| Store Locator | V2 | User selects from a store list at checkout; location-aware map is enhancement |
| Product Customization (milk, add-ins, syrups) | V2 | Adds significant backend complexity — ProductOption, OptionGroup, pricing rules per customization |
| Rewards Redemption at Checkout | V2 | Points balance display is sufficient for MVP; redemption adds payment reconciliation complexity |
| Rewards Tiers (Bronze/Silver/Gold) | V2 | Tier system requires promotion engine, milestone tracking, and tier-specific benefits |
| Gift Cards | V2 | Entirely new payment and gifting subsystem |
| Promotions Engine | V2 | Time-based discounts, BOGO, seasonal pricing require campaign management |
| Delivery Tracking | V2 | MVP is pickup-only; real-time delivery tracking is a significant feature |
| Guest Checkout | V2 | MVP requires registration to build loyalty profile and order history from the start |
| Biometric Login | V2 | Enhancement; password login covers MVP auth needs |
| Product Search | V2 | Search requires full-text indexing; category browsing is sufficient for MVP |
| Deep Links from Marketing | V2 | Requires universal link configuration and marketing campaign integration |

### 9.3 Gap Analysis

| Gap | Severity | Action |
|-----|----------|--------|
| **Nutrition info** needed in MVP but not listed in mvp.md explicitly | Low | Included in PDP requirements (PDP-04) as it's visible on Starbucks PDP and expected by health-conscious users |
| **Store selection** not mentioned in mvp.md but required for checkout | Low | Added to MVP specification; user must select a pickup store. For single-store MVP, default to that store |
| **Order notifications** (FCM) — implied but not listed | Low | Added to MVP; critical for order-ready communication. Without notifications, users don't know when to pick up |
| **Reorder** from Order History — not in mvp.md but low effort | Low | Included as PRO-05 (P1) — re-creates cart from previous order; backend work is minimal |
| **Cart persistence** across app restarts | None | Explicitly specified (CART-08); expected user behavior |
| **Empty states** (cart, order history, no network) | None | Specified per screen; critical for production quality |

### 9.4 MVP Validation Conclusion

The MVP scope as defined is **viable and well-scoped**. The amendments and gap-fillings above (nutrition info, store selection, FCM notifications, reorder, empty states) are necessary production-quality additions that don't increase scope beyond a reasonable 1.0 release. The recommendation is to proceed with:

1. **14 screens** (Splash through Change Password) in the MVP
2. **4 backend modules** for MVP: Auth, Products/Categories, Cart/Orders, Users/Rewards
3. **26 API endpoints** supporting all MVP flows
4. **2 payment gateways**: MoMo + VNPay
5. **FCM integration** for order status notifications

**Estimated scope:** ~8–12 weeks for a team of 2 frontend + 2 backend engineers + 1 QA, assuming feature teams work in parallel on auth+menu (frontend) and auth+products (backend) during the first sprint.

---

*End of Specification Phase Document*
*Generated: June 7, 2026*
