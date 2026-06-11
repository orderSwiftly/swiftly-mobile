# Store Switcher

**`GET /stores`**

Call this after login if the user's role is `STORE_OWNER` or `STAFF`. Returns all stores they have access to — this is what you use to build the store switcher in the side panel.

**No query params. No body. Just the auth header.**

**Response:**
```json
[
    {
        "store_id": "20c6dc32-ddaa-40a5-a537-0a581f66dc38",
        "store_name": "Triple Bites",
        "store_address": "Block C, Main Campus",
        "store_institution": "BABCOCK"
    },
    {
        "store_id": "f8e07872-62e9-4ddc-816b-cfdf51d821de",
        "store_name": "BIG Meals",
        "store_address": "SUB Ground Floor",
        "store_institution": "BABCOCK"
    }
]
```

Store the `store_id` of whichever store the user switches to — that's what goes into every subsequent store-related request as the `:store_id` path param.