# Products — Frontend Integration Guide

This covers creating, listing, updating stock, and deleting products, plus changes to cart and checkout that came along with this sprint.

## Creating a Product

`POST /store/:store_id/product`

```json
{
  "name": "Jollof Rice (Large)",
  "sku": "jollof-lg",
  "description": "A generous portion of jollof rice.",
  "price": 1500.00,
  "initial_stock": 30,
  "status": "ACTIVE",
  "category": "Food"
}
```

`description` and `initial_stock` are optional — stock defaults to `0` if you don't send it, useful for staging a product before it physically arrives. `status` only accepts `ACTIVE` or `HIDDEN` here — a product can never be created already deleted, that's a separate action entirely.

`sku` is unique per store, not globally — two different stores can both have a product with sku `"jollof-lg"`, no conflict. If you try to create a product with an sku that already exists at that store, you'll get:

```json
{
  "status": 400,
  "errors": [
    { "field": "sku", "message": "A product with this SKU already exists at this store." }
  ]
}
```

Can also throw the standard forbidden if the caller isn't the store owner or staff with the right permission:

```json
{
  "status": 403,
  "message": "You cannot perform this action"
}
```

On success:

```json
{
  "message": "Product added.",
  "product_id": "2a3c8312-20dc-413d-a58f-a7616c571213"
}
```

## Listing Products

`GET /store/:store_id/products`

Query params: `page`, `limit`, `product_id`, `status` — all optional except none are required at all, really.

If you don't pass `status`, you get everything except deleted products (active and hidden both). Pass `status=ACTIVE` or `status=HIDDEN` to filter to just one. If you want one specific product, pass `product_id` instead of paging through everything.

```json
{
    "products": [
        {
            "product_id": "2a3c8312-20dc-413d-a58f-a7616c571213",
            "name": "Product G",
            "sku": "prod_G",
            "description": null,
            "picture_urls": [],
            "price": "10.1",
            "stock": 10,
            "status": "ACTIVE",
            "category": "Gadgets"
        },
        {
            "product_id": "c995ac11-8d1f-4dae-83cf-ff8dc11a889a",
            "name": "Dummy 02",
            "sku": "dum-002",
            "description": null,
            "picture_urls": [],
            "price": "20",
            "stock": 0,
            "status": "HIDDEN",
            "category": "Gadgets"
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

Can also throw the standard forbidden.

## Editing a Product

`PATCH /store/:store_id/product/:product_id`

This is atomic, not partial — send the full current state of the product every time, not just the fields you changed. There's no merge happening on the backend; whatever you send fully replaces what's there. So `name`, `sku`, `price`, `status`, and `category` are all required on every request, even the ones that didn't change. `description` is the one exception — it's optional, and omitting it clears it out entirely (sets it to `null`) rather than leaving the old value untouched. So if you want to keep the existing description, send it back as-is.

```json
{
  "name": "Jollof Rice (Large)",
  "sku": "jollof-lg",
  "description": "A generous portion of jollof rice.",
  "price": 1600.00,
  "status": "ACTIVE",
  "category": "Food"
}
```

Same as create, `status` only accepts `ACTIVE` or `HIDDEN` here — deleting a product is its own separate endpoint, not a value you can patch into.

If the sku you sent is already taken by another product at this store:

```json
{
  "status": 400,
  "errors": [
    { "field": "sku", "message": "A product with this SKU already exists at this store." }
  ]
}
```

If the product doesn't exist, doesn't belong to this store, or has been deleted:

```json
{
  "status": 404,
  "message": "This product was not found"
}
```

Can also throw the standard forbidden.

On success:

```json
{
  "message": "Product updated."
}
```

## Updating Stock

`PATCH /store/:store_id/product/:product_id/stock`

This is separate from editing the rest of the product, because stock changes constantly — restocks, sales, spoilage — while name, price, category, etc. barely change at all. Bundling them into one form would mean reloading and resending the whole product just to bump a number.

The body is one of two completely different shapes, and which one applies is decided by a `mode` field:

**`mode: "set"`** — you're stating the exact number stock should now be, full stop, no matter what it currently is:
```json
{ "mode": "set", "new_stock": 50 }
```

**`mode: "adjust"`** — you're saying how much to add or remove from whatever the current stock already is:
```json
{ "mode": "adjust", "amount": -5 }
```
A positive `amount` adds (restocking), a negative `amount` subtracts (sold, damaged, lost). You only ever send one of these two shapes per request — never both fields together, and never neither.

If you send a negative `amount` that would push stock below zero, the whole request is rejected — stock never goes negative, not even temporarily:

```json
{
  "status": 404,
  "message": "Insufficient stock for this adjustment."
}
```

Can also throw the standard forbidden.

On success:

```json
{
  "message": "Stock updated.",
  "stock": 45
}
```

## Deleting a Product

`DELETE /store/:store_id/product/:product_id`

No body needed. This should be guarded behind a confirmation popup on the frontend — same treatment as dismissing staff — since there's no way back from here once it's done.

```json
{
  "status": 404,
  "message": "This product was not found"
}
```

You'll get that if the product doesn't exist, doesn't belong to this store, or has already been deleted. Can also throw the standard forbidden.

On success:

```json
{
  "message": "Product deleted."
}
```

## Cart & Checkout Changes

Quick context before the actual changes: products can now be hidden or deleted by stores after a customer's already added them to their cart. It would be a terrible experience to silently delete those items out of someone's cart without them doing it — they'd likely think the app is broken, or panic that something went wrong. So instead, the item stays exactly where it is, and we now tell you enough to handle it gracefully on your end.

### Fetching the Cart

Each item in the cart response now includes a few new fields:

```json
{
  "product_id": "...",
  "quantity": 2,
  "name": "Jollof Rice (Large)",
  "price": "1500.00",
  "picture_urls": [],
  "available_quantity": 10,
  "status": "ACTIVE",
  "store_id": "...",
  "store_name": "...",
  "zone_id": "...",
  "zone_name": "..."
}
```

`status` is either `ACTIVE` or `INACTIVE` — `INACTIVE` covers both hidden and deleted products, you don't need to tell those two apart, they mean the same thing to a customer: can't buy this right now.

What you need to do with it: if any item in the cart has `status: "INACTIVE"`, grey that item out, and also grey out the checkout button for that item's zone, so the customer can't proceed to checkout and get stopped there instead. The only thing they can still do with an inactive item is delete it from their cart manually — adding more, reducing, or setting its quantity is blocked (more on that below). We're deliberately not auto-removing it for them; they need to do it themselves so it's clear what happened.

`available_quantity` is purely informational — show something like "10 left" next to the item if you want. It's not enforced anywhere; a customer can still set quantity past it and nothing breaks, checkout will catch it properly if it ever actually matters.

`picture_urls` is also now included — it's an empty array for now since image upload isn't wired up yet, but the field exists and will populate once that's in.

### Adding/Updating Quantity on Inactive Products

Any attempt to add to cart, set an exact quantity, or increase/decrease quantity on a product that's no longer active will now fail with:

```json
{
  "status": 400,
  "message": "This product is no longer available."
}
```

Removing the item entirely still works regardless of status — that's intentional, it's the one way out.

### Checkout Summary

Same two additions here — `picture_urls`, `available_quantity`, and `status` are now included per item:

```json
{
  "id": "...",
  "name": "Jollof Rice (Large)",
  "quantity": 2,
  "price": "1500.00",
  "picture_urls": [],
  "available_quantity": 10,
  "status": "ACTIVE",
  "store_id": "...",
  "store_name": "..."
}
```

Same idea as the cart — if a customer somehow reaches the summary screen with an inactive item still in there, you can warn them before they hit checkout proper. Checkout itself is still the hard backstop that will reject the order outright if anything's actually unavailable or out of stock by the time payment is attempted — this is just an earlier, friendlier warning so they're not surprised at the very last step.