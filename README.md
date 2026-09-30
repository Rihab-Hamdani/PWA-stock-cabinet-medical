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
