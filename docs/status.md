# CFPV — Project Status

Last updated: 2026-06-08
Sprint: 1

---

## MVP Coverage

| Requirement | Status | Notes |
|------------|--------|-------|
| Login | ✅ | Phone/password + OTP verification |
| Register | ✅ | With OTP flow |
| Forgot Password | ✅ | OTP + reset |
| Categories (Menu) | ✅ | Chips + fetching |
| Product List | ✅ | 2-column grid |
| Product Detail | ✅ | Add-to-cart, nutrition, out-of-stock |
| Cart | ✅ | CRUD, quantity, totals |
| Checkout | ✅ | Order submission |
| Points Balance | ✅ | Rewards screen + history |
| User Profile | ✅ | Edit profile + change password |
| Order History | ✅ | List + Detail + Reorder |

---

## Screens (16 total)

### Unauthenticated (5)
| Screen | Route | File |
|--------|-------|------|
| Splash | `/` | `lib/features/splash/screens/splash_screen.dart` |
| Onboarding | `/onboarding` | `lib/features/onboarding/screens/onboarding_screen.dart` |
| Login | `/login` | `lib/features/auth/screens/login_screen.dart` |
| Register | `/register` | `lib/features/auth/screens/register_screen.dart` |
| Forgot Password | `/forgot-password` | `lib/features/auth/screens/forgot_password_screen.dart` |

### Authenticated (11)
| Screen | Route | File |
|--------|-------|------|
| Home | `/home` | `lib/features/home/screens/home_screen.dart` |
| Menu List | `/menu` | `lib/features/menu/presentation/pages/menu_list_page.dart` |
| Product Detail | `/menu/product/:productId` | `lib/features/menu/presentation/pages/product_detail_page.dart` |
| Cart | `/cart` | `lib/features/cart/presentation/pages/cart_page.dart` |
| Checkout | `/checkout` | `lib/features/checkout/presentation/pages/checkout_page.dart` |
| Rewards | `/rewards` | `lib/features/rewards/presentation/pages/rewards_page.dart` |
| Profile | `/profile` | `lib/features/profile/presentation/pages/profile_page.dart` |
| Edit Profile | `/profile/edit` | `lib/features/profile/presentation/pages/edit_profile_page.dart` |
| Change Password | `/profile/settings/change-password` | `lib/features/profile/presentation/pages/change_password_page.dart` |
| Order List | `/profile/orders` | `lib/features/orders/presentation/pages/orders_list_page.dart` |
| Order Detail | `/profile/orders/:orderId` | `lib/features/orders/presentation/pages/order_detail_page.dart` |

---

## Backend API

### Modules (9)
| Module | Endpoints |
|--------|-----------|
| Auth | register, verify-otp, login, forgot-password, reset-password, refresh |
| Users | GET/PATCH /me, avatar upload |
| Categories | GET /categories |
| Products | GET /products, /products/featured, /products/:id |
| Cart | GET, POST item, PATCH/DELETE item, clear, store, notes |
| Orders | POST order, GET list, GET :id, cancel, reorder |
| Rewards | GET balance, GET transactions |
| Notifications | POST/DELETE device |
| Uploads | POST avatar |

### Missing
- Stores module (CRUD, entity)
- VNPay / MoMo payment integration

---

## Tests (32 files)

| Area | Files | Scope |
|------|-------|-------|
| Auth screens | 3 | Login, Register, Forgot Password widget tests |
| Auth providers | 2 | Auth notifier, OTP timer |
| Splash | 2 | Screen + provider |
| Onboarding | 1 | Screen |
| Menu | 1 | Menu list page |
| Cart | 2 | Page + provider |
| Checkout | 1 | Page |
| Orders | 5 | List, Detail, provider, card, status badge, timeline |
| Profile | 3 | Profile, edit, change password |
| Rewards | 1 | Page |
| Shared widgets | 5 | Buttons (2), loading dots, cards, item row |
| Core services | 1 | Token service |
| Tab screens | 1 | Stub screens |
| Integration | 1 | App flow |

---

## Recent Changes (uncommitted)

- **App branding**: Logo changed from "CFPV" to "Coffee Phong Vũ" with coffee cup icon
- **Product images**: All products now have `imageUrl` via picsum.photos seeds
- **Featured items**: Home scroll now loads `CachedNetworkImage` with icon fallback
- **Menu items**: Product cards now load images via `CachedNetworkImage`
- **API fix**: APK built with `API_BASE_URL=http://192.168.1.4:3000/api/v1` for physical device
- **Login fix**: Backend login port conflict resolved, `_saveTokens` handles response format

---

## Tech Stack

- **Frontend**: Flutter 3.27.4, Riverpod, GoRouter
- **Backend**: NestJS 10, TypeORM, PostgreSQL, Redis
- **Infra**: Docker (postgres:16-alpine, redis:7-alpine)
- **CI**: GitHub Actions (flutter analyze + test)

---

## Known Issues

1. No order confirmation screen — navigates to Order History after checkout
2. Generic payment methods instead of VNPay/MoMo
3. No stores module (backend or frontend)
4. No settings screen
5. No size selector on product detail (Tall/Grande/Venti)
