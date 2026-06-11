# Orders API

## How Orders Flow

Before diving into the endpoints, here's the mental model. Once a customer places an order and payment is confirmed, the order moves through these stages:

```
PAID → PACKAGED → CLAIMED → COLLECTED → DELIVERED
```

- **PAID** — payment confirmed, store needs to package the items
- **PACKAGED** — store has packaged the items, waiting for a rider to claim it
- **CLAIMED** — a rider has claimed the order and is heading to the store
- **COLLECTED** — rider has picked up the order from the store
- **DELIVERED** — rider has delivered the order to the customer

For customers, there are two extra statuses:
- **FAILED** — customer paid but something went wrong with the amount
- **ABANDONED** — customer never completed payment

Keep this flow in mind as you read the endpoints below — the `status` you pass is always one of these stages.

---

## 1. Rider Orders
**`GET /rider/orders`**

In v1, you had three separate endpoints — one for claimed orders, one for collected, one for delivered. That's gone. It's now one endpoint and the `status` query param is what gives you what you need.

**Query params:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | string | Yes | What orders you want to see |
| `page` | number | No | Page number, defaults to 1 |
| `limit` | number | No | Items per page, defaults to 10, max 100 |

**How status works:**

- Pass `CLAIMED` → you see your claimed orders
- Pass `COLLECTED` → you see your collected orders
- Pass `DELIVERED` → you see your delivered orders
- Pass `PACKAGED` → you see all available orders in your institution that are ready to be picked up. This is your "available jobs" list.

**Response:**
```json
{
    "orders": [
        {
            "id": "eafa63a0-4dc2-402b-8d74-cc48647098f5",
            "order_status": "PACKAGED",
            "payment_status": "PAID",
            "payment_resolved_at": "2026-01-01T12:00:00Z",
            "landmark_details": "Room A46"
        }
    ],
    "pagination": {
        "total": 2,
        "page": 1,
        "limit": 10,
        "total_pages": 1,
        "has_next": false,
        "has_prev": false
    }
}
```

Use `has_next` and `has_prev` to control your next/prev buttons.

---

## 2. Store Orders
**`GET /store/:store_id/orders`**

Same idea as rider — one endpoint, status tells you what you need.

**Path param:** `store_id` — the ID of the store you are fetching orders for.

**Query params:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | string | Yes | Either `PAID` or `PACKAGED` |
| `page` | number | No | Page number, defaults to 1 |
| `limit` | number | No | Items per page, defaults to 10, max 100 |

**How status works:**

- Pass `PAID` → orders that have just come in and are waiting to be packaged. These are your new orders.
- Pass `PACKAGED` → orders you have already packaged and are waiting for a rider.

One important thing about the response — the `items` array only contains products that belong to your store. If an order has items from multiple stores, you will only see yours.

**Response:**
```json
{
    "orders": [
        {
            "id": "eafa63a0-4dc2-402b-8d74-cc48647098f5",
            "order_status": "PAID",
            "items": [
                {
                    "name": "Jollof Rice",
                    "quantity": 2
                }
            ]
        }
    ],
    "pagination": {
        "total": 5,
        "page": 1,
        "limit": 10,
        "total_pages": 1,
        "has_next": false,
        "has_prev": false
    }
}
```

---

## 3. Customer Orders
**`GET /customer/orders`**

Same pattern — one endpoint, pass a status to filter.

**Query params:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | string | No | Filter by order status. If not passed, returns all orders. |
| `page` | number | No | Page number, defaults to 1 |
| `limit` | number | No | Items per page, defaults to 10, max 100 |

**Available statuses:** `PAID`, `PACKAGED`, `CLAIMED`, `COLLECTED`, `DELIVERED`, `FAILED`, `ABANDONED`

**Response:**
```json
{
    "orders": [
        {
            "id": "eafa63a0-4dc2-402b-8d74-cc48647098f5",
            "items": [
                {
                    "price": "10.1",
                    "name": "Product A",
                    "quantity": 1
                }
            ],
            "total": 210.1,
            "order_status": "PAID"
        }
    ],
    "pagination": {
        "total": 3,
        "page": 1,
        "limit": 10,
        "total_pages": 1,
        "has_next": false,
        "has_prev": false
    }
}
```

---

> All three endpoints require authentication. You will only ever see data that belongs to you or your store.