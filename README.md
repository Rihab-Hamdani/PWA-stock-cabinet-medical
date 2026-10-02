# Medical Practice Stock Management

A stock management application for a medical practice specialized in functional exploration (EEG, EMG, PEA, PEV, ERG, PES, EFR/Spirometry...). Built as an installable Progressive Web App for mobile and desktop, allowing the doctor and secretary/secretaries to track stock movements in real time, get alerted on low stock, and manage patient appointments.

## Features

### Authentication & roles
- Secure JWT-based login
- Two roles: **Doctor** (full access) and **Secretary**
- Self-service registration with doctor approval (the very first account created automatically becomes the doctor)
- Email-based password reset (via Brevo)
- Admin screen to review pending/active accounts

### Stock
- Product categories, created together with their first product
- Product record: name, unit, quantity, alert threshold, unit price (excl. tax), expiry date, lot number
- Search and filter by category
- Quick usage ("Use") and full stock intake (quantity, price, VAT, supplier — picked from a list or entered manually with phone number and invoice number)
- Complete, timestamped movement history per product
- Supplier management

### Dashboard
- View adapted to the logged-in role: out-of-stock / below-threshold products, today's movements
- Financial indicators for the doctor only: stock value, today's incoming amount, lost amount (valued outgoing stock)
- Stock alerts with direct access to the product record

### Patients
- Patient identification record (identity, contact details)
- Appointment info (requested exam, referring doctor, clinic, date)
- Payment tracking (insurance, amount paid, notes)

## Tech stack

| Layer | Technology |
|---|---|
| Frontend | Angular 18 (standalone components, signals), PWA |
| Backend | Spring Boot 4.1 (Java 21), modular monolith |
| Database | PostgreSQL |
| Authentication | Spring Security 6 + JWT (jjwt) |
| Email | Brevo (SMTP) |
| Tools | IntelliJ IDEA, DBeaver |

## Backend architecture

Modular monolith organized by business domain:
com.example.stock
├── auth — users, roles, JWT, security, registration
├── catalog — categories and products
├── supplier — suppliers
├── inventory — stock movements (in/out)
├── patient — patient records and appointments
└── shared — configuration, cross-cutting security, dashboard, error handling


## Prerequisites

- Java 21
- Node.js 18+
- PostgreSQL 16+
- A Brevo account (optional, for real password-reset email delivery)

## Setup

### Database

Create a PostgreSQL database named `stock`, then run the migration script found at `backend/src/main/resources/db/migration/V1__init.sql`.

### Backend

```bash
cd backend
./mvnw clean package -DskipTests
./mvnw spring-boot:run
```

Main environment variables (see `application.yaml`):

```yaml
DB_URL, DB_USER, DB_PASSWORD       # PostgreSQL connection
JWT_SECRET, JWT_EXPIRATION_MS      # token configuration
MAIL_USER, MAIL_PASSWORD, MAIL_FROM # Brevo SMTP
CORS_ORIGINS                        # allowed frontend origin
ADMIN_EMAIL, ADMIN_PASSWORD         # fallback admin credentials
```

The backend starts on `http://localhost:8090`, served under the `/api/v1` prefix.

### Frontend

```bash
cd frontend
npm install
ng serve
```

The app is available at `http://localhost:4200`.

## First run

The very first account registered via `/register` automatically becomes the **doctor** (administrator). Every subsequent account is created as a **secretary**, pending approval by the doctor from the admin screen.

## Roadmap

- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] Automatic alert follow-ups
- [ ] PDF / Excel export of history
- [ ] Consumption statistics
- [ ] Multi-practice support

## License

Private project — all rights reserved.
