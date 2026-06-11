# Customer Orders

---

## 1. List Orders
**Endpoint:** `GET /customer/orders`

**Query params:**

| Param | Type | Default | Max | Description |
|-------|------|---------|-----|-------------|
| `page` | number | 1 | — | Page number |
| `limit` | number | 10 | 100 | Items per page |

Both params are optional — omit them and you get page 1 with 10 results.

**Response:**
```json
{
    "orders": [
        {
            "id": "6948c1bc-2b3c-41ea-aa5e-b1d8d8b0c5bd",
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

Use `has_next` and `has_prev` to control next/prev buttons. Orders with a failed payment initiation are excluded automatically.

---

## 2. Order Details
**Endpoint:** `GET /customer/order/:order_id`

**Path param:** `order_id` — UUID of the order, gotten from the list endpoint.

**Response:**
```json
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
    "order_status": "AWAITING_PAYMENT"
}
```

Returns `404` if the order doesn't exist or doesn't belong to the authenticated customer.

---

**Order statuses for reference:**

| Status | Meaning |
|--------|---------|
| `AWAITING_PAYMENT` | Order created, payment not yet completed |
| `PAID` | Payment confirmed, waiting for store to prepare |
| `PREPARING` | Store is preparing the order |
| `READY` | Order is ready for pickup by rider |
| `IN_TRANSIT` | Rider has picked up the order |
| `DELIVERED` | Order delivered successfully |
| `CANCELLED` | Order was cancelled |

> Note: the statuses listed are for reference — use only what your app currently surfaces. Confirm with the backend team if you need to handle any status differently.