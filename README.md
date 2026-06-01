# NUSphere 🌏

> A unified mobile platform for international students at NUS — manage deadlines, find housing, connect with peers, and split group orders, all in one place.

**Team:** 404 Sleep Not Found | Orbital 26 — Apollo 11  
**Members:** Amin (Frontend) · Kar Mun (Backend) 
**Github repository link:** https://github.com/amin0328/404SleepNotFound 
**Stack:** Flutter · Node.js/TypeScript · PostgreSQL · Railway · Render 

---

## Motivation

Our team consists of two international students — from Malaysia and South Korea. When we first arrived at NUS, we experienced firsthand how chaotic the first few weeks abroad can be.

Students miss visa renewal deadlines because reminders are scattered across different apps. Students fall victim to housing scams because they lack local knowledge and trusted networks. Students struggle with social isolation because there is no structured way to find peers who share their background and habits.

We built NUSphere to solve this — a single trusted platform that consolidates the core logistical and social challenges of student life abroad.

---

## User Stories

1. **Profile Setup** — As a newly arrived international student, I want to create a profile capturing my home country, arrival date, cultural preferences, and lifestyle habits, so the platform can surface relevant matches and alerts from day one.

2. **Deadline Tracker** — As a student managing multiple administrative deadlines, I want to record visa expiry, insurance renewal, and lease end dates in one dashboard, so I can receive reminders and avoid missing critical deadlines.

3. **Housing Search** — As a student looking for housing, I want to search verified listings filtered by price, location, lease length, and room type, so I can find accommodation that suits my budget and lifestyle.

4. **Buddy Matching** — As a student looking for a compatible roommate, I want to complete a lifestyle questionnaire and be matched based on sleep schedule, cleanliness, diet, and social preferences, so I can find a housemate before searching for a place together.

5. **Group Orders** — As a student who wants to buy products from my home country, I want to join or create a group order with other students so we can split international shipping costs.

6. **Live Currency** — As an international student managing expenses, I want all prices shown in my home currency so I can make informed financial decisions without manual conversion.

---

## Core Features

### 1. User Authentication & Profile System
Secure registration and login using NUS credentials (NUSNET ID). Profile captures:
- Academic info: NUS ID, major, faculty, graduation year, dorm
- Personal info: Home country, home currency, arrival date
- Lifestyle: Sleep schedule, cleanliness (1–5), cooking, noise tolerance, dietary requirements, social preference

### 2. Centralised Deadline Tracker
Calendar dashboard for all administrative deadlines with colour-coded urgency indicators:
- 🟢 **Green** — 30+ days remaining
- 🟡 **Amber** — 8–30 days remaining
- 🔴 **Red** — 0–7 days remaining

Categories: Visa renewal, course registration, housing/lease, insurance, school fees. Customisable push notification reminders.

### 3. Housing Listings & Search
Aggregated rental listings with filters:
- Price range (SGD)
- Location (central / north / south / east / west)
- Housing type (HDB, condo, landed)
- Room arrangement (room share, private room, studio)
- Lease duration (short / long term)

All prices shown with live home currency equivalent.

### 4. Community Board
**Buddy Matching** — Compatibility-based matching for roommates, study partners, and hobby groups. Weighted compatibility algorithm:

| Factor | Weight |
|--------|--------|
| Sleep schedule | 25 pts |
| Noise tolerance | 20 pts |
| Dietary requirements | 20 pts |
| Social preference | 15 pts |
| Cleanliness | 15 pts |
| Cooking habits | 5 pts |

**Group Order Board** — Pool international purchases to split shipping costs. Order lifecycle: `Open → Confirmed → Shipped → Arrived`

### 5. Live Currency Conversion
Daily exchange rate refresh via ExchangeRate-API. Shown inline on all SGD prices throughout the app.

### 6. In-App Chat & Notifications
Auto-created group chats on buddy match or group order join. Push notifications for deadlines, order updates, match requests, and collection alerts.

---

## System Design

### Prototype
<img width="1355" height="413" alt="Screenshot 2026-06-01 at 2 27 48 PM" src="https://github.com/user-attachments/assets/ea48e429-88a5-4169-9016-7b9332612364" />


### Architecture

```
┌─────────────────┐         ┌──────────────────────┐         ┌─────────────┐
│  Flutter App    │ ──────▶ │  Node.js + Express   │ ──────▶ │ PostgreSQL  │
│  (Dart)         │  REST   │  TypeScript          │         │ (Railway)   │
│  Android / iOS  │         │  JWT Auth            │         │             │
└─────────────────┘         └──────────────────────┘         └─────────────┘
```

### Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (Dart) |
| Backend | Node.js + Express + TypeScript |
| Database | PostgreSQL (Railway) |
| Auth | JWT + bcryptjs |
| Notifications | Firebase Cloud Messaging |
| State Management | Riverpod |
| Deployment | Render (backend) |

### Database Schema

**users** — `id, nusnet_id, name, email, password_hash, home_country, major, home_currency, dorm, arrival_date, grad_year, lifestyle (JSONB), created_at`

**deadlines** — `id, user_id (FK), title, category, due_date, reminder_days (INT[]), notifications_on, notes, created_at`

**listings** — `id, title, price_sgd, location, type, room, lease_months, created_at`

**posts** — `id, author_id (FK), category, title, body, group_size, tags (TEXT[]), move_in_date, created_at`

**post_interests** — `post_id (FK), user_id (FK), created_at`

### API Contract

Base URL: `https://nusphere-backend.onrender.com/v1`

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/register` | No | Register new account |
| POST | `/auth/login` | No | Login, returns JWT |
| GET | `/users/me` | Yes | Get current user profile |
| PUT | `/users/me` | Yes | Update profile & lifestyle |
| GET | `/deadlines` | Yes | Get deadlines with urgency |
| POST | `/deadlines` | Yes | Create deadline |
| PATCH | `/deadlines/:id` | Yes | Update deadline |
| DELETE | `/deadlines/:id` | Yes | Delete deadline |
| GET | `/listings` | Yes | Search listings with filters |
| GET | `/listings/:id` | Yes | Get listing detail |
| GET | `/posts` | Yes | Get community posts |
| POST | `/posts` | Yes | Create post |
| POST | `/posts/:id/interest` | Yes | Express interest + get matches |

---

## Development Plan

| Milestone | Due Date | Deliverables |
|-----------|----------|-------------|
| M1 — Ideation | 1 Jun 2025 | Project idea, design, API contract, PoC (login + profile) |
| M2 — Prototype | 29 Jun 2025 | Deadline Tracker, Housing, Community Board, Buddy Matching |
| M3 — Extensions | 27 Jul 2025 | Group Orders, Chat, Notifications, user testing |
| Splashdown | 26 Aug 2025 | Polish, bug fixes, deployment, final docs |

### Work Distribution

| Amin (Frontend) | Kar Mun (Backend) |
|-----------------|-------------------|
| Login & registration screens | JWT auth API |
| Profile setup UI (4-step onboarding) | Profile data model & API |
| Deadline calendar UI | Deadline CRUD + urgency scoring |
| Housing search UI | Housing aggregator & filter API |
| Community board UI | Community post CRUD API |
| Buddy matching quiz UI | Compatibility scoring algorithm |
| Currency display widget | Currency conversion API |

---

## Git Workflow

**Branch naming:** `feat/name` · `fix/name` · `chore/name`  
**Commit format:** `type(scope): description`  
e.g. `feat(auth): add login screen` · `fix(deadline): fix urgency colour logic`

**Workflow:** feature branch → PR → teammate review → merge to main

---

## Folder Structure

```
404SleepNotFound/
├── mobile/                  # Flutter app
│   └── lib/
│       ├── core/            # API client, auth, models, constants, theme
│       ├── features/        # auth, profile, deadlines, housing, community, chat
│       └── shared/          # reusable widgets, extensions
├── backend/                 # Node.js + Express + TypeScript
│   └── src/
│       ├── config/          # DB, env
│       ├── middleware/       # JWT auth, error handler
│       ├── routes/          # API endpoints
│       ├── controllers/     # Route handlers
│       └── services/        # Business logic (matching, urgency, cost split)
└── .github/
    └── workflows/           # CI: lint, test on PR
```
