# Medical Practice Stock Management

Installable Angular PWA and Spring Boot API for managing inventory and patient
workflow in a medical practice specialized in functional exploration
(EEG, EMG, PEA, PEV, ERG, PES and spirometry).

## Features

- JWT authentication with doctor and secretary roles
- Doctor approval flow for new secretary accounts
- Products, categories, suppliers and stock movements
- Low-stock alerts, expiry dates, lot numbers and movement history
- Dashboard with stock and financial indicators for doctors
- Patient records, appointments and payment tracking
- Password reset email delivery through Brevo

## Stack

| Layer | Technology |
|---|---|
| Frontend | Angular 18 standalone components, signals and PWA |
| Backend | Spring Boot 4.1, Java 21, Spring Security and JWT |
| Database | PostgreSQL with Flyway migrations |
| Email | Brevo SMTP |

## Project structure

```text
backend/     Spring Boot API, Flyway migrations and tests
frontend/    Angular PWA
```

## Prerequisites

- Java 21
- Node.js 18+
- PostgreSQL 16+
- Optional: a Brevo account for password-reset emails

## Local setup

Create a PostgreSQL database named `stock`, then apply
`backend/src/main/resources/db/migration/V1__init.sql`. The default JDBC URL is
`jdbc:postgresql://localhost:5433/stock`; set `DB_URL` if your database uses a
different host or port.

Start the backend:

```bash
cd backend
./mvnw spring-boot:run
```

The API starts at <http://localhost:8090/api/v1>.

Start the frontend in another terminal:

```bash
cd frontend
npm install
npm start
```

Open <http://localhost:4200>.

## Configuration

The backend reads these environment variables:

```text
DB_URL, DB_USER, DB_PASSWORD
JWT_SECRET, JWT_EXPIRATION_MS
MAIL_USER, MAIL_PASSWORD, MAIL_FROM
CORS_ORIGINS
ADMIN_EMAIL, ADMIN_PASSWORD
```

Never use the development JWT fallback or weak credentials in production.

## First account

The first account registered through `/register` becomes the doctor
administrator. Later accounts are secretaries pending approval from the doctor.

## Roadmap

- Push notifications
- Automatic alert follow-ups
- PDF/Excel history export
- Consumption statistics
- Multi-practice support

## License

Private project — all rights reserved.
