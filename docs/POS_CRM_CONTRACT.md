# POS ↔ CRM API Contract

**System:** MyGenie POS Frontend ↔ CRM service (`crm.mygenie.online`)
**Created:** 2026-10-06 — derived from codebase (crmAxios.js, customerService.js, loyaltyService.js, couponService.js, crmReportService.js, customerIntelService.js, customerTransform.js, orderTransform.js, constants.js)
**Status:** Live (partial kill-switch on loyalty redeem + wallet debit)

---

## 1. Transport

| Item | Value |
|------|-------|
| Base URL | `REACT_APP_CRM_BASE_URL` env var (`https://crm.mygenie.online/api`) |
| Auth header | `X-API-Key: <crm_token>` |
| Token source | POS login response → `crm_token` field |
| Token lifecycle | Set on login via `setCrmToken()` · persisted to `localStorage['crm_token']` · cleared on logout |
| Token refresh | On 401: `GET /api/v2/vendoremployee/restaurant-crm-token` (POS backend) → retry once |
| Timeout default | 15 000 ms (intel endpoint: 3 000 ms hard) |
| Content-Type | `application/json` |
| Response envelope | `{ success: bool, data: <payload>, message?: string }` |

---

## 2. Endpoints

### 2.1 Customer — Search & Lookup

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/pos/customers?search=<q>&limit=<n>` | Typeahead — name or phone, min 2 chars |
| POST | `/pos/customer-lookup` | Exact phone lookup → full profile + addresses |
| GET | `/pos/customers/{id}` | Full customer detail (loyalty blob, orders, addresses) |

**POST /pos/customer-lookup request:**
```json
{ "phone": "9876543210" }
```
**Response (registered=true):**
```json
{
  "customer_id": "<uuid>",
  "registered": true,
  "name": "...",
  "phone": "...",
  "tier": "Gold",
  "total_points": 420,
  "points_value": 42.0,
  "wallet_balance": 150.0,
  "total_visits": 12,
  "total_spent": 8400.0,
  "allergies": [],
  "favorites": [],
  "last_visit": "2026-09-20",
  "addresses": [ <address objects> ],
  "documents": {},
  "customer_type": "normal",
  "is_b2b": false,
  "gst_name": null,
  "gst_number": null
}
```

---

### 2.2 Customer — CRUD

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/pos/customers` | Create customer |
| PUT | `/pos/customers/{id}` | Update customer |

**POST /pos/customers request:**
```json
{
  "pos_id": "mygenie",
  "restaurant_id": "<rid>",
  "name": "...",
  "phone": "...",
  "email": "...",          // optional
  "dob": "YYYY-MM-DD",    // optional
  "anniversary": "...",   // optional
  "gender": "...",         // optional
  "customer_type": "normal|corporate",
  "is_b2b": false,
  "gst_name": null,
  "gst_number": null
}
```
**Response:** `{ customer_id, name, phone }`

---

### 2.3 Addresses

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/pos/address-lookup` | Cross-restaurant addresses by phone |
| POST | `/pos/customers/{id}/addresses` | Add address |
| PUT | `/pos/customers/{id}/addresses/{addr_id}` | Update address |
| DELETE | `/pos/customers/{id}/addresses/{addr_id}` | Delete address |
| PUT | `/pos/customers/{id}/addresses/{addr_id}/default` | Set default |

**Address object (response):**
```json
{
  "pos_address_id": "<id>",
  "is_default": false,
  "address_type": "Home|Work|Other",
  "address": "full text",
  "house": "...", "floor": "...", "road": "...",
  "city": "...", "state": "...", "pincode": "...", "country": "India",
  "latitude": "", "longitude": "",
  "contact_person_name": "", "contact_person_number": "",
  "delivery_instructions": ""
}
```

---

### 2.4 Documents (PMS Check-In)

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/pos/customers/{id}/documents` | List uploaded ID docs |
| POST | `/pos/customers/{id}/documents` | Upload ID doc (multipart/form-data) |

**Upload fields:** `doc_type` (Aadhaar/Passport/PAN/DL/VoterID), `file` (binary)

---

### 2.5 Loyalty

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/pos/max-redeemable` | Max redeemable points for a bill (non-mutating) |
| POST | `/pos/loyalty/redeem` | Redeem points (mutating — kill-switched, POS Backend only) |

**POST /pos/max-redeemable request:**
```json
{
  "pos_id": "mygenie",
  "restaurant_id": "<rid>",
  "bill_amount": 850.0,
  "customer_id": "<uuid>"     // OR "cust_mobile": "9876543210"
}
```
**Response:**
```json
{
  "success": true,
  "max_points_redeemable": 120,
  "max_discount_value": 12.0,
  "ratio_per_point": 0.10,
  "tier": "Gold",
  "available_points": 420,
  "min_redemption_points": 50,
  "loyalty_enabled": true
}
```

**POST /pos/loyalty/redeem request:**
```json
{
  "crm_customer_id": "<uuid>",
  "points_to_redeem": 120,
  "order_id": "<pos_order_id>",
  "order_total": 850.0,
  "idempotency_key": "<deterministic-key>"
}
```
> ⚠️ `BUG108_FLAGS.loyaltyRedeemLive = false` — POS Frontend does NOT call redeem. POS Backend calls CRM directly. POS Frontend calls `max-redeemable` only.

---

### 2.6 Coupons

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/pos/coupons/available?customer_id=&order_total=&channel=` | List eligible coupons (read-only) |
| POST | `/pos/coupons/validate` | Validate + compute coupon discount (read-only) |

**POST /pos/coupons/validate request:**
```json
{
  "code": "SAVE20",
  "customer_id": "<uuid>",
  "order_total": 850.0,
  "channel": "pos",
  "loyalty_points_used": 0,
  "items": [ { "id": "...", "qty": 2, "unit_price": 200 } ]
}
```

---

### 2.7 Customer Intelligence

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/pos/customers/order-suggestions` | Cross-sell suggestions (CRM 2.0) |

**Request:**
```json
{
  "crm_customer_id": "<uuid>",
  "current_cart": [ { "item_id": "123", "qty": 1, "unit_price": 200.0 } ],
  "order_type": "dine_in"
}
```
Timeout: 3 000 ms hard. Failure is silent (no toast, suggestion panel stays empty).

---

### 2.8 CRM Reports

| Method | Path | Params | Cache |
|--------|------|--------|-------|
| GET | `/pos/reports/summary` | — | 5 min |
| GET | `/pos/reports/top-customers` | `sort_by=total_spent\|total_visits\|total_points`, `limit=1-100` | 5 min |
| GET | `/pos/reports/churn-risk` | `band=high\|medium`, `limit=1-200` | **NO cache** |

---

## 3. CRM Data Written to POS Order Payload

Every order commit (`place-order`, `update-place-order`, `collectBillExisting`) sends CRM fields to the **POS Backend**:

| Field | Source | Notes |
|-------|--------|-------|
| `cust_membership_id` | `customer.id` (CRM UUID) | Links order to CRM customer |
| `crm_customer_id` | `tabContact.crmId` | TAB orders only |
| `coupon_code` | CollectPaymentPanel input | CRM-validated |
| `coupon_discount` | fromCRM `/validate` response | ₹ amount |
| `loyalty_points` | CollectPaymentPanel input | Points redeemed (POS Backend calls CRM) |
| `loyalty_discount` | Computed `points × ratio` | ₹ amount |
| `use_wallet_balance` | CollectPaymentPanel input | ₹ debited (kill-switched: `BUG108_FLAGS.walletDebitLive`) |
| `loyalty_idempotency_key` | `buildRedeemIdempotencyKey()` | Prevents double-redeem |

---

## 4. Loyalty Blob Shape (Frontend)

Both `searchResult` and `customerLookup` normalise to this shape for CollectPaymentPanel:

```javascript
customer.loyalty = {
  tier:            "Gold",
  tier_label:      "Gold Member",
  total_points:    420,
  ratio_per_point: 0.10,     // ₹ per point
  points_value:    42.0,     // total ₹ value of available points
  loyalty_enabled: true,
}
```

---

## 5. Kill Switches (`BUG108_FLAGS`)

| Flag | Current | Effect |
|------|---------|--------|
| `loyaltyRedeemLive` | `false` | `redeemLoyalty()` throws without any network call |
| `walletDebitLive` | `false` | `use_wallet_balance: 0` forced in all order payloads |
| `couponLive` | (gated at CollectPaymentPanel) | Coupon UI visible only when flag enabled |

---

## 6. Known Quirks

| Quirk | Impact |
|-------|--------|
| `address_id` vs `pos_address_id` — CRM returns both, use `pos_address_id` as canonical | BUG-278: wrong id caused delivery address not attaching |
| `crossRestaurantAddress` must include `house`, `floor`, `road` | BUG-395: missing fields → null delivery lines in payload |
| CRM token in `localStorage` (not `sessionStorage`) — survives page refresh | Design decision per BUG-300 |
| CRM `customer-lookup` and `search` return flat loyalty fields, not the strict loyalty blob | FE builds synthetic blob in `buildSyntheticLoyalty()` |
| CRM intelligence timeout is 3 s hard — failure is silent | UX: no toast on timeout, panel just stays empty |
| `restaurant_id` is a **string** in all CRM payloads (`String(restaurantId)`) | Sending number causes schema violation |
| `pos_id` must be `"mygenie"` in create/update customer payloads | Hardcoded identifier |


## Loyalty

Source files:

- `frontend/src/api/services/loyaltyService.js`
- `frontend/src/api/transforms/loyaltyTransform.js`
- `frontend/src/components/order-entry/CollectPaymentPanel.jsx`
- `frontend/src/api/transforms/orderTransform.js` (`placeOrderWithPayment`, `collectBillExisting`)

### Business rules

The screen does not compute tier, ratio, or cap. CRM does that on `POST /pos/max-redeemable`.

- A point’s rupee value is the per-tier override, else the restaurant `redemption_value`, else `0.25`.
- Tiers are Bronze, Silver, Gold, and Platinum.
- `points_value = round(total_points × ratio_per_point, 2)`.
- Redemption is capped by available points, the minimum redemption, and the bill. The response fields are `max_points_redeemable` and `max_discount_value`.
- If available points are below `min_redemption_points`, CRM returns `BELOW_MIN_REDEMPTION` and the checkbox stays disabled. The screen shows how many more points are needed.
- `LOYALTY_DISABLED`, `SETTINGS_MISSING`, `CUSTOMER_NOT_FOUND`, and `INVALID_REQUEST` hide the loyalty section.
- Earn is a preview only: `projected_points_earned` and `earn_ratio_display`. The screen shows “You’ll earn N pts”. Earning itself happens later on the backend, on the net bill.
- The cashier must tick Loyalty. It is not auto-applied. If the CRM call errors or the discount is 0, the tick is cleared.

Customer points shown before the CRM calculation come from the customer APIs (`POST /pos/customer-lookup`, `GET /pos/customers?search=`, `GET /pos/customers/{id}`). The redeemable amount always comes from max-redeemable, not from that blob. Lookup and search build a synthetic `customer.loyalty` object in `customerTransform.js` because those responses are flat.

### Working flow

1. The cashier opens Collect Payment with a customer.
2. After 400 ms, if loyalty is enabled and `billAmount > 0`, the screen calls `getMaxRedeemable`.
3. It refires when customer, phone, item total, manual discount, preset discount, or restaurant changes.
4. The UI shows tier, available points, and `₹{maxDiscountValue}`.
5. The cashier ticks the checkbox. `loyaltyDiscount` becomes `maxDiscountValue`.
6. On Pay, the order payload carries points and rupees. `loyalty_redemption_id` is always `null`. The POS backend is expected to call CRM redeem.

Unpaid place-order and update-order always send loyalty and coupon as zero. Loyalty and coupons apply only when the bill is paid: prepaid place-and-pay, and collect-bill on an existing order.

### Preview — what this frontend calls

`POST ${REACT_APP_CRM_BASE_URL}/pos/max-redeemable`

```bash
curl -X POST "$CRM_BASE_URL/pos/max-redeemable" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "X-API-Key: $CRM_TOKEN" \
  -d '{
    "pos_id": "mygenie",
    "restaurant_id": "689",
    "customer_id": "cust_abc",
    "bill_amount": 850
  }'
```

`customer_id` is preferred. If it is missing, the service sends `cust_mobile` instead. Missing `pos_id`, `restaurant_id`, or `bill_amount` returns HTTP 422.

Success:

```json
{
  "success": true,
  "data": {
    "max_points_redeemable": 200,
    "max_discount_value": 50.0,
    "ratio_per_point": 0.25,
    "tier": "Bronze",
    "available_points": 480,
    "min_redemption_points": 100,
    "loyalty_enabled": true,
    "projected_points_earned": 17,
    "projected_earn_percent": 2,
    "earn_ratio_display": "2%"
  }
}
```

This call does not change the point balance. The frontend maps the response in `maxRedeemableFromAPI`. On 401, 422, 5xx, or a network error it returns zeros plus `error.code = NETWORK_ERROR` so the panel does not crash.

| `data.error.code` | HTTP | `success` | Screen |
|---|---|---|---|
| (none) | 200 | `true` | Show discount. Checkbox enabled. Cashier must tick it. |
| `BELOW_MIN_REDEMPTION` | 200 | `true` | “Minimum {min} points required”. Checkbox disabled. |
| `LOYALTY_DISABLED` | 200 | `true` | Section hidden. |
| `SETTINGS_MISSING` | 200 | `true` | Section hidden. |
| `CUSTOMER_NOT_FOUND` | 200 | `false` | Section hidden. |
| `INVALID_REQUEST` | 200 | `false` | Section hidden. |
| network / 401 / 422 / 5xx | — | — | “Unable to calculate loyalty discount”. |

### Redeem — POS backend, not this frontend

`POST ${REACT_APP_CRM_BASE_URL}/pos/loyalty/redeem`

```bash
curl -X POST "$CRM_BASE_URL/pos/loyalty/redeem" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $CRM_TOKEN" \
  -d '{
    "customer_id": "cust_abc",
    "points_to_redeem": 200,
    "order_id": "939848",
    "order_total": 850,
    "idempotency_key": "pos_689_939848_loyalty_200"
  }'
```

Idempotency key format from `buildRedeemIdempotencyKey`: `pos_{restaurantId}_{orderId}_loyalty_{points}`. Retry a network or 5xx failure with the same key and the same body.

Success (`success: true`) returns `transaction_id`, `points_redeemed`, `ratio_per_point`, `redeemed_value`, `remaining_points`, `remaining_points_value`, `tier`, `total_points_redeemed`, `customer_id`, and `idempotent` on a replay.

Business failures are HTTP 200 with `success: false` and `data.error.code`:

| Code | Meaning |
|---|---|
| `ORDER_ID_REQUIRED` | Order reference missing. |
| `IDEMPOTENCY_KEY_REQUIRED` | Key missing. |
| `INVALID_POINTS` | Points are not a positive integer. |
| `IDEMPOTENCY_CONFLICT` | Same key, different body. `error.existing` may be present. |
| `SETTINGS_MISSING` | Restaurant has no loyalty settings. |
| `LOYALTY_DISABLED` | Program is off. |
| `CUSTOMER_NOT_FOUND` | Customer id is unknown. |
| `BELOW_MIN_REDEMPTION` | Below `min_redemption_points`. |
| `INSUFFICIENT_POINTS` | Balance cannot cover the request. |

HTTP 401 is auth failure (do not retry). HTTP 422 is a schema violation (do not retry). HTTP 5xx and network errors are retryable with the same key.

### Fields this frontend sends on pay

On `POST /api/v2/vendoremployee/order/place-order` (pay now) and `POST /api/v2/vendoremployee/order/order-bill-payment` (collect an existing bill):

| Payload field | Meaning |
|---|---|
| `used_loyalty_point` | Points to redeem (`max_points_redeemable`). `0` if Loyalty is unticked or `loyaltyRatioLive` is off. |
| `loyalty_points_used` | Same number, duplicated. |
| `loyalty_discount` | Rupee discount (`max_discount_value`). |
| `loyalty_redemption_id` | Always `null`. The backend fills this after CRM redeem. |

Print bill uses `loyalty_dicount_amount` (that spelling is in the print payload).

---

## Coupon

Source files:

- `frontend/src/api/services/couponService.js`
- `frontend/src/api/transforms/couponTransform.js`
- `frontend/src/components/order-entry/CollectPaymentPanel.jsx`
- `frontend/src/api/transforms/orderTransform.js`

### Business rules

CRM is the source of the rupee amount. The screen does not recompute percent versus flat. `selectedCoupon.computedDiscount` is `computed_discount` from validate.

| `offer_type` | Scope | Cart lines required |
|---|---|---|
| `simple` | order | No. `requires_cart_validation` is `false`. |
| `simple` | item or category | Yes. |
| `bogo` / `bxg` | buy X get Y | Yes. The free or discounted item must already be in the cart. The POS does not add it. |
| `nth_item` | every Nth item | Yes. Applications are `floor(eligible qty / N)`. Line order does not matter. |

Other rules:

- One coupon per order.
- `GET /available` and `POST /validate` do not record usage. Usage is recorded only when the final order is committed with `coupon_code` and `coupon_discount > 0`. CRM rechecks the coupon at that moment.
- Channel from this POS is never `"pos"`. Mapping in `couponTransform.js`: dine-in, walk-in, and room service → `dine_in`; takeaway → `takeaway`; delivery → `delivery`; anything else → `dine_in`.
- Happy hour uses the CRM server clock. `order_time` is informational. Outside the window, the coupon stays visible but is not auto-applied.
- `stackable_with_loyalty: false` hides the coupon while Loyalty is ticked. If Loyalty is turned on after a non-stackable coupon is applied, the coupon is removed and a toast says it is incompatible with loyalty.
- Item, category, BOGO, and Nth coupons are filtered on the client with `eligible_match_hint` (food ids or category names) before validate.
- If CRM `benefit_items` hit a line with `give_discount = No`, the coupon is rejected.
- For item and category coupons, line discounts follow `benefit_items`. Other discounts are spread across discountable lines (`distributeItemDiscounts` in `orderTransform.js`).

### Working flow

1. The panel opens with a customer and coupons enabled. `GET /pos/coupons/available` runs immediately, and again on input focus. The list is cached per customer, with a cap of 3 calls per panel session.
2. The list is sorted: in-window first, then highest `expected_discount`.
3. The best order-scope coupon that is in-window and does not need cart validation is auto-validated.
4. Typing a prefix waits 500 ms, then validates the best matching in-window order coupon. Item, category, BOGO, and Nth coupons are not auto-applied. The cashier picks them or presses Apply.
5. Apply or a dropdown click calls `POST /pos/coupons/validate`. If `requires_cart_validation` is true, the body includes `items[]`.
6. On `valid: true`, `computed_discount` is the bill discount. Benefit lines are shown (for example `1× Coffee FREE`).
7. On Pay, `coupon_code`, `coupon_discount`, `coupon_title`, and `coupon_type` go on the POS order payload.

Do not call `POST /pos/coupons/apply`. It is deprecated. It commits usage immediately and does not support cart-aware coupons.

### List

`GET ${REACT_APP_CRM_BASE_URL}/pos/coupons/available`

```bash
curl -G "$CRM_BASE_URL/pos/coupons/available" \
  -H "X-API-Key: $CRM_TOKEN" \
  -H "Accept: application/json" \
  --data-urlencode "customer_id=cust_abc" \
  --data-urlencode "order_total=850" \
  --data-urlencode "channel=dine_in"
```

| Query param | Required | Notes |
|---|---|---|
| `customer_id` | Yes | CRM customer id. Guest checkout is not supported. |
| `order_total` | Yes | `itemTotal − manual − preset`. |
| `channel` | No | `dine_in`, `takeaway`, or `delivery`. This POS never sends `pos`. |

Useful fields on each coupon: `code`, `title`, `offer_type`, `discount_scope`, `expected_discount`, `final_amount_preview`, `stackable_with_loyalty`, `requires_cart_validation`, `eligible_match_hint`, `time_window.within_window_now`, `time_window.next_window_start`.

`eligible_match_hint` shapes:

- Item: `{ "type": "food_ids", "values": ["182039"] }`
- Category: `{ "type": "category_names", "values": ["beverages"] }`
- BOGO / BXG: `{ "kind": "bogo", "buy": { "type": "food_ids", "values": [] }, "get": { ... } }`
- Every Nth: `{ "kind": "nth_item", "eligibility": { "type": "food_ids", "values": [] }, "nth_item_number": 5 }`

### Validate

`POST ${REACT_APP_CRM_BASE_URL}/pos/coupons/validate`

Order coupon (no cart):

```bash
curl -X POST "$CRM_BASE_URL/pos/coupons/validate" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $CRM_TOKEN" \
  -d '{
    "code": "SUMMER20",
    "customer_id": "cust_abc",
    "order_total": 850,
    "channel": "dine_in",
    "loyalty_points_used": 0,
    "items": null,
    "order_time": "2026-10-09T12:00:00.000Z"
  }'
```

Item, category, BOGO, or Nth (items required):

```bash
curl -X POST "$CRM_BASE_URL/pos/coupons/validate" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $CRM_TOKEN" \
  -d '{
    "code": "NTH5FREE",
    "customer_id": "cust_abc",
    "order_total": 500,
    "channel": "dine_in",
    "loyalty_points_used": 200,
    "items": [
      {
        "food_id": "182039",
        "item_id": "182039",
        "name": "Coffee",
        "quantity": 5,
        "unit_price": 100,
        "line_total": 500,
        "category_name": "beverages"
      }
    ],
    "order_time": "2026-10-09T12:00:00.000Z"
  }'
```

| Body field | Required | Notes |
|---|---|---|
| `code` | Yes | Trimmed and uppercased by the transform. |
| `customer_id` | Yes | CRM customer id. |
| `order_total` | Yes | Same base as the list call. |
| `channel` | No | See the channel map above. |
| `loyalty_points_used` | No | `max_points_redeemable` when Loyalty is ticked, otherwise `0`. |
| `items` | When `requires_cart_validation` is true | Built by `toAPI.posCartItem`. |
| `order_time` | No | Informational. The server clock decides the time window. |

Each cart line:

| Field | Source |
|---|---|
| `food_id` | `item.foodId` or `item.id` |
| `item_id` | `item.id` or `item.foodId` |
| `name` | item name |
| `quantity` | `item.qty` or `1` |
| `unit_price` | `item.unitPrice` or `item.price` |
| `line_total` | unit price × quantity |
| `category_name` | category name from `categoryId` |

Success is HTTP 200 with `data.valid: true`. Use `computed_discount` as the bill discount. `benefit_items`, `applied_applications`, and the match summaries describe which lines were discounted.

Failure is also HTTP 200, with `data.valid: false` and `data.error.code`. Show `pos_instruction` when it is present. Network failures are mapped to code `NETWORK`.

| Code | Cashier text |
|---|---|
| `INVALID_CODE` | Invalid coupon code |
| `EXPIRED` | Coupon has expired |
| `INACTIVE` | Coupon is no longer active |
| `MIN_ORDER_NOT_MET` | Minimum order value not met |
| `USAGE_LIMIT_REACHED` | Coupon fully redeemed |
| `CUSTOMER_USAGE_LIMIT_REACHED` | Customer has used this coupon the maximum number of times |
| `CUSTOMER_NOT_ELIGIBLE` | Coupon not available for this customer |
| `CHANNEL_NOT_VALID` | Coupon not valid for this order type |
| `STACKING_NOT_ALLOWED` | Cannot combine coupon with loyalty points |
| `OUTSIDE_TIME_WINDOW` | Coupon not active right now |
| `MISSING_ITEMS_FOR_ITEM_COUPON` / `MISSING_ITEMS_FOR_CATEGORY_COUPON` | Cart items required |
| `NO_ELIGIBLE_ITEMS_IN_CART` / `NO_ELIGIBLE_CATEGORY_IN_CART` | No eligible items in cart |
| `MIN_ITEM_QTY_NOT_MET` | Minimum item quantity not met |
| `BUY_REQUIREMENT_NOT_MET` | Not enough qualifying items to buy |
| `GET_REQUIREMENT_NOT_MET` | Required free or discount item not in cart |
| `NTH_REQUIREMENT_NOT_MET` | Not enough items to qualify |
| `BXGY_CONFIG_INVALID` / `EVERY_NTH_CONFIG_INVALID` | Offer configuration error |

### Fields this frontend sends on pay

| Payload field | Source |
|---|---|
| `coupon_code` | Validated `code` |
| `coupon_discount` | `computed_discount` |
| `coupon_title` | Title |
| `coupon_type` | `order`, `item`, or `category` |

`self_discount` and `order_discount` stay manual plus preset only. Coupon and loyalty have their own keys.

CRM’s own commit, if the POS backend forwards the order, is `POST /api/pos/orders` with `coupon_code` and `coupon_discount > 0`. Usage is idempotent on `(user_id, order_id)`. The amount the POS sends is what gets billed. CRM stores its own recompute separately as `crm_computed_discount`. A failed recheck does not block the order; `coupon_usage.recorded` is `false`.

---

## End-to-end sequence

```
Customer attached
    │
    ├─ POST /pos/max-redeemable          loyalty preview, 400 ms debounce
    └─ GET  /pos/coupons/available       coupon list, cached, max 3 calls
            │
            └─ POST /pos/coupons/validate   auto-apply or Apply
                    │
                    ▼
         Cashier ticks Loyalty (optional) and presses Pay
                    │
                    ├─ Prepaid:  POST /api/v2/vendoremployee/order/place-order
                    └─ Postpaid: POST /api/v2/vendoremployee/order/order-bill-payment
                            │
                            ▼
                    POS backend commits:
                      loyalty → POST /pos/loyalty/redeem
                      coupon  → coupon_usage on the order webhook
```

Endpoint constants live in `frontend/src/api/constants.js`:

| Constant | Method | Path |
|---|---|---|
| `MAX_REDEEMABLE` | POST | `/pos/max-redeemable` |
| `LOYALTY_REDEEM` | POST | `/pos/loyalty/redeem` (backend only) |
| `COUPONS_AVAILABLE` | GET | `/pos/coupons/available` |
| `COUPONS_VALIDATE` | POST | `/pos/coupons/validate` |
| `PLACE_ORDER` | POST | `/api/v2/vendoremployee/order/place-order` |
| `BILL_PAYMENT` | POST | `/api/v2/vendoremployee/order/order-bill-payment` |

