# Order Flow — Frontend & Rider Integration Notes



---

## Overview — How an Order Moves

An order goes through these statuses in order:

`PACKAGED` → `CLAIMED` → `COLLECTED` → `DELIVERED`

- **PACKAGED** — the store has packed the order and it's ready for pickup
- **CLAIMED** — a rider has locked the order to themselves
- **COLLECTED** — the rider physically has the order in hand
- **DELIVERED** — the rider entered the correct delivery code and the customer received it

---

## 1. Mark Item as Packaged

**Endpoint:** `PATCH /orders/items/:order_item_id/packaged`

**Who calls this:** Store owner

When you've physically packed an item, call this with the item's ID in the URL. That's it — no request body needed.

**Response:**

```json
{ "message": "Item marked as packaged" }
```

---

## 2. Get Packaged Orders

UPDATED: CHECK THE '# Fetching Orders API.md' FILE TO SEE HOW TO GET PACKAGED ORDERS FOR RIDERS
IT IS THE FIRST ITEM THERE '1. RIDER ORDERS'

---

## 3. Claim an Order

**Endpoint:** `PATCH /rider/:orderId/claim`

**Who calls this:** Rider

Locks the order to you. If another rider claims it first, you get a 409 — handle this gracefully in the UI so the rider knows to pick a different order.

**Success response:**

```json
{ "message": "Order claimed successfully!" }
```

**If someone else already claimed it:**

```json
409 — "This order has been claimed by another rider."
```

---

## 4. Unclaim an Order

**Endpoint:** `PATCH /rider/:orderId/unclaim`

**Who calls this:** Rider

Changed your mind? Puts the order back in the pool for other riders. Only works if you're the one who claimed it, and only while it's still in `CLAIMED` status (not collected yet).

**Response:**

```json
{ "message": "Order unclaimed successfully!" }
```

---

## 5. Collect an Order

**Endpoint:** `PATCH /rider/:orderId/collect`

**Who calls this:** Rider

Call this once you've physically picked up the order from the store. You must have claimed it first.

**Response:**

```json
{ "message": "Order collected!" }
```

---

## 6. Deliver an Order

**Endpoint:** `PATCH /rider/:orderId/deliver`

**Who calls this:** Rider

Final step. The customer has a 6-digit code — the rider enters it here to confirm delivery.

**Request body:**

```json
{ "code": "123456" }
```

**Success response:**

```json
{ "message": "Order delivered successfully" }
```

**If the code is wrong:**

The attempt is counted. After **5 wrong attempts**, the order locks and requires admin intervention. An alert fires automatically when this happens.

**If the order is already locked (5 failed attempts):**

```json
429 — "This order is locked because you entered the wrong code 5 times. Contact an admin to unlock this order."
```

---

## Auth — Quick Notes

Both rider and store owner routes authenticate via JWT in the request headers.

- Store owner routes call `requireStoreOwner()` — token must have role `STORE_OWNER`
- Rider routes call `requireRider()` — token must have role `RIDER`

Sending the wrong role to either endpoint returns a `403 Forbidden`.