# Checkout Flow — Breaking Changes

> Only naming has changed across the board. No logic, no flow, no response structure has been altered. If something was called `address_*` before, it is now called `landmark_*`. That's the entire story.

---

## 1. List Landmarks
**Endpoint:** `GET /addresses/:store_zone_id` → `GET /landmarks/:store_zone_id`

Everything else about this endpoint is identical — same params, same auth, same behaviour.

The response shape:

- Top-level key `addresses` is now `landmarks`
- All fields prefixed `address_` are now prefixed `landmark_`
- `recent_addresses` key stays the same, but its fields also move from `address_` to `landmark_`

```json
{
    "landmarks": [
        {
            "landmark_id": "20c6dc32-ddaa-40a5-a537-0a581f66dc38",
            "landmark_name": "Bethel",
            "landmark_zone_id": "0e645567-d91c-4b0b-a906-ebf0dc8213d2",
            "landmark_zone_name": "MH"
        }
    ],
    "recent_addresses": [
        {
            "id": "f33fe63e-d9f3-4e9c-a8a0-35d09fea60b4",
            "landmark_id": "20c6dc32-ddaa-40a5-a537-0a581f66dc38",
            "landmark_name": "Bethel",
            "landmark_details": "A46",
            "landmark_zone_id": "0e645567-d91c-4b0b-a906-ebf0dc8213d2",
            "landmark_zone_name": "MH"
        }
    ]
}
```

Note: the list is no longer paginated or limited — you get everything in one push. Search/filter on your end as the user types.

---

## 2. Checkout Summary
**Endpoint:** `GET /checkout/:store_zone_id/summary` — URL unchanged

The query param changed:

`?address_zone_id=` → `?landmark_zone_id=`

Use the `landmark_zone_id` from the landmarks list exactly as you used `address_zone_id` before. Response is identical.

---

## 3. Checkout
**Endpoint:** `POST /checkout/:store_zone_id` — URL unchanged

The request body changed:

```json
// Before
{
    "address_id": "...",
    "address_zone_id": "...",
    "details": "Room A46"
}

// Now
{
    "landmark_id": "...",
    "landmark_zone_id": "...",
    "details": "Room A46"
}
```

Use the `landmark_id` and `landmark_zone_id` from the landmarks list exactly as before. `details` is unchanged.

The response now includes `tx_reference` alongside `payment_link`:

```json
{
    "tx_reference": "ord_...",
    "payment_link": "https://..."
}
```

Hold on to `tx_reference` — it will be needed for payment verification. More on that soon.

---

That's everything. Find and replace `address_` with `landmark_` and you're most of the way there.


## 4. 
Claude limit don hit, I'll just type this by myself 
There's a new endpoint 

GET /payment/order/:tx_reference 
the tx_reference is the same tx_reference from the checkout

and the response is 

```json
{
    "status": "PAID"
}
```

the statuses can be 

PENDING => the payment has not yet been confirmed on flutterwave

PAID => the payment is paid 

FAILED => the payment failed -- maybe customer paid the wrong amount or whatever 

ABANDONED => the customer never even paid at all, probably they left the app before the flutterwave UI showed