# Role-Based Discount — Implementation Spec

**System:** MyGenie Restaurant POS (Flutter / GetX)
**Created:** 2026-10-07 — derived from live codebase on the branch that already has this feature
**Status:** Spec only. Implement on the target branch. Do **not** invent extra screens, APIs, or restaurant-settings toggles.

This document is the source of truth for porting the feature. Copy the gates, payloads, and file list as written. Do not “improve” the permission check to `permissions.contains('discount')` unless the target branch already uses `permissions` everywhere for this feature — the live implementation uses **`profile.role.contains('discount')`**.

---

## 1. What this feature is

Restaurant-level switch that decides **who can see and edit discount fields** on checkout and collect-bill screens.

| Restaurant flag | Employee role | Result |
|-----------------|---------------|--------|
| `role_base_discount` is `'No'` (default) | any | Discount UI is **not** role-gated. Anyone who already passed the other discount conditions can edit discount. |
| `role_base_discount` is `'Yes'` | `role` list **contains** `'discount'` | Staff can see/edit discount fields. On collect bill / pay later they also get Discount Note + Apply checkbox, which POSTs `order-discount-manage`. |
| `role_base_discount` is `'Yes'` | `role` list does **not** contain `'discount'` | Staff **cannot** edit discount. Collect bill / pay later show a **read-only** “Order Discount Applied” amount (and note). Checkout **hides** Discount Category / Discount Type / amount entirely. |

This is **not** a new discount math engine. Existing `amountCalculation()`, restaurant `discountType`, coupon lock (`!isCouponValidate`), and place-order discount payload stay as they are. This feature only **gates the UI** and, on collect bill / pay later, **persists** a discount onto an existing order via one extra API.

---

## 2. Business rules (must match exactly)

1. Source of the restaurant flag is **login/profile JSON**, not a POS settings screen.
   - JSON key: `restaurants[0].settings.role_base_discount`
   - Dart field: `Settings.isRoleBaseDiscount`
   - Default when missing: `'No'`
2. Source of the employee permission is **`profile.role`**, a `List<String>?`.
   - Check: `profile.role!.contains('discount')`
   - The token is the string `'discount'` (lowercase). Do not use `'Discount'`, `'apply_discount'`, or `permissions.contains('discount')`.
3. Gate expression used everywhere except the Apply checkbox:

```dart
(Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .settings!
            .isRoleBaseDiscount ==
        'Yes'
    ? Get.find<AuthController>().profileModel!.role!.contains('discount')
    : true)
```

   Read it as: **if the restaurant turned the flag on, require the role; otherwise allow.**

4. Apply-discount checkbox (collect bill / pay later only) is **stricter**. It shows only when **both** are true:
   - `role.contains('discount')`
   - `settings.isRoleBaseDiscount == 'Yes'`
   When the restaurant flag is `'No'`, there is **no** Apply checkbox and **no** `order-discount-manage` call. Discount is still entered locally and sent on the existing collect/place payment path.

5. Checkout **does not** call `order-discount-manage`. Role-base only hides the three discount widgets. Place-order still sends whatever discount is in local state (including `0` when hidden).

6. Coupon already applied (`isCouponValidate == true`) still hides discount category / type / amount, same as before. Role-base is **AND**ed with those existing conditions, not a replacement.

7. Restaurant `discountType == 'No'` still hides Discount Type and amount (existing rule). Role-base does not override that.

8. If a role-base discount is already stored on the order (`order_discount_json`), collect bill (and pay later, once init is enabled) prefills amount / type / note and sets `isApplyDiscountForRoleBase = true`. Changing the amount after that **unapplies** via API with `discount_amount: 0`.

9. Staff **without** `'discount'` when the flag is `'Yes'` must still **see** an already-applied amount so they can collect the reduced bill. They must not be able to change it.

10. Do not add a restaurant-config UI toggle in this POS app. Ops/backend set `role_base_discount`. POS only reads it.

---

## 3. Data model

### 3.1 `Settings` on restaurant (`lib/data/model/response/profile_model.dart`)

Add (or keep) on `Settings`:

```dart
String? isRoleBaseDiscount;
```

Constructor: include `this.isRoleBaseDiscount`.

`fromJson`:

```dart
isRoleBaseDiscount = json['role_base_discount'] ?? 'No';
```

`toJson`:

```dart
data['role_base_discount'] = this.isRoleBaseDiscount;
```

Do not rename the JSON key. Do not default to `null` — missing key must become `'No'` so existing restaurants keep open discount UI.

### 3.2 `OrderDiscountJson` on collect-bill response

File: `lib/data/model/response/get_collect_bill_resoonse_model.dart`

Parent order object has:

```dart
OrderDiscountJson? orderDiscountJson;
```

`fromJson` on the parent:

```dart
orderDiscountJson: json['order_discount_json'] != null
    ? OrderDiscountJson.fromJson(json['order_discount_json'])
    : null,
```

Class (copy as-is):

```dart
class OrderDiscountJson {
  int? id;
  int? orderId;
  String? discountType;   // 'percent' | 'fixed' (API). UI uses 'Percent' | 'Amount'
  String? discountNote;
  double? discountAmount; // JSON field name is `discount`, not `discount_amount`

  OrderDiscountJson({
    this.id,
    this.orderId,
    this.discountType,
    this.discountNote,
    this.discountAmount,
  });

  factory OrderDiscountJson.fromJson(Map<String, dynamic> json) {
    return OrderDiscountJson(
      id: json['id'],
      orderId: json['order_id'],
      discountType: json['discount_type'] ?? 'percent',
      discountNote: json['discount_note'] ?? '',
      discountAmount: json['discount'] == null
          ? 0
          : double.parse('${json['discount'] ?? 0}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'discount_type': discountType,
      'discount_note': discountNote,
      'discount': discountAmount,
    };
  }
}
```

If the target branch’s collect-bill model class names differ, attach the same JSON keys (`order_discount_json`, `discount`, `discount_type`, `discount_note`) to whatever order object collect bill already parses.

---

## 4. API

### 4.1 Constant

File: `lib/util/app_constants.dart`

```dart
static const String APPLY_DISCOUNT_FOR_ROLE_BASE_URI =
    '/api/v1/vendoremployee/order-discount-manage';
```

### 4.2 Repo

File: `lib/data/repository/pos_repo.dart`

```dart
Future<Response> applyDiscountForRoleBase({required var jsonData}) async {
  return await apiClient.postData(
      AppConstants.APPLY_DISCOUNT_FOR_ROLE_BASE_URI, jsonData);
}
```

Use the existing authenticated `apiClient.postData`. No extra headers.

### 4.3 Controller

File: `lib/controller/pos_controller.dart`

```dart
Future<void> applyDiscountForRoleBase({required var jsonData}) async {
  _isLoading = true;
  update();
  Response response =
      await posRepo.applyDiscountForRoleBase(jsonData: jsonData);
  if (response.statusCode == 200) {
    showCustomSnackBar(response.body['message']);
  } else {
    ApiChecker.checkApi(response);
  }
  _isLoading = false;
  update();
}
```

Success = HTTP 200. Toast `response.body['message']`. Failures go through existing `ApiChecker`.

### 4.4 Request body

```json
{
  "order_id": 123,
  "discount_amount": 10,
  "discount_type": "percent",
  "discount_note": "optional note"
}
```

| Field | Rules |
|-------|--------|
| `order_id` | Collect-bill / pay-later `widget.orderId` (int). Never call this API from checkout — there is no persisted order id yet (or the screen does not use this path). |
| `discount_amount` | Number from `_discountController.text`. On **unapply**, send `0`. |
| `discount_type` | `'percent'` if UI `selectedDiscountType == 'Percent'`, else `'fixed'`. UI values are `'Percent'` and `'Amount'`; API values are `'percent'` and `'fixed'`. |
| `discount_note` | `_discountNoteController.text` on apply; `''` on unapply. |

Do **not** convert Amount (fixed) into a percent of subtotal in the payload. A commented-out conversion exists in collect bill — leave it commented / do not port it as live code.

### 4.5 When to POST

| Action | `discount_amount` | `discount_note` | Local flag after toggle |
|--------|-------------------|-----------------|-------------------------|
| Staff taps Apply (currently off) | parsed field value | note text | `isApplyDiscountForRoleBase = true` |
| Staff taps Apply (currently on) → unapply | `0` | `''` | `isApplyDiscountForRoleBase = false` |
| Staff with apply-on changes the amount field | `0` | `''` | `isApplyDiscountForRoleBase = false` (amount `onChanged`) |

Validation **before** apply/unapply tap:

- empty amount → toast `'Please enter discount amount'`
- amount `== 0` → toast `'Please enter discount amount'`
- `selectedDiscountType == 'Percent'` and amount `> 100` → toast `'Please enter valid discount'`

Empty/`0` validation means you **cannot** use the checkbox itself to unapply when the field is already `0`. Unapply with a non-zero field still works (toggle sends `0`). Changing the text field while applied also unapplies.

---

## 5. Shared gate (copy this; do not invent helpers unless you keep the same semantics)

Recommended local helper if the target branch is cleaner — **optional**. Live code inlines the ternary. Either is fine if behavior matches §2.

```dart
bool get canEditRoleBaseDiscount {
  final profile = Get.find<AuthController>().profileModel!;
  final settings = profile.restaurants!.first.settings;
  if (settings?.isRoleBaseDiscount != 'Yes') return true;
  return profile.role?.contains('discount') ?? false;
}

bool get showRoleBaseApplyCheckbox {
  final profile = Get.find<AuthController>().profileModel!;
  return (profile.role?.contains('discount') ?? false) &&
      profile.restaurants!.first.settings?.isRoleBaseDiscount == 'Yes';
}

bool get showReadOnlyAppliedDiscount {
  final profile = Get.find<AuthController>().profileModel!;
  return profile.restaurants!.first.settings?.isRoleBaseDiscount == 'Yes' &&
      !(profile.role?.contains('discount') ?? false);
}
```

**Null caution (live code uses `settings!` and `role!`):** if `settings` is null, this crashes today. Prefer `settings?.` on the target branch if that restaurant is known to send `settings: null`. Do not change unrelated `settings!` usages.

---

## 6. Screen: Checkout (`lib/view/screens/pos/checkout_order_screen.dart`)

**Scope:** hide three widgets. No Apply checkbox. No `order-discount-manage`. No discount note field.

Wrap **each** of these existing `if`s with the §2 ternary (AND, keep every existing clause):

1. **Discount Category** dropdown  
   Existing: `selectedDiscountType == 'Percent'` AND `discountList != null` AND `!isCouponValidate` AND `discountList.isNotEmpty`  
   Live branch also requires `restaurants.first.isOrderPaymentType != 'postpaid'`. Port that extra clause **only if** the target branch already has the postpaid checkout hide. Role-base work must not introduce postpaid hiding.

2. **Discount Type** dropdown (`Percent` / `Amount` / `No`)  
   Existing: `discountType != 'No'` AND `!isCouponValidate` (and postpaid check on live branch). Live also has `(widget.editOrder == null)` on type + amount.

3. **Discount amount** field (label = `restaurants.first.discountText`)  
   Existing: `discountType != 'No'` AND `selectedDiscountType != 'No'` AND `!isCouponValidate` (and postpaid / `editOrder == null` on live branch).

Pattern:

```dart
if ((/* all existing conditions */) &&
    (settings.isRoleBaseDiscount == 'Yes'
        ? role.contains('discount')
        : true))
```

### Checkout behavior when hidden

- Do not clear restaurant-configured default discount unless the target screen already does that on init.
- Place-order payload still includes the current `_discountController` / type. If the user never saw the fields, they get whatever was initialized (often `0` or restaurant default).
- Do **not** add read-only “Order Discount Applied” on checkout.

---

## 7. Screen: Collect Bill (`lib/view/screens/waiter/collect_payment/collect_payment.dart`)

This is the full role-base surface.

### 7.1 State

Add:

```dart
bool isApplyDiscountForRoleBase = false;
final TextEditingController _discountNoteController = TextEditingController();
```

`_discountController` and `selectedDiscountType` already exist.

### 7.2 Init / prefill (after collect-bill API returns)

Run when `settings.isRoleBaseDiscount == 'Yes'` **and** `orderDiscountJson != null`. Live code does **not** also require `role.contains('discount')` for prefill — everyone gets local state filled; UI then decides edit vs read-only.

```dart
if (Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .settings!
            .isRoleBaseDiscount ==
        'Yes' &&
    posController.getCollectBillResponseModel!.order!.orderDiscountJson !=
        null) {
  isApplyDiscountForRoleBase = true;
  _discountController.text = posController.getCollectBillResponseModel!
      .order!.orderDiscountJson!.discountAmount
      .toString();
  selectedDiscountType = posController.getCollectBillResponseModel!.order!
              .orderDiscountJson!.discountType ==
          'percent'
      ? 'Percent'
      : 'Amount';
  _discountNoteController.text = posController
      .getCollectBillResponseModel!.order!.orderDiscountJson!.discountNote
      .toString();
}
```

Call `amountCalculation()` after this as the screen already does after loading the bill.

Exact property path (`getCollectBillResponseModel.order.orderDiscountJson`) may differ if the target model nests differently — map `order_discount_json` from the same collect-bill response the screen already uses.

### 7.3 Widgets — who sees what

AND the §2 ternary onto existing conditions for:

| Widget | Extra existing conditions (keep them) |
|--------|----------------------------------------|
| Discount Category | `selectedDiscountType == 'Percent'` AND `discountList` non-null/non-empty AND `!isCouponValidate` |
| Discount Type | `restaurants.first.discountType != 'No'` AND `!isCouponValidate` |
| Discount amount field | `discountType != 'No'` AND `selectedDiscountType != 'No'` AND `!isCouponValidate` |

**Amount field `onChanged`:** if `isApplyDiscountForRoleBase` is true, unapply immediately:

```dart
if (isApplyDiscountForRoleBase) {
  isApplyDiscountForRoleBase = false;
  var jsonData = {
    "order_id": widget.orderId,
    "discount_amount": 0,
    "discount_type":
        selectedDiscountType == 'Percent' ? 'percent' : 'fixed',
    "discount_note": ''
  };
  await posController.applyDiscountForRoleBase(jsonData: jsonData);
}
amountCalculation();
```

### 7.4 Read-only (no `'discount'` role, flag `'Yes'`)

Show **in addition to** hiding the editors:

1. Label + amount (right-aligned):

```text
Order Discount Applied :  {_discountController.text}
```

Gate:

```dart
if (settings.isRoleBaseDiscount == 'Yes' &&
    !role.contains('discount'))
```

2. Note (same gate):

```text
Order Discount Note :  {_discountNoteController.text}
```

Use existing `poppinsMedium` / shortestSide font sizes (`15` vs `11`) and `right: 15, top: 10` padding so it lines up with other collect-bill rows.

### 7.5 Discount Note + Apply checkbox (has `'discount'` role **and** flag `'Yes'`)

Show **only** with the stricter gate (§2 rule 4). Independent of `discountType == 'No'` in the live code — if they have the role and the flag is on, they get note + checkbox even when category/type/amount might still be hidden by coupon / `discountType`. In practice amount must be non-zero to apply.

**Discount Note:** right-aligned row, label `'Discount Note : '`, `TextFormField` bound to `_discountNoteController`, width `Get.width * 0.35`, same border as other fields. Live `onChanged` is a no-op (`(s) async {}`).

**Apply control:** `InkWell` toggling `isApplyDiscountForRoleBase`, then POST §4.4.

Checkbox visuals (copy):

- `isApplyDiscountForRoleBase == true` → `Icons.check_box`, color `Theme.of(context).secondaryHeaderColor`
- else → `Icons.check_box_outline_blank_outlined`, color `Colors.grey`
- Label: `'Apply Discount'`
- Row `mainAxisAlignment: MainAxisAlignment.end`, padding `right: 15`

After API: `if (mounted) setState(() {});`

`amountCalculation()` is called at the start of the tap handler (before validation). Discount still affects local totals the same way a normal collect-bill discount does; the API persists it on the order for other staff / later collection.

---

## 8. Screen: Pay Later Collect Bill (`lib/view/screens/paid_order/pay_later_collect_bill.dart`)

Mirror **collect bill UI gates** (§7.3–§7.5): same ternary, same read-only labels, same note + Apply checkbox, same payload, same `onChanged` unapply.

**Init prefill:** on the live branch the equivalent of §7.2 is **commented out**. Port the UI. Restore prefill on pay later **if** that screen’s collect-bill (or pay-later) response includes `order_discount_json`. If it does not, leave prefill out rather than crashing. Prefer enabling the same prefill block as collect bill when the model has `orderDiscountJson`.

Do not add role-base to tablet `payment_method` / other pay sheets unless those screens already have Discount Category / Type / amount. Live role-base is only checkout + collect bill + pay later.

---

## 9. Discount math (do not rewrite)

Role-base does not change how a typed amount becomes a rupee discount.

- UI type `'Percent'` → amount is percent of the same base `amountCalculation()` already uses.
- UI type `'Amount'` → amount is a fixed rupee discount.
- Coupon path (`isCouponValidate`) continues to lock discount fields.
- Loyalty / tips / service charge / GST stay untouched.

When flag is `'Yes'` and user has no `'discount'` role, they never type a new value; totals must use the prefilled `_discountController` from `order_discount_json` (collect bill).

---

## 10. Files to touch (checklist)

Implement **only** these unless the target branch’s collect-bill model lives under a different path.

| File | Change |
|------|--------|
| `lib/data/model/response/profile_model.dart` | `Settings.isRoleBaseDiscount` from `role_base_discount` default `'No'` |
| `lib/data/model/response/get_collect_bill_resoonse_model.dart` (or equivalent) | `OrderDiscountJson` + `order.orderDiscountJson` from `order_discount_json` |
| `lib/util/app_constants.dart` | `APPLY_DISCOUNT_FOR_ROLE_BASE_URI` |
| `lib/data/repository/pos_repo.dart` | `applyDiscountForRoleBase` |
| `lib/controller/pos_controller.dart` | `applyDiscountForRoleBase` |
| `lib/view/screens/pos/checkout_order_screen.dart` | AND role-base ternary on Discount Category / Type / amount only |
| `lib/view/screens/waiter/collect_payment/collect_payment.dart` | state, prefill, gates, read-only, note, apply/unapply |
| `lib/view/screens/paid_order/pay_later_collect_bill.dart` | same UI as collect bill; prefill if model has the JSON |

---

## 11. Do not touch

- Restaurant settings / menu-management screens (no POS toggle for `role_base_discount`).
- Login, `permissions` list, KDS, order_edit, Check In, popular category, CRM, coupons, loyalty, wallet.
- Place-order / collect-payment **payload shape** except the new POST above.
- KOT / Captain print, sockets, room GST, postpaid checkout hiding, service-charge force-off, TypeAhead, complementary sheet.
- `tablet_payment_method` unless that file already has the same discount dropdowns **and** product asks to gate them (live app does not).
- Renaming `role` → `permissions` for this check.
- Backend. If `order-discount-manage` 404s on the target environment, that is a server deploy issue, not a POS workaround.

---

## 12. Acceptance tests

Use three employees on one restaurant, then repeat with the flag off.

### A. Flag `'No'` (default)

- Checkout: Discount Category / Type / amount visible under the **existing** (non-role) rules, for staff **with and without** `'discount'` in `role`.
- Collect bill: same. No “Apply Discount” checkbox. No “Order Discount Applied” read-only row.
- No POST to `order-discount-manage`.

### B. Flag `'Yes'`, employee **has** `'discount'`

- Checkout: discount widgets visible (still hidden if coupon / `discountType == 'No'` / other existing rules).
- Collect bill: category / type / amount visible; Discount Note visible; Apply checkbox visible.
- Enter `10`, type Percent, optional note, tap Apply → POST `discount_amount: 10`, `discount_type: "percent"`. Totals update. Checkbox looks checked.
- Tap Apply again → POST `discount_amount: 0`, `discount_note: ""`. Checkbox unchecked.
- With apply on, edit the amount field → POST unapply (`0`) and checkbox off.
- Percent `> 100` or empty/`0` on Apply → toast, no toggle.

### C. Flag `'Yes'`, employee **lacks** `'discount'`

- Checkout: Discount Category / Type / amount **hidden**.
- Collect bill: those editors **hidden**. If the order has `order_discount_json`, show “Order Discount Applied” and “Order Discount Note” with prefilled values; bill totals include that discount. No Apply checkbox.
- Staff cannot change the discount.

### D. Prefill

- Employee with `'discount'` opens collect bill on an order that already has `order_discount_json` → amount, type (`percent`→`Percent`, else `Amount`), note, and `isApplyDiscountForRoleBase == true`.
- Employee without `'discount'` sees the same numbers read-only.

### E. Coupon

- Valid coupon still hides discount editors. Role-base does not re-show them.

### F. Pay later

- Same visibility matrix as collect bill.
- Apply POST uses that screen’s `orderId`.

---

## 13. Known live-branch quirks (port or document, do not “fix” unless asked)

1. **Pay later init prefill is commented out** while the UI gates are live. Totals on pay later may not show a previously managed discount until prefill is restored.
2. **Apply checkbox ignores `discountType == 'No'`** in its `if`; category/type/amount still respect `discountType`.
3. **`settings!` / `role!`** will NPE if either is null. Target branch may use `?.` / `?? false` without changing the boolean meaning.
4. **Checkout postpaid hide** (`isOrderPaymentType != 'postpaid'`) is a **separate** feature on the live branch. Do not bundle it into this port.
5. **JSON amount field is `discount`**, request field is `discount_amount`. Do not mix them.
6. **Checkbox unapply** requires a non-zero field to pass validation; clearing the field to `0` and tapping Apply will toast instead of sending `0`. Amount `onChanged` is the reliable unapply-while-applied path.

---

## 14. Suggested implementation order

1. `Settings.isRoleBaseDiscount` default `'No'` — safe, no UI change.
2. Constant + repo + controller method.
3. `OrderDiscountJson` on collect-bill model.
4. Checkout three `if`s.
5. Collect bill state, prefill, gates, read-only, note, apply.
6. Pay later same UI; enable prefill if the response includes `order_discount_json`.
7. Run §12 matrix.

If anything in this spec conflicts with an explicit product instruction on the target branch, follow that instruction and note the delta. Otherwise match this document.
