# CFPV — Implementation Phase

> **Project:** CFPV (Cross-Platform Food & Beverage Application)
> **Status:** Draft Implementation Plan
> **Specification Source:** specs/specification-phase.md
> **Design Source:** specs/design-phase.md
> **Architecture Source:** docs/architecture.md
> **Target:** MVP Release 1.0

---

## Table of Contents

1. [Project Setup & Conventions](#1-project-setup--conventions)
2. [Flutter Frontend Structure](#2-flutter-frontend-structure)
3. [NestJS Backend Structure](#3-nestjs-backend-structure)
4. [Database Migration Sequence](#4-database-migration-sequence)
5. [Component Build Order (Dependency Graph)](#5-component-build-order-dependency-graph)
6. [Sprint-by-Sprint Delivery Timeline](#6-sprint-by-sprint-delivery-timeline)
7. [API Implementation Order](#7-api-implementation-order)
8. [Testing Strategy](#8-testing-strategy)
9. [CI/CD Pipeline](#9-cicd-pipeline)
10. [Infrastructure Setup](#10-infrastructure-setup)
11. [Risk Mitigation During Implementation](#11-risk-mitigation-during-implementation)
12. [Open Decisions Log](#12-open-decisions-log)

---

## 1. Project Setup & Conventions

### 1.1 Tech Stack Versions

| Component | Technology | Version (target) |
|-----------|------------|-------------------|
| Frontend Framework | Flutter | 3.24+ (stable channel) |
| State Management | Riverpod | 2.5+ (`flutter_riverpod`, `riverpod_annotation`) |
| Navigation | GoRouter | 14.0+ |
| Networking | Dio | 5.4+ |
| Local Storage | `flutter_secure_storage` | 9.0+ |
| Backend Framework | NestJS | 10.x |
| ORM | TypeORM | 0.3.x |
| Database | PostgreSQL | 15+ |
| Cache | Redis | 7.x |
| Payments | VNPay SDK, MoMo SDK | Latest per provider |
| Notifications | Firebase Cloud Messaging | `firebase_messaging` 15.0+ |
| Auth | `@nestjs/jwt`, `@nestjs/passport` | Latest |

### 1.2 Git Branching Strategy

```
main          ──●─────────────────────●── production
                  \                  /
develop          ──●────●────●────●── integration
                    \  /    \  /
feature/sprint-1   ──●───────●────●── feature branches
```

- **main:** Production-ready, protected, requires PR + CI green
- **develop:** Integration branch, daily merges from feature branches
- **feature/sprint-N-feature:** Naming: `feature/s1-auth`, `feature/s2-menu`
- **Conventional commits:** `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`

### 1.3 Code Quality Gates

| Gate | Tool | Threshold |
|------|------|-----------|
| Lint | `dart analyze` / ESLint | Zero warnings |
| Unit tests | `flutter test` / Jest | 80% coverage minimum |
| Widget tests | `flutter test` | All screens covered |
| E2E | Patrol / Playwright | Critical paths green |
| Security | `npm audit`, Trivy | Zero high severity |

### 1.4 Environment Configuration

```
.env.development  — Local dev (localhost:3000 API)
.env.staging      — Staging server (staging.cfpv.com)
.env.production   — Production (api.cfpv.com)

Flutter:
- API_BASE_URL
- VNPAY_RETURN_URL
- MOMO_RETURN_URL
- FCM_SENDER_ID

NestJS:
- DATABASE_URL (postgresql://...)
- REDIS_URL
- JWT_SECRET
- JWT_REFRESH_SECRET
- VNPAY_TMN_CODE / VNPAY_SECRET
- MOMO_PARTNER_CODE / MOMO_SECRET
- FCM_SERVER_KEY
- SMTP_HOST (for OTP fallback)
```

---

## 2. Flutter Frontend Structure

### 2.1 Top-Level Directory Layout

```
lib/
├── main.dart                          # App entry, ProviderScope, MaterialApp.router
├── app.dart                           # App widget, theme, router configuration
│
├── core/                              # Framework-level concerns
│   ├── constants/
│   │   ├── api_constants.dart          # Base URL, endpoint paths
│   │   ├── app_constants.dart          # Timeouts, limits, feature flags
│   │   └── storage_keys.dart           # Secure storage key names
│   ├── errors/
│   │   ├── app_exception.dart          # Base exception class
│   │   ├── api_exception.dart          # Dio error mapping
│   │   └── error_handler.dart          # Global error handler
│   ├── network/
│   │   ├── dio_client.dart             # Dio singleton with interceptors
│   │   ├── auth_interceptor.dart       # JWT injection + refresh logic
│   │   ├── cache_interceptor.dart      # Redis-aware caching
│   │   └── api_response.dart           # Generic ApiResponse<T>
│   ├── router/
│   │   ├── app_router.dart             # GoRouter configuration
│   │   ├── auth_guard.dart             # Redirect unauthenticated users
│   │   └── route_paths.dart            # Route constant definitions
│   └── services/
│       ├── secure_storage_service.dart  # FlutterSecureStorage wrapper
│       ├── token_service.dart           # Access + refresh token management
│       └── deep_link_service.dart       # FCM deep link handling
│
├── shared/                             # Reusable UI components
│   ├── theme/
│   │   ├── app_theme.dart              # ThemeData construction
│   │   ├── colors.dart                 # CFPVColors class
│   │   ├── typography.dart             # CFPVTypography styles
│   │   ├── spacing.dart                # CFPVSpacing constants
│   │   ├── elevation.dart              # CFPVElevation shadows
│   │   └── radius.dart                 # CFPVRoundRadius constants
│   ├── widgets/
│   │   ├── buttons/
│   │   │   ├── primary_pill_button.dart
│   │   │   ├── primary_pill_button_full_width.dart
│   │   │   ├── outlined_pill_button.dart
│   │   │   ├── dark_outlined_button.dart
│   │   │   ├── green_inverted_button.dart
│   │   │   ├── outlined_on_dark_button.dart
│   │   │   └── frap_cta_button.dart
│   │   ├── cards/
│   │   │   ├── content_card.dart
│   │   │   ├── category_tile.dart
│   │   │   ├── product_card.dart
│   │   │   └── menu_row_card.dart
│   │   ├── inputs/
│   │   │   ├── floating_label_input.dart
│   │   │   ├── password_input.dart
│   │   │   ├── otp_input.dart
│   │   │   ├── numeric_stepper.dart
│   │   │   └── toggle_switch.dart
│   │   ├── navigation/
│   │   │   ├── cfpv_tab_bar.dart
│   │   │   ├── app_bar_back.dart
│   │   │   ├── app_bar_home.dart
│   │   │   └── subcategory_chips.dart
│   │   ├── feedback/
│   │   │   ├── status_badge.dart
│   │   │   ├── empty_state.dart
│   │   │   ├── loading_skeleton.dart
│   │   │   ├── error_state.dart
│   │   │   ├── snackbar_helper.dart
│   │   │   └── order_status_timeline.dart
│   │   └── layout/
│   │       ├── section_header.dart
│   │       ├── price_row.dart
│   │       └── page_indicator.dart
│   └── extensions/
│       ├── context_extensions.dart
│       ├── string_extensions.dart
│       └── number_format.dart
│
├── features/                           # Feature modules (isolated)
│   ├── splash/
│   │   ├── screens/
│   │   │   └── splash_screen.dart
│   │   └── providers/
│   │       └── splash_provider.dart     # Auth check logic
│   │
│   ├── onboarding/
│   │   ├── screens/
│   │   │   └── onboarding_screen.dart
│   │   └── widgets/
│   │       └── onboarding_slide.dart
│   │
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── widgets/
│   │   │   ├── otp_verification.dart
│   │   │   └── password_requirements.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart        # AuthNotifier: login/register/logout
│   │   │   ├── auth_state.dart           # AuthState sealed class
│   │   │   └── otp_timer_provider.dart   # Resend countdown
│   │   └── repositories/
│   │       └── auth_repository.dart      # API calls + token storage
│   │
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   ├── widgets/
│   │   │   ├── home_app_bar.dart
│   │   │   ├── hero_banner.dart
│   │   │   ├── quick_action_card.dart
│   │   │   └── featured_items_scroll.dart
│   │   ├── providers/
│   │   │   ├── home_provider.dart
│   │   │   └── featured_products_provider.dart
│   │   └── repositories/
│   │       └── home_repository.dart
│   │
│   ├── menu/
│   │   ├── screens/
│   │   │   ├── category_list_screen.dart
│   │   │   ├── product_list_screen.dart
│   │   │   └── product_detail_screen.dart
│   │   ├── widgets/
│   │   │   ├── size_selector.dart
│   │   │   ├── nutrition_summary.dart
│   │   │   ├── nutrition_table.dart
│   │   │   └── product_action_bar.dart
│   │   ├── providers/
│   │   │   ├── categories_provider.dart
│   │   │   ├── products_provider.dart
│   │   │   └── product_detail_provider.dart
│   │   └── repositories/
│   │       ├── category_repository.dart
│   │       └── product_repository.dart
│   │
│   ├── cart/
│   │   ├── screens/
│   │   │   └── cart_screen.dart
│   │   ├── widgets/
│   │   │   ├── cart_item_card.dart
│   │   │   ├── cart_summary_bar.dart
│   │   │   └── cart_store_selector.dart
│   │   ├── providers/
│   │   │   ├── cart_provider.dart
│   │   │   ├── cart_item_count_provider.dart
│   │   │   └── cart_total_provider.dart
│   │   └── repositories/
│   │       └── cart_repository.dart
│   │
│   ├── checkout/
│   │   ├── screens/
│   │   │   ├── checkout_screen.dart
│   │   │   └── order_confirmation_screen.dart
│   │   ├── widgets/
│   │   │   ├── store_selection_card.dart
│   │   │   ├── order_summary_card.dart
│   │   │   ├── payment_method_selector.dart
│   │   │   ├── notes_text_area.dart
│   │   │   └── order_progress_bar.dart
│   │   ├── providers/
│   │   │   ├── checkout_provider.dart
│   │   │   ├── payment_provider.dart
│   │   │   └── store_selection_provider.dart
│   │   └── repositories/
│   │       ├── order_repository.dart
│   │       └── store_repository.dart
│   │
│   ├── rewards/
│   │   ├── screens/
│   │   │   └── rewards_screen.dart
│   │   ├── widgets/
│   │   │   ├── points_hero.dart
│   │   │   └── points_history_tile.dart
│   │   ├── providers/
│   │   │   └── rewards_provider.dart
│   │   └── repositories/
│   │       └── rewards_repository.dart
│   │
│   ├── orders/
│   │   ├── screens/
│   │   │   ├── order_history_screen.dart
│   │   │   └── order_detail_screen.dart
│   │   ├── widgets/
│   │   │   ├── order_history_row.dart
│   │   │   └── status_timeline.dart
│   │   ├── providers/
│   │   │   └── orders_provider.dart
│   │   └── repositories/
│   │       └── order_repository.dart
│   │
│   └── profile/
│       ├── screens/
│       │   ├── profile_screen.dart
│       │   ├── edit_profile_screen.dart
│       │   ├── settings_screen.dart
│       │   └── change_password_screen.dart
│       ├── widgets/
│       │   ├── profile_header_card.dart
│       │   └── avatar_picker.dart
│       ├── providers/
│       │   ├── profile_provider.dart
│       │   └── settings_provider.dart
│       └── repositories/
│           └── user_repository.dart
│
└── services/                           # Cross-cutting services
    └── notifications/
        ├── fcm_service.dart            # Firebase messaging init + handlers
        ├── notification_provider.dart  # Riverpod provider for FCM state
        └── notification_permissions.dart
```

### 2.2 Shared Component Inventory

The following table maps each DESIGN.md component to its Flutter file and the screens that consume it.

| Component | File | Consumed By |
|-----------|------|-------------|
| PrimaryFilledButton | `shared/widgets/buttons/primary_pill_button.dart` | All screens with CTAs |
| FullWidthPrimary | `...primary_pill_button_full_width.dart` | Cart, Checkout, Home |
| PrimaryOutlined | `...outlined_pill_button.dart` | Order Confirmation |
| GreenInverted | `...green_inverted_button.dart` | (PDP hero band - post-MVP) |
| ContentCard | `shared/widgets/cards/content_card.dart` | All section cards |
| CategoryTile | `...category_tile.dart` | Menu Category List |
| ProductCard | `...product_card.dart` | Product List, Featured scroll |
| FloatingLabelInput | `shared/widgets/inputs/floating_label_input.dart` | Login, Register, Edit Profile, Change Password |
| PasswordInput | `...password_input.dart` | Login, Register, Forgot Password, Change Password |
| OTPInput | `...otp_input.dart` | Register, Forgot Password |
| NumericStepper | `...numeric_stepper.dart` | PDP, Cart |
| ToggleSwitch | `...toggle_switch.dart` | Settings |
| CFPVTabBar | `shared/widgets/navigation/cfpv_tab_bar.dart` | All authenticated root screens |
| SubcategoryChips | `...subcategory_chips.dart` | Product List |
| SizeSelector | `menu/widgets/size_selector.dart` | PDP |
| StatusBadge | `shared/widgets/feedback/status_badge.dart` | Order History |
| EmptyState | `...empty_state.dart` | Cart (empty), Order History (empty) |
| LoadingSkeleton | `...loading_skeleton.dart` | All list screens |
| OrderStatusTimeline | `...order_status_timeline.dart` | Order Detail |
| FrapCTA | `shared/widgets/buttons/frap_cta_button.dart` | Home, Menu, PDP, Rewards, Profile |

---

## 3. NestJS Backend Structure

### 3.1 Module Directory Layout

```
src/
├── main.ts                              # Bootstrap, validation pipe, CORS
├── app.module.ts                        # Root module imports
├── common/                              # Shared cross-cutting concerns
│   ├── decorators/
│   │   ├── current-user.decorator.ts    # @CurrentUser() param decorator
│   │   └── public.decorator.ts          # @Public() skips auth guard
│   ├── guards/
│   │   ├── jwt-auth.guard.ts            # Global JWT guard
│   │   └── throttle.guard.ts            # Rate limiting
│   ├── interceptors/
│   │   ├── response-transform.interceptor.ts  # Wraps { data, meta }
│   │   ├── logging.interceptor.ts       # Request/response logging
│   │   └── cache.interceptor.ts         # Redis cache logic
│   ├── filters/
│   │   └── http-exception.filter.ts     # Consistent error format
│   ├── pipes/
│   │   └── validation.pipe.ts           # DTO validation
│   ├── dto/
│   │   ├── pagination.dto.ts            # page, limit query params
│   │   └── api-response.dto.ts          # Generic response wrapper
│   └── constants/
│       └── app.constants.ts             # App-wide constants
│
├── config/                              # Configuration modules
│   ├── database/
│   │   ├── database.module.ts            # TypeORM config
│   │   └── database.config.ts            # Env-based config factory
│   ├── redis/
│   │   ├── redis.module.ts               # Redis client setup
│   │   └── redis.config.ts
│   └── auth/
│       └── jwt.config.ts                  # JWT secret, expiry
│
├── modules/
│   ├── auth/
│   │   ├── auth.module.ts
│   │   ├── auth.controller.ts             # POST /register, /login, /refresh, /logout
│   │   ├── auth.service.ts                # Business logic
│   │   ├── auth.guard.ts                  # JwtAuthGuard
│   │   ├── strategies/
│   │   │   ├── jwt.strategy.ts            # Passport JWT strategy
│   │   │   └── jwt-refresh.strategy.ts    # Refresh token strategy
│   │   ├── dto/
│   │   │   ├── register.dto.ts
│   │   │   ├── register-verify.dto.ts
│   │   │   ├── login.dto.ts
│   │   │   ├── refresh.dto.ts
│   │   │   ├── forgot-password.dto.ts
│   │   │   └── reset-password.dto.ts
│   │   ├── otp/
│   │   │   ├── otp.service.ts             # Generate, verify, expire OTP
│   │   │   └── sms-provider.service.ts    # SMS gateway integration
│   │   └── tests/
│   │       ├── auth.controller.spec.ts
│   │       └── auth.service.spec.ts
│   │
│   ├── users/
│   │   ├── users.module.ts
│   │   ├── users.controller.ts            # GET/PUT /users/me, /users/me/password, /users/me/settings
│   │   ├── users.service.ts
│   │   ├── entities/
│   │   │   └── user.entity.ts
│   │   ├── dto/
│   │   │   ├── update-profile.dto.ts
│   │   │   ├── change-password.dto.ts
│   │   │   └── update-settings.dto.ts
│   │   └── tests/
│   │       └── users.service.spec.ts
│   │
│   ├── products/
│   │   ├── products.module.ts
│   │   ├── products.controller.ts         # GET /products, /products/featured, /products/:id, /products/:id/nutrition
│   │   ├── products.service.ts
│   │   ├── entities/
│   │   │   ├── product.entity.ts
│   │   │   ├── product-variant.entity.ts
│   │   │   └── product-store.entity.ts    # (MVP: simplified to Product.is_available)
│   │   └── tests/
│   │       └── products.service.spec.ts
│   │
│   ├── categories/
│   │   ├── categories.module.ts
│   │   ├── categories.controller.ts       # GET /categories
│   │   ├── categories.service.ts
│   │   ├── entities/
│   │   │   └── category.entity.ts
│   │   └── tests/
│   │       └── categories.service.spec.ts
│   │
│   ├── cart/
│   │   ├── cart.module.ts
│   │   ├── cart.controller.ts             # GET /cart, POST /cart/items, PUT /cart/items/:id, DELETE /cart/items/:id, PUT /cart/store, PUT /cart/notes
│   │   ├── cart.service.ts
│   │   ├── entities/
│   │   │   ├── cart.entity.ts
│   │   │   └── cart-item.entity.ts
│   │   ├── dto/
│   │   │   ├── add-cart-item.dto.ts
│   │   │   ├── update-cart-item.dto.ts
│   │   │   ├── update-cart-store.dto.ts
│   │   │   └── update-cart-notes.dto.ts
│   │   └── tests/
│   │       └── cart.service.spec.ts
│   │
│   ├── orders/
│   │   ├── orders.module.ts
│   │   ├── orders.controller.ts           # POST /orders, POST /orders/:id/confirm-payment, GET /orders, GET /orders/:id, POST /orders/:id/reorder
│   │   ├── orders.service.ts
│   │   ├── entities/
│   │   │   ├── order.entity.ts
│   │   │   └── order-item.entity.ts
│   │   ├── dto/
│   │   │   ├── create-order.dto.ts
│   │   │   └── confirm-payment.dto.ts
│   │   ├── payments/
│   │   │   ├── payment-gateway.interface.ts
│   │   │   ├── momo.service.ts
│   │   │   └── vnpay.service.ts
│   │   └── tests/
│   │       ├── orders.service.spec.ts
│   │       └── payment.service.spec.ts
│   │
│   ├── stores/
│   │   ├── stores.module.ts
│   │   ├── stores.controller.ts           # GET /stores
│   │   ├── stores.service.ts
│   │   ├── entities/
│   │   │   └── store.entity.ts
│   │   └── tests/
│   │       └── stores.service.spec.ts
│   │
│   ├── rewards/
│   │   ├── rewards.module.ts
│   │   ├── rewards.controller.ts          # GET /rewards/balance, GET /rewards/transactions
│   │   ├── rewards.service.ts            # Point calculation, earn, ledger
│   │   ├── entities/
│   │   │   └── reward-transaction.entity.ts
│   │   └── tests/
│   │       └── rewards.service.spec.ts
│   │
│   └── notifications/
│       ├── notifications.module.ts
│       ├── notifications.controller.ts    # POST /notifications/device
│       ├── notifications.service.ts       # FCM send + device registration
│       ├── entities/
│       │   └── device-token.entity.ts
│       └── tests/
│           └── notifications.service.spec.ts
│
├── uploads/                               # File upload module
│   ├── uploads.module.ts
│   ├── uploads.controller.ts              # POST /uploads/avatar
│   └── uploads.service.ts
│
└── database/
    ├── migrations/                        # TypeORM migration files
    │   ├── 001_create_users_table.ts
    │   ├── 002_create_categories_table.ts
    │   ├── 003_create_products_table.ts
    │   ├── 004_create_product_variants.ts
    │   ├── 005_create_stores_table.ts
    │   ├── 006_create_carts_table.ts
    │   ├── 007_create_cart_items_table.ts
    │   ├── 008_create_orders_table.ts
    │   ├── 009_create_order_items_table.ts
    │   ├── 010_create_reward_transactions.ts
    │   └── 011_create_device_tokens.ts
    └── seeds/
        ├── seed-categories.ts             # Initial category data
        ├── seed-products.ts               # Initial product + variant data
        └── seed-stores.ts                 # Initial store data
```

### 3.2 Module Dependency Graph

```
auth ────▶ users
            │
            ▼
categories ──▶ products ──▶ cart
                              │
                              ▼
stores ──▶ orders ◀── payments (MoMo / VNPay)
            │
            ▼
rewards ──▶ users (points credit)

notifications (standalone, called from orders service)
uploads (standalone, called from users controller)
```

### 3.3 Entity Relationship (NestJS Decorator View)

```
User
├── @OneToOne(() => Cart, cart => cart.user)
├── @OneToMany(() => Order, order => order.user)
└── @OneToMany(() => RewardTransaction, tx => tx.user)

Cart
└── @OneToMany(() => CartItem, item => item.cart)

CartItem
├── @ManyToOne(() => Product)
└── @ManyToOne(() => ProductVariant, { nullable: true })

Category
└── @OneToMany(() => Product, product => product.category)

Product
├── @ManyToOne(() => Category)
├── @OneToMany(() => ProductVariant, variant => variant.product)
├── @OneToMany(() => CartItem, item => item.product)
└── @OneToMany(() => OrderItem, item => item.product)

ProductVariant
└── @ManyToOne(() => Product)

Order
├── @ManyToOne(() => User)
├── @OneToMany(() => OrderItem, item => item.order)
└── @Column({ type: 'enum' }) status

OrderItem
├── @ManyToOne(() => Order)
└── @ManyToOne(() => Product)

Store
└── (standalone for MVP)

RewardTransaction
├── @ManyToOne(() => User)
└── @ManyToOne(() => Order, { nullable: true })

DeviceToken
├── @ManyToOne(() => User)
└── @Column() platform: 'android' | 'ios'
```

---

## 4. Database Migration Sequence

### 4.1 Ordered Migration Plan

| Order | Migration Name | Tables Created | Dependencies |
|-------|---------------|----------------|--------------|
| 001 | `CreateUsersTable` | `users` | None — foundation table |
| 002 | `CreateCategoriesTable` | `categories` | None — reference data |
| 003 | `CreateProductsTable` | `products` (includes `is_available` field per MENU-09) | 002 (FK → categories) |
| 004 | `CreateProductVariants` | `product_variants` | 003 (FK → products) |
| 005 | `CreateStoresTable` | `stores` | None — reference data |
| 006 | `CreateCartsTable` | `carts` | 001 (FK → users) |
| 007 | `CreateCartItemsTable` | `cart_items` | 006 (FK → carts), 003 (FK → products), 004 (FK → variants) |
| 008 | `CreateOrdersTable` | `orders` | 001 (FK → users), 005 (FK → stores) |
| 009 | `CreateOrderItemsTable` | `order_items` | 008 (FK → orders), 003 (FK → products) |
| 010 | `CreateRewardTransactions` | `reward_transactions` | 001 (FK → users), 008 (FK → orders) |
| 011 | `CreateDeviceTokens` | `device_tokens` | 001 (FK → users) |

### 4.2 Migration File Pattern (TypeORM)

```typescript
// 001_create_users_table.ts
import { MigrationInterface, QueryRunner, Table, TableIndex } from 'typeorm';

export class CreateUsersTable1710000000000 implements MigrationInterface {
    name = 'CreateUsersTable1710000000000';

    async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.createTable(new Table({
            name: 'users',
            columns: [
                { name: 'id', type: 'uuid', isPrimary: true, generationStrategy: 'uuid', default: 'uuid_generate_v4()' },
                { name: 'phone', type: 'varchar', length: '15', isUnique: true },
                { name: 'email', type: 'varchar', length: '255', isNullable: true },
                { name: 'full_name', type: 'varchar', length: '100' },
                { name: 'password_hash', type: 'varchar', length: '255' },
                { name: 'avatar_url', type: 'varchar', length: '500', isNullable: true },
                { name: 'phone_verified_at', type: 'timestamp', isNullable: true },
                { name: 'refresh_token_hash', type: 'varchar', length: '255', isNullable: true },
                { name: 'notification_enabled', type: 'boolean', default: true },
                { name: 'promotion_notification_enabled', type: 'boolean', default: true },
                { name: 'created_at', type: 'timestamp', default: 'now()' },
                { name: 'updated_at', type: 'timestamp', default: 'now()', onUpdate: 'now()' },
            ],
        }), true);

        await queryRunner.createIndex('users', new TableIndex({
            name: 'IDX_USERS_PHONE',
            columnNames: ['phone'],
            isUnique: true,
        }));
        await queryRunner.createIndex('users', new TableIndex({
            name: 'IDX_USERS_EMAIL',
            columnNames: ['email'],
            isUnique: true,
        }));
    }

    async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropTable('users');
    }
}
```

### 4.3 Seed Data Requirements

| Seed File | Data | Quantity (MVP) |
|-----------|------|-----------------|
| `seed-categories.ts` | Beverages, Food, Merchandise, At Home | 4 categories |
| `seed-products.ts` | Caffè Latte, Latte Macchiato, Mocha, Americano, Chicken Sandwich, ... etc | 12-20 products |
| `seed-product-variants.ts` | Tall/Grande/Venti per beverage product | ~3 per beverage |
| `seed-stores.ts` | Initial store(s) with name, address, hours | 1-3 stores |

---

## 5. Component Build Order (Dependency Graph)

### 5.1 Layer 0: Foundation (Build First — Sprint 1)

```
Flutter Foundation             Backend Foundation
├── Theme system               ├── NestJS project scaffold
│   ├── colors.dart            ├── Database connection
│   ├── typography.dart        ├── Redis connection
│   ├── spacing.dart           ├── JWT auth module
│   ├── elevation.dart         ├── Common interceptors
│   └── radius.dart            └── Exception filters
├── Dio client
│   ├── api_client.dart
│   ├── auth_interceptor.dart
│   └── cache_interceptor.dart
├── Secure storage service
├── GoRouter setup
│   ├── app_router.dart
│   └── auth_guard.dart
├── Shared primitives
│   ├── primary_pill_button.dart
│   ├── content_card.dart
│   ├── floating_label_input.dart
│   ├── section_header.dart
│   └── loading_skeleton.dart
└── Riverpod providers
    └── auth_state.dart
```

### 5.2 Layer 1: Auth Feature (Sprint 1-2)

```
Flutter                         Backend
├── Splash screen               ├── Auth controller + service
├── Onboarding screen           ├── OTP service
├── Login screen                ├── Users controller + service
├── Register screen             ├── JWT strategy
├── Forgot Password screen      └── User entity
├── Auth provider flow
└── Token management
```

### 5.3 Layer 2: Menu + Products (Sprint 2-3)

```
Flutter                         Backend
├── Category tile               ├── Categories controller + service
├── Product card                ├── Products controller + service
├── Size selector               ├── Category entity
├── Nutrition components        ├── Product entity
├── Subcategory chips           └── ProductVariant entity
├── Category list screen
├── Product list screen
├── Product detail screen
├── Frap CTA button
└── Categories + Products providers
```

### 5.4 Layer 3: Cart (Sprint 3)

```
Flutter                         Backend
├── Cart item card              ├── Cart controller + service
├── Numeric stepper             ├── Cart entity
├── Cart summary bar            ├── CartItem entity
├── Empty state                 └── Cart endpoints
├── Cart screen
├── Cart providers
└── Badge on tab bar
```

### 5.5 Layer 4: Checkout + Orders (Sprint 4-5)

```
Flutter                         Backend
├── Store selector              ├── Orders controller + service
├── Payment method selector     ├── Order entity
├── Order summary card          ├── OrderItem entity
├── Order progress bar          ├── Store controller + service
├── Status badge                ├── Store entity
├── Status timeline             ├── MoMo service
├── Checkout screen             ├── VNPay service
├── Order confirmation screen   └── Orders endpoints
├── Order history screen
├── Order detail screen
├── Checkout provider
├── Payment provider
└── FCM notification handler
```

### 5.6 Layer 5: Rewards (Sprint 5)

```
Flutter                         Backend
├── Points hero band            ├── Rewards controller + service
├── Points history tile         ├── RewardTransaction entity
├── Rewards screen              └── Rewards endpoints
└── Rewards provider
```

### 5.7 Layer 6: Profile + Settings (Sprint 5-6)

```
Flutter                         Backend
├── Profile header card         └── (Uses existing Users endpoints)
├── Menu row card
├── Avatar picker
├── Toggle switch
├── Profile screen
├── Edit profile screen
├── Settings screen
├── Change password screen
├── Profile provider
└── Settings provider
```

### 5.8 Layer 7: Polish + Integration (Sprint 6-7)

```
Flutter                         Backend
├── Home screen                 ├── Uploads module
│   ├── Hero banner             ├── Notifications module
│   ├── Quick action cards      ├── Reward points credit on order complete
│   ├── Featured products       └── FCM send on order events
│   └── Category chips
├── Deep link handling
├── Order polling (FCM fallback)
├── Error states all screens
├── Loading skeletons all screens
├── Pull-to-refresh all lists
├── Accessibility pass
│   ├── Semantics labels
│   ├── Screen reader testing
│   └── Touch target audit
└── Performance profiling
    ├── Image lazy loading
    ├── List viewport caching
    └── Animation jank check
```

---

## 6. Sprint-by-Sprint Delivery Timeline

### 6.1 Sprint Overview

| Sprint | Duration | Focus | Frontend (2 devs) | Backend (2 devs) | QA (1) |
|--------|----------|-------|-------------------|------------------|--------|
| S1 | 10 days | Foundation + Auth | Theme system, router, shared components, auth screens + minimal Home stub | NestJS scaffold, database, JWT auth, OTP, users | Write E2E auth scenarios |
| S2 | 10 days | Menu + Products | Category list, product list, product detail + minimal Home screen (greeting + categories shortcut) | Categories, products, variants APIs, seed data + rate limiter middleware | Test menu CRUD flow |
| S3 | 10 days | Cart | Cart screen, item management, store selector + store picker modal | Cart APIs, store APIs | Test add/remove/update cart |
| S4 | 10 days | Checkout + Payments | Checkout screen, payment selection, order confirmation | Orders, MoMo/VNPay integration, webhook handling, notifications module setup | Test full order flow |
| S5 | 10 days | Orders + Rewards | Order history, order detail, rewards screen | Order history, rewards ledger, FCM event integration (using notifications module from S4) | Test order + rewards lifecycle |
| S6 | 10 days | Profile + Home (full) | Profile, settings, edit profile, full Home screen (hero, quick actions, featured) | Uploads, notification settings, Home endpoint optimization | Test profile CRUD, notification delivery |
| S7 | 5 days | Polish | Animations, loading states, empty states, error handling, accessibility | Performance tuning, error logging, endpoint optimization | Regression test all flows |
| S8 | 5 days | Hardening | Bug fixes, device testing (top 10 Vietnam devices), App Store prep | Security audit, load test, monitoring setup | Acceptance testing, sign-off |

**Total: 10 weeks** (6 × 10-day sprints + 2 × 5-day sprints = 70 working days)

### 6.2 Sprint 1 Detail: Foundation + Auth

**Goal:** Developer environment ready, both apps can register, log in, and persist sessions. Build a **minimal Home stub** so users aren't left on a blank screen after login.

**Additional Flutter task (S1):**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Build minimal `HomeScreen` stub with greeting + category chips placeholder (uses categories from S2) | 4 | Auth flow |

**Flutter Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Scaffold Flutter project, set up Riverpod, GoRouter | 4 | None |
| Build theme system (`colors.dart`, `typography.dart`, `spacing.dart`, `elevation.dart`, `radius.dart`) | 8 | None |
| Build `DioClient` with `AuthInterceptor` | 6 | Theme done |
| Build `SecureStorageService` + `TokenService` | 4 | None |
| Build `GoRouter` with `AuthGuard`, define all route paths | 4 | Auth service |
| Build shared primitives: `PrimaryPillButton`, `ContentCard`, `FloatingLabelInput`, `SectionHeader` | 12 | Theme done |
| Build `SplashScreen` with auth check logic | 4 | Auth guard |
| Build `OnboardingScreen` with 3 slides | 6 | Shared primitives |
| Build `LoginScreen` with validation | 8 | Inputs, CTA, Auth provider |
| Build `RegisterScreen` with OTP flow | 10 | Inputs, OTP input, Auth provider |
| Build `ForgotPasswordScreen` | 8 | Inputs, OTP input |
| Build `AuthProvider`/notifier with login/register/logout/refresh | 8 | Dio client |
| Unit test auth provider | 4 | Auth provider |
| Widget test login, register screens | 6 | Auth screens |
| Accessibility labels on auth screens | 2 | Auth screens |

**NestJS Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Scaffold NestJS project with TypeORM, config module | 4 | None |
| Set up PostgreSQL connection, `uuid-ossp` extension | 2 | DB access |
| Set up Redis client module | 2 | Redis access |
| Create migration: `001_users` | 3 | Database setup |
| Create `User` entity | 2 | Migration done |
| Build `AuthModule`: controller, service, JWT strategy, refresh strategy | 16 | User entity |
| Build `OTPService`: generate, verify, expire OTP; **hardcoded OTP `131017`** for MVP; SmsProviderInterface for future SMS integration | 6 | None |
| Build `UsersController`: GET/PUT `/users/me` | 6 | Auth module |
| Build `ChangePassword` endpoint | 4 | Auth module |
| Create `JwtAuthGuard` (global) + `@Public()` decorator | 3 | Auth module |
| Create `HttpExceptionFilter` + `ResponseTransformInterceptor` | 4 | NestJS scaffold |
| Create `ValidationPipe` with DTO validation | 3 | NestJS scaffold |
| Build `ThrottleGuard` for rate limiting auth endpoints | 3 | NestJS scaffold |
| Write auth controller/serive unit tests | 8 | Auth module |
| Create Postman/Insomnia collection for auth | 2 | API ready |

**QA Tasks:**
| Task | Hours |
|------|-------|
| Write E2E test scenarios: Register → OTP → Login → Refresh → Logout | 8 |
| Test OTP timeout flow | 4 |
| Test rate limiting on auth endpoints | 2 |
| Validate secure storage behavior (app restart, token expiry) | 4 |

**Sprint 1 Deliverables:**
- ✅ Flutter app boots, navigates from Splash → Login → Home (when authenticated)
- ✅ User can register with phone + OTP, log in, log out
- ✅ Session persists across app restarts (refresh token rotation)
- ✅ Backend: Auth + Users modules deployed to staging
- ✅ CI pipeline: lint + unit tests pass

### 6.3 Sprint 2 Detail: Menu + Products

**Flutter Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Build `CategoryTile` component | 3 | Shared card |
| Build `ProductCard` component | 4 | Shared card |
| Build `SizeSelector` component | 6 | Shared buttons |
| Build `NutritionSummary` + `NutritionTable` components | 6 | Shared card |
| Build `SubcategoryChips` component | 3 | None |
| Build `FrapCTAButton` component | 2 | Theme |
| Build `HomeAppBar` with points badge + cart icon | 4 | Theme |
| Build `HomeScreen` layout (hero, quick actions, featured, categories) | 12 | All components |
| Build `CategoryListScreen` with 2-column grid | 6 | CategoryTile |
| Build `ProductListScreen` with subcategory chips + infinite scroll | 8 | ProductCard |
| Build `ProductDetailScreen` with size selector + add to order | 14 | SizeSelector, Nutrition, Stepper |
| Build `CategoriesProvider` | 4 | Dio client |
| Build `ProductsProvider` (list + detail) | 6 | Dio client |
| Widget test: Home, Category List, Product List, PDP | 10 | Screens done |
| Unit test: Categories/Products providers | 4 | Providers done |

**NestJS Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Create migrations: `002_categories`, `003_products`, `004_product_variants` | 6 | Users table |
| Create `Category`, `Product`, `ProductVariant` entities | 6 | Migrations done |
| Build `CategoriesController` + `CategoriesService` | 8 | Category entity |
| Build `ProductsController` + `ProductsService` | 12 | Product entity |
| Add Redis caching to GET categories, products: `/products?categoryId=...` | 6 | Redis module |
| Create seed data: categories (4), products (12-20), variants (per beverage) | 8 | Entities done |
| Add `is_available` field handling (MENU-09 out-of-stock) | 3 | Products service |
| Write products/categories service tests | 6 | Services done |
| Create `GET /products/featured` endpoint | 3 | Products service |

**Sprint 2 Deliverables:**
- ✅ Menu screens: Categories → Products → Product Detail with size selector
- ✅ Home screen shows featured products and categories
- ✅ Products cached in Redis
- ✅ Seed data populates menu
- ✅ Backend: Products + Categories modules deployed

### 6.4 Sprint 3 Detail: Cart

**Flutter Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Build `CartItemCard` component | 4 | NumericStepper |
| Build `CartSummaryBar` component | 3 | Shared |
| Build `CartStoreSelector` component | 3 | Store proxy |
| Build `EmptyState` component with illustration + CTA | 3 | Shared |
| Build `CartScreen` with item list, store selector, summary, checkout CTA | 10 | All cart components |
| Build `CartProvider` (load, add, remove, update, clear) | 8 | Dio client |
| Build `CartItemCountProvider` (badge number) | 3 | Cart provider |
| Build `CartTotalProvider` (computed totals) | 2 | Cart provider |
| Add cart badge to tab bar | 2 | Tab bar widget |
| Wire "Add to Order" button in PDP to cart | 4 | Cart provider |
| Widget test: Cart screen (items view, empty state, quantity changes) | 8 | Cart screen |
| Unit test: Cart provider operations | 4 | Cart provider |

**NestJS Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Create migrations: `005_stores`, `006_carts`, `007_cart_items` | 6 | Users, Products |
| Create `Cart`, `CartItem`, `Store` entities | 6 | Migrations done |
| Build `CartController` + `CartService` (all 6 endpoints) | 14 | Cart + CartItem entities |
| Build `StoresController` + `StoresService` | 6 | Store entity |
| Create store seed data | 2 | Store entity |
| Write cart service unit tests | 6 | Services done |
| Add IDOR check: verify cart.userId === request.user.id | 3 | Cart service |

**Sprint 3 Deliverables:**
- ✅ Users can add products to cart from PDP
- ✅ Cart screen shows items with quantity controls, store selection
- ✅ Empty cart state displays correctly
- ✅ Cart persists on server (API-backed)
- ✅ Backend: Cart + Stores modules deployed

### 6.5 Sprint 4 Detail: Checkout + Payments

**Flutter Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Build `StoreSelectionCard` component | 3 | ContentCard |
| Build `PaymentMethodSelector` with MoMo/VNPay radio | 6 | Shared radio |
| Build `NotesTextArea` component | 3 | Input style |
| Build `CheckoutScreen` with store, order summary, notes, payment | 12 | All above |
| Build `OrderProgressBar` component | 4 | Theme |
| Build `OrderConfirmationScreen` with checkmark animation | 8 | Shared |
| Build `CheckoutProvider` (submit order, handle payment redirect) | 10 | Dio + Deep links |
| Build `PaymentProvider` (launch gateway, handle return URL) | 8 | Dio |
| Integrate MoMo SDK (Flutter) | 8 | Payment module |
| Integrate VNPay SDK (Flutter) | 8 | Payment module |
| Wire deep link handling for payment redirect | 4 | Deep link service |
| Widget test: Checkout, Order Confirmation | 6 | Screens done |
| E2E test: Full checkout flow (mock payment) | 8 | All integrated |

**NestJS Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Create migrations: `008_orders`, `009_order_items` | 6 | Users, Products |
| Create `Order`, `OrderItem` entities with status enums | 6 | Migrations done |
| Build `OrdersController` + `OrdersService` (create, confirm, list, detail, reorder) | 16 | Order entity |
| Build `PaymentGatewayInterface` | 3 | None |
| Build `MoMoService`: create payment, verify IPN | 10 | Payment interface |
| Build `VNPayService`: create payment URL, verify IPN | 10 | Payment interface |
| Build payment webhook/confirm-payment endpoint | 6 | Orders + payments |
| Add points-earned calculation on order completion | 4 | Rewards module collaboration |
| Write orders service unit tests | 8 | Orders service |
| Write payment service unit tests (mock gateway) | 6 | Payment services |

**Sprint 4 Deliverables:**
- ✅ Full checkout flow: Cart → Checkout → Payment → Confirmation
- ✅ MoMo payment integration working (staging)
- ✅ VNPay payment integration working (staging)
- ✅ Order created in `pending_payment` → `confirmed` → `preparing` → `ready` flow
- ✅ Backend: Orders + Payments modules deployed

### 6.6 Sprint 5 Detail: Orders + Rewards

**Flutter Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Build `OrderHistoryRow` component with status badge | 4 | StatusBadge |
| Build `StatusBadge` component | 2 | Theme |
| Build `StatusTimeline` component (vertical) | 6 | Theme |
| Build `OrderHistoryScreen` with date grouping | 8 | OrderHistoryRow |
| Build `OrderDetailScreen` with timeline + reorder | 8 | StatusTimeline |
| Build `OrdersProvider` | 6 | Dio |
| Build `PointsHero` House Green band component | 4 | ContentCard |
| Build `PointsHistoryTile` component | 3 | ContentCard |
| Build `RewardsScreen` with hero + history list | 6 | Points components |
| Build `RewardsProvider` | 4 | Dio |
| Wire "Reorder" button → navigate to Cart | 3 | Cart provider |
| Widget test: Order History, Order Detail, Rewards | 8 | Screens done |

**NestJS Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Create migration: `010_reward_transactions` | 3 | Users, Orders |
| Create `RewardTransaction` entity | 3 | Migration done |
| Build `RewardsController` + `RewardsService` | 10 | RewardTransaction entity |
| Wire points-earned logic into Order completion service | 6 | Orders + Rewards |
| Push notification event: "Order Confirmed" (FCM) | 6 | Notifications module |
| Push notification event: "Order Ready" (FCM) | 4 | Notifications module |
| Push notification event: "Reward Earned" (FCM) | 4 | Notifications + Rewards |
| Write rewards service unit tests | 6 | Rewards service |
| Add order status transitions with validation | 4 | Orders service |

**Sprint 5 Deliverables:**
- ✅ Order History and Order Detail screens functional
- ✅ Reorder from history works
- ✅ Rewards screen shows points balance + history
- ✅ Points credited on order completion
- ✅ FCM notifications sent for order events
- ✅ Backend: Rewards + FCM modules deployed

### 6.7 Sprint 6 Detail: Profile + Home + Polish

**Flutter Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Build `ProfileHeaderCard` component | 4 | Avatar, shared |
| Build `AvatarPicker` component (camera/gallery) | 6 | Image picker plugin |
| Build `MenuRowCard` component | 2 | ContentCard |
| Build `ToggleSwitch` component | 3 | Theme |
| Build `ProfileScreen` with header + menu rows + logout | 6 | Profile components |
| Build `EditProfileScreen` with form | 6 | FloatingLabelInput |
| Build `SettingsScreen` with toggles | 4 | ToggleSwitch |
| Build `ChangePasswordScreen` | 4 | PasswordInput |
| Build `ProfileProvider` | 4 | Dio |
| Build `SettingsProvider` | 3 | Dio |
| Build `HeroBanner` component (swipable) | 6 | PageView |
| Build `QuickActionCard` component | 3 | ContentCard |
| Build `FeaturedItemsScroll` (horizontal) | 4 | ProductCard |
| Complete `HomeScreen` with all sections | 6 | Home components |
| Add loading skeleton to all list screens | 6 | LoadingSkeleton |
| Add pull-to-refresh to Menu, Orders, Rewards | 4 | Existing screens |
| Accessibility pass: semantics, screen reader, contrast | 8 | Theme + all screens |
| Widget test: Profile, Edit Profile, Settings | 6 | Screens done |

**NestJS Tasks:**
| Task | Hours | Dependencies |
|------|-------|-------------|
| Build `UploadsController` + `UploadsService` (avatar upload) | 8 | CDN setup |
| Build `NotificationsModule`: device token registration, FCM send | 10 | FCM credentials |
| Create migration: `011_device_tokens` | 2 | Users |
| Create `DeviceToken` entity | 2 | Migration done |
| Add reward points credit on "Order Completed" status change | 4 | Orders service |
| Performance: Add database indexes (verify all) | 4 | All entities |
| Performance: Add Redis cache eviction on product updates | 3 | Redis module |
| Security review: OWASP compliance check | 8 | All modules |
| Create `GET /orders/active` endpoint for Home screen | 3 | Orders |
| Create `GET /products/featured` in Redis cache | 3 | Products |

**Sprint 6 Deliverables:**
- ✅ Profile, Edit Profile, Settings, Change Password screens functional
- ✅ Avatar upload working
- ✅ Home screen with hero banner, quick actions, featured items
- ✅ FCM device registration working
- ✅ Loading states on all screens
- ✅ Accessibility audit complete

### 6.8 Sprint 7: Polish

| Area | Tasks | Hours |
|------|-------|-------|
| **Animations** | Checkmark animation on order confirmation, card entrance animations, button feedback on all CTAs | 8 |
| **Empty States** | Verify empty states on Cart, Order History, Rewards — correct illustration, headline, CTA | 4 |
| **Error Handling** | Network error banners, retry buttons, API error toasts on all screens | 6 |
| **Loading States** | Skeleton loaders on Categories, Product List, Orders List, Rewards history | 6 |
| **Performance** | Image lazy loading verification, list viewport caching (GridView, ListView.builder), animation jank check with Flutter DevTools | 8 |
| **Deep Links** | Verify `cfpv://order/:id` and `cfpv://rewards` deep links work from FCM notifications | 4 |
| **Device Testing** | Test on top 10 Vietnam Android devices (Samsung A-series, Xiaomi Redmi, Oppo), iPhone SE/12/13/14 | 12 |

### 6.9 Sprint 8: Hardening

| Area | Tasks | Hours |
|------|-------|-------|
| **Security Audit** | Verify JWT refresh rotation, rate limiting on auth, IDOR on all user-scoped endpoints, HTTPS enforcement | 8 |
| **Load Test** | Simulate 100 concurrent users browsing menu, 50 orders/minute peak load, measure P95 response times | 6 |
| **Bug Fixes** | Triage and fix bugs found during QA regression testing | 12 |
| **Monitoring** | Sentry/Datadog setup, structured logging review, API metrics dashboards | 6 |
| **App Store Prep** | Google Play Store listing assets, App Store Connect setup, privacy policy, test accounts | 8 |
| **Sign-off** | Stakeholder demo, acceptance criteria sign-off, release notes | 4 |

---

## 7. API Implementation Order

### 7.1 API Priority Matrix

| Priority | Endpoint | Sprint | Reason |
|----------|----------|--------|--------|
| P0 | `POST /api/v1/auth/register` | S1 | Auth flow foundation |
| P0 | `POST /api/v1/auth/register/verify` | S1 | Auth flow foundation |
| P0 | `POST /api/v1/auth/login` | S1 | Auth flow foundation |
| P0 | `POST /api/v1/auth/refresh` | S1 | Token lifecycle |
| P0 | `POST /api/v1/auth/logout` | S1 | User control |
| P0 | `POST /api/v1/auth/forgot-password` | S1 | Password recovery |
| P0 | `POST /api/v1/auth/forgot-password/verify` | S1 | Password recovery |
| P0 | `GET /api/v1/categories` | S2 | Menu browsing |
| P0 | `GET /api/v1/products?categoryId=` | S2 | Menu browsing |
| P0 | `GET /api/v1/products/:id` | S2 | Product detail |
| P0 | `GET /api/v1/products/featured` | S2 | Home screen |
| P1 | `GET /api/v1/products/:id/nutrition` | S2 | Nutrition info |
| P0 | `GET /api/v1/cart` | S3 | Cart management |
| P0 | `POST /api/v1/cart/items` | S3 | Cart management |
| P0 | `PUT /api/v1/cart/items/:itemId` | S3 | Cart management |
| P0 | `DELETE /api/v1/cart/items/:itemId` | S3 | Cart management |
| P0 | `PUT /api/v1/cart/store` | S3 | Cart management |
| P1 | `PUT /api/v1/cart/notes` | S3 | Cart management |
| P0 | `GET /api/v1/stores` | S3 | Store selection |
| P0 | `POST /api/v1/orders` | S4 | Place order |
| P0 | `POST /api/v1/orders/:id/confirm-payment` | S4 | Payment confirmation |
| P0 | `GET /api/v1/orders` | S5 | Order history |
| P0 | `GET /api/v1/orders/:id` | S5 | Order detail |
| P1 | `POST /api/v1/orders/:id/reorder` | S5 | Reorder |
| P0 | `GET /api/v1/rewards/balance` | S5 | Points balance |
| P1 | `GET /api/v1/rewards/transactions` | S5 | Points history |
| P0 | `GET /api/v1/users/me` | S1 | Profile |
| P1 | `PUT /api/v1/users/me` | S6 | Edit profile |
| P1 | `PUT /api/v1/users/me/password` | S1 | Change password |
| P1 | `PUT /api/v1/users/me/settings` | S6 | Notification settings |
| P1 | `POST /api/v1/notifications/device` | S6 | FCM token |
| P1 | `POST /api/v1/uploads/avatar` | S6 | Avatar upload |

---

## 8. Testing Strategy

### 8.1 Test Pyramid

```
        ╱╲
       ╱ E2E ╲              Patrol (Flutter) / Playwright (Web admin)
      ╱────────╲
     ╱Integration╲           TypeORM fixtures + supertest (NestJS)
    ╱─────────────╲
   ╱  Unit Tests   ╲         flutter_test + Dart (Flutter)
  ╱─────────────────╲        Jest (NestJS) - services, providers, controllers
 ╱ Static Analysis   ╲      dart analyze / ESLint / TypeScript strict mode
╱─────────────────────╲
```

### 8.2 Flutter Testing

| Level | Tool | Coverage Target | Location |
|-------|------|----------------|----------|
| Unit tests | `flutter_test` | All providers, all repositories services | `test/features/*/providers/` |
| Widget tests | `flutter_test` | All 19 screens (happy path + error + empty + loading states) | `test/features/*/screens/` |
| Golden tests | `golden_toolkit` | All shared components (button states, card variants, input states) | `test/shared/widgets/` |
| Integration | Patrol | 3 critical paths: Auth flow, Order flow, Rewards flow | `test/e2e/` |

**Key widget test scenarios (per screen):**
- Loading state: verify skeleton/shimmer renders
- Data state: verify all components render with mock data
- Error state: verify error message + retry button renders
- Empty state: verify empty illustration + CTA renders (cart, order history)
- Interaction: verify navigation, form submission, button press feedback

### 8.3 NestJS Testing

| Level | Tool | Coverage Target | Location |
|-------|------|----------------|----------|
| Unit tests | Jest | All services (mock repositories) | `src/modules/*/tests/*.service.spec.ts` |
| Integration | Jest + supertest | All controllers (use TypeORM test DB) | `src/modules/*/tests/*.controller.spec.ts` |
| E2E | Jest + supertest | Full API workflows (auth → menu → cart → order) | `test/e2e/` |

**Key integration test scenarios:**
- Auth: Register → OTP verify → Login → Refresh → Logout
- Menu: GET categories → GET products by category → GET product detail
- Cart: Add item → Update quantity → Remove item → Get cart
- Orders: Create order → Confirm payment → Get order → Reorder
- Rewards: Get balance → List transactions

### 8.4 E2E Testing with Patrol

```
test/e2e/
├── auth_flow_test.dart           # Register → Login → Forgot Password
├── menu_browsing_test.dart       # Browse categories → View products → View PDP
├── order_flow_test.dart          # Add to cart → Checkout → Payment → Confirmation
├── rewards_flow_test.dart        # View points → View history
└── profile_flow_test.dart        # Edit profile → Update settings → Change password
```

---

## 9. CI/CD Pipeline

### 9.1 GitHub Actions Workflow

```yaml
name: CFPV CI/CD

on:
  push:
    branches: [develop, main]
  pull_request:
    branches: [develop, main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Flutter lint
        run: |
          flutter analyze
          flutter format --set-exit-if-changed .
      - name: NestJS lint
        run: |
          cd backend
          npm run lint

  test-flutter:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
          flags: flutter

  test-nestjs:
    runs-on: ubuntu-latest
    needs: lint
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: cfpv_test
          POSTGRES_USER: cfpv
          POSTGRES_PASSWORD: cfpv_test
        ports: ['5432:5432']
      redis:
        image: redis:7
        ports: ['6379:6379']
    steps:
      - uses: actions/checkout@v4
      - run: |
          cd backend
          npm ci
          npm run test -- --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./backend/coverage/lcov.info
          flags: nestjs

  build:
    runs-on: ubuntu-latest
    needs: [test-flutter, test-nestjs]
    steps:
      - uses: actions/checkout@v4
      - run: flutter build apk --release
      - run: flutter build ios --release --no-codesign
      - run: |
          cd backend
          npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            backend/dist/

  deploy-staging:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/develop'
    steps:
      - run: echo "Deploy to staging server..."
      # Actual deployment script would go here

  deploy-production:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - run: echo "Deploy to production..."
      # Actual deployment script would go here
```

### 9.2 Deployment Environments

| Environment | Server | Database | API URL | Who |
|-------------|--------|----------|---------|-----|
| **Local** | Local machine | Local PostgreSQL | `localhost:3000` | Developers |
| **Staging** | VPS / Railway | Staging DB | `staging.api.cfpv.com` | QA + Demo |
| **Production** | Cloud Run / ECS | Production RDS | `api.cfpv.com` | Users |

---

## 10. Infrastructure Setup

### 10.1 Required Services

| Service | Provider | Purpose | Cost (MVP) |
|---------|----------|---------|------------|
| Cloud Hosting | Railway / Fly.io | Backend deployment | ~$15-25/month |
| PostgreSQL | Railway / Supabase | Primary database | ~$10-15/month |
| Redis | Railway / Upstash | Caching + rate limiting | ~$10/month |
| CDN + Storage | Cloudflare R2 | Product images + avatars (zero egress fees, S3-compatible) | ~$5-10/month |
| FCM | Firebase (free) | Push notifications | Free |
| SMS OTP | Twilio / VN-specific | Phone verification | ~$0.07/SMS |
| Sentry | Sentry cloud (saas) | Error tracking + Flutter crash reporting | Free tier (5K errors/mo) |
| Monitoring | Grafana + Prometheus | Metrics dashboard | Free (self-hosted) |

### 10.2 DevOps Setup Order

```
Week 1:
  1. Create GitHub repository, set up branch protection
  2. Set up staging server (Railway/Fly.io)
  3. Provision PostgreSQL + Redis
  4. Configure CDN bucket (Cloudflare R2)
  5. Set up Sentry for error tracking (free tier; `sentry_flutter` + `@sentry/node`)

Week 2:
  6. Deploy NestJS staging via CI/CD
  7. Configure custom domain (api.staging.cfpv.com)
  8. Set up Firebase project for FCM

Week 6:
  9. Set up production environment
  10. Configure production SSL + domain
  11. Set up monitoring dashboards

Week 8:
  12. Production deployment
  13. CDN warmup (cache product images)
  14. Load testing against production infra
```

---

## 11. Risk Mitigation During Implementation

### 11.1 Technical Risks

| Risk | Sprint | Impact | Mitigation |
|------|--------|--------|------------|
| OTP delivery (hardcoded in MVP) | S1 | Not applicable in MVP — OTP `131017` bypasses SMS | Post-MVP: integrate Twilio/VietGuys via `SmsProviderInterface`, implement resend timer and voice call fallback |
| VNPay/MoMo sandbox integration issues | S4 | Checkout flow blocked | Start sandbox registration in Sprint 1; maintain a `PaymentServiceInterface` with a `MockPaymentService` fallback that works without gateway credentials |
| FCM delivery on Chinese OEM Android devices (Xiaomi, Oppo) | S5 | Users don't receive order-ready notifications | Implement polling endpoint `GET /orders/:id/status` as fallback; foreground service on Android |
| Image loading on slow 4G networks | S2 | PDP images fail to load | Progressive JPEG, blur-up placeholders, CDN cache pre-warming, `cached_network_image` with disk cache |
| Concurrent cart operations race condition | S3 | Cart state inconsistency on rapid add/remove | Optimistic UI updates + server-side conflict resolution (last-write-wins at item level) |

### 11.2 Dependency Risks

| Dependency | Risk | Mitigation |
|------------|------|------------|
| Flutter Riverpod 2.x breaking changes | Pin version in `pubspec.yaml`, avoid auto-migration |
| TypeORM migration conflicts | Generate all migrations in Sprint 1; lock migration ordering in documentation |
| MoMo SDK updates | Wrap SDK calls in `MoMoService` adapter; mock in tests |

### 11.3 Team Scaling Notes

- **Sprint 1-2 (Foundation + Auth):** Both frontend engineers work on auth; both backend engineers work on auth + users
- **Sprint 2-3 (Menu + Cart):** Parallel: FE1 → Menu screens, FE2 → Cart; BE1 → Products, BE2 → Cart
- **Sprint 4-5 (Checkout + Orders + Rewards):** FE1 → Checkout flow, FE2 → Orders + Rewards; BE1 → Payments integration, BE2 → Orders + Rewards
- **Sprint 6-7 (Profile + Home + Polish):** FE1 → Profile + Settings, FE2 → Home + Accessibility; BE1 → Uploads + Notifications, BE2 → Performance + Security

---

## 12. Open Decisions Log

| ID | Decision | Options | Impact | Deadline |
|----|----------|---------|--------|----------|
| D-01 | SMS provider for OTP | ✅ **MVP: Hardcoded OTP `131017`** — no SMS cost, zero integration time. Post-MVP: Twilio → VietGuys migration path via `SmsProviderInterface` adapter. | Sprint 1 — OTP verification v1 | ✅ Decided |
| D-02 | Image hosting | ✅ **Cloudflare R2** — zero egress fees, S3-compatible API, excellent Vietnam CDN performance. Use `@aws-sdk/client-s3` with R2 endpoint. Generated signed URLs for secure image delivery. | Sprint 2 — CDN cost, Vietnam latency | ✅ Decided |
| D-03 | Points earn rate | ✅ **1★ per 10,000₫** | Sprint 5 — rewards economics | ✅ Decided |
| D-04 | Minimum order amount | 0₫ vs 20,000₫ vs 50,000₫ | Sprint 4 — checkout validation | Before S4 |
| D-05 | Tax rate | 8% vs 10% (standard VAT for F&B in Vietnam) | Sprint 4 — order total calculation | Before S4 |
| D-06 | CI/CD provider | ✅ **GitHub Actions** | Sprint 1 — pipeline cost + complexity | ✅ Decided |
| D-07 | Error monitoring | ✅ **Sentry** — generous free tier (5K errors/mo), superior Flutter crash reporting with breadcrumbs, `sentry_flutter` SDK. Datadog is overkill for MVP scale. | Sprint 6 — observability cost | ✅ Decided |

---

*End of Implementation Phase Document*
*Generated: June 7, 2026*
*Next: Development Sprint 1*

---

## Appendix A: Key File Dependency Map

```
main.dart
  └── app.dart
       ├── app_router.dart
       │   ├── auth_guard.dart
       │   └── route_paths.dart
       └── app_theme.dart
            ├── colors.dart
            ├── typography.dart
            ├── spacing.dart
            ├── elevation.dart
            └── radius.dart

Any feature screen → shared/widgets/  (buttons, cards, inputs, feedback)
                  → core/network/dio_client.dart
                  → core/router/app_router.dart (for navigation callbacks)

Any provider → features/*/repositories/*_repository.dart
             → core/network/dio_client.dart

Any repository → core/network/dio_client.dart
               → core/constants/api_constants.dart
```

## Appendix B: Story Point Estimation (Total: ~350 points)

| Feature | Points | Sprint |
|---------|--------|--------|
| Project setup + Theme | 13 | S1 |
| Auth screens (Login, Register, Forgot) | 21 | S1 |
| Auth backend (JWT, OTP, Users) | 21 | S1 |
| Onboarding + Splash | 8 | S1 |
| Menu screens (Categories, Products, PDP) | 34 | S2 |
| Menu backend (Categories, Products) | 26 | S2 |
| Cart screen | 18 | S3 |
| Cart backend | 18 | S3 |
| Stores (frontend + backend) | 8 | S3 |
| Checkout screen + Payment (MoMo + VNPay) | 34 | S4 |
| Checkout backend (Orders + Payments) | 34 | S4 |
| Order History + Detail + Reorder | 18 | S5 |
| Rewards screen + backend | 16 | S5 |
| FCM integration | 13 | S5 |
| Profile + Settings + Edit Profile | 18 | S6 |
| Home screen (Hero, Quick actions, Featured) | 18 | S6 |
| Uploads + Notification settings | 10 | S6 |
| Polish (Animations, Loading, Empty, Errors) | 13 | S7 |
| Hardening (Security, Load, App Store) | 13 | S8 |
```

> **Implementation team size assumption:** 2 Frontend (Flutter) + 2 Backend (NestJS) + 1 QA
> **Total timeline:** 11 weeks (8 sprints × 1-2 weeks + buffer)
