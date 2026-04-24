# Backend Missing Endpoints (Gap Analysis vs Frontend Implementation)

Based on the newly implemented frontend functionality (Flutter UI and Web UI), the backend currently lacks or has mismatched implementations for the following endpoints:

| Feature | Frontend Endpoint Called | Current Backend Status | Required Action |
| --- | --- | --- | --- |
| **Referral Programme** | `GET/POST /loyalty/referral/` | Missing view & url | Create `ReferralCodeView` |
| **Loyalty Transactions** | `GET /loyalty/transactions/` | Implicit in `/loyalty/balance/` | Modify Flutter to extract from balance |
| **Gift Card Vouchers** | `GET /salons/vouchers/my/` | Handled by `/salons/vouchers/` | Modify Flutter to call `/salons/vouchers/` |
| **POS Terminal** | `POST /salons/pos-checkout/` | Missing view & url | Create `POSCheckoutAPIView` |
| **Salon Services (POS)** | `GET /salons/options/` | Nested under `/salons/<id>/options/` | Modify Flutter to fetch user's salon ID |
| **Owner Offers** | `GET /salons/offers/` | Nested under `/salons/<id>/offers/` | Modify Flutter to fetch user's salon ID |
| **Owner Packages** | `GET /salons/packages/` | Nested under `/salons/<id>/packages/` | Modify Flutter to fetch user's salon ID |
| **Analytics Summary** | `GET /analytics/summary/` | Exists as `/analytics/overview/` | Modify Flutter |
| **Analytics Staff KPIs** | `GET /analytics/staff-kpis/` | Missing | Create `StaffKPIsAPIView` |
| **Analytics Services** | `GET /analytics/top-services/` | Missing | Create `TopServicesAPIView` |
| **Public Booking (Web)** | `POST /salons/public-booking/` | Missing | Create `PublicBookingAPIView` |

### Action Plan
1. Fix all **Flutter endpoint paths** to align with existing backend structure where relevant (Options, Offers, Packages, Vouchers, Analytics Summary, Loyalty Transactions).
2. Create **Missing Backend Views**:
    - `loyalty/views.py`: `ReferralCodeView` (Manage referral codes)
    - `salons/views.py`: `POSCheckoutAPIView` (Process point-of-sale)
    - `salons/views.py`: `PublicBookingAPIView` (No-auth web booking)
    - `analytics/views.py`: `StaffKPIsAPIView` and `TopServicesAPIView` (Live data aggregations)

All models and core schemas (Points logic, Transactions, Invoices, Vouchers) are already in place and solid. Only the routing layers are missing to serve these new use-cases.
