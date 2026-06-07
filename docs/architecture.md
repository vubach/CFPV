# CFPV Architecture

## Overview

CFPV is a mobile-first Food & Beverage platform.

Platforms:

* Android
* iOS

Frontend:

* Flutter

Backend:

* NestJS

Database:

* PostgreSQL

Cache:

* Redis

Notifications:

* Firebase Cloud Messaging (FCM)

Payments:

* VNPay
* MoMo
* Stripe (future)

---

# High Level Architecture

Mobile App
↓
API Gateway
↓
NestJS Backend
↓
PostgreSQL

Additional Services:

Mobile App
↓
FCM

Backend
↓
Redis

Backend
↓
Payment Providers

---

# Frontend Architecture

Pattern:

Feature-Based Architecture

Structure:

lib/

├── core/
├── shared/
├── features/
├── routes/
├── services/
└── app/

Example:

features/

├── auth/
├── home/
├── menu/
├── cart/
├── checkout/
├── rewards/
└── profile/

Rules:

* Feature isolation
* No cross-feature imports
* Shared code belongs in shared/
* Business logic belongs in services/

State Management:

* Riverpod

Navigation:

* GoRouter

Networking:

* Dio

---

# Backend Architecture

Pattern:

Modular Monolith

Modules:

* Auth
* Users
* Products
* Categories
* Cart
* Orders
* Rewards
* Notifications

Example:

src/

├── auth/
├── users/
├── products/
├── categories/
├── cart/
├── orders/
├── rewards/
└── notifications/

Rules:

* Module owns its data
* No direct DB access across modules
* Shared functionality through services

---

# Database Architecture

Database:

PostgreSQL

Primary Entities:

User
Category
Product
ProductOption
Cart
CartItem
Order
OrderItem
RewardPoint

Relationships:

User
└── Orders

Order
└── OrderItems

Product
└── ProductOptions

Cart
└── CartItems

---

# Authentication

Method:

JWT

Flow:

Login
↓
Access Token
↓
Refresh Token

Storage:

Mobile Secure Storage

Rules:

* Access token expiration 15 minutes
* Refresh token expiration 30 days

---

# Rewards Architecture

Rule:

# 1 USD equivalent

1 Point

Points earned after successful order.

Points redeemed during checkout.

Future:

* Tier system
* Promotions
* Campaign engine

---

# API Principles

Style:

REST

Versioning:

/api/v1

Examples:

GET /api/v1/products

GET /api/v1/products/:id

POST /api/v1/cart/items

POST /api/v1/orders

Rules:

* JSON only
* Consistent error responses
* Pagination required

---

# Notification Architecture

Provider:

Firebase Cloud Messaging

Events:

Order Created

Order Confirmed

Order Completed

Reward Earned

Promotions

---

# Caching Strategy

Technology:

Redis

Cache:

Products
Categories
Featured Products

Do Not Cache:

User Profile
Cart
Orders

---

# Security

Requirements:

HTTPS Only

JWT Authentication

Input Validation

Rate Limiting

SQL Injection Protection

OWASP Compliance

Never:

* Store plaintext passwords
* Expose internal IDs
* Trust client-side validation

---

# Observability

Logging:

Structured JSON Logging

Monitoring:

Application Metrics

API Metrics

Error Tracking

Performance Metrics

Future:

OpenTelemetry

Grafana

Prometheus

---

# CI/CD

Source Control:

GitHub

Pipeline:

Lint
↓
Unit Tests
↓
Integration Tests
↓
Build
↓
Deploy

Rules:

No deployment if tests fail.

Coverage target:

80% minimum

---

# Design System

DESIGN.md is the single source of truth.

All screens must follow:

* Typography rules
* Color tokens
* Component rules
* Layout rules

No custom visual systems allowed.
