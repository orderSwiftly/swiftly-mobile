# Staff Management — Frontend Integration Guide

This covers everything you need to list staff, invite new ones, and manage their status (suspend, reinstate, dismiss).

## Listing Staff

`GET /store/:store_id/staffs`

This returns the staff working at a store, paginated. Here's what a real response looks like:

```json
{
    "staffs": [
        {
            "staff_id": "92c949c8-2fe2-45f6-92f7-6a1ec14ec436",
            "first_name": "Staff Zero",
            "last_name": "0",
            "status": "ACTIVE",
            "role_id": "0a41626e-c5d9-4dfd-8695-5b97ee1257dc",
            "role_name": "manage staff"
        },
        {
            "staff_id": "d5cd4a77-d0ad-40f2-80bf-e72267f1a3e7",
            "first_name": "Staff One",
            "last_name": "1",
            "status": "ACTIVE",
            "role_id": null,
            "role_name": null
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

A staff member can have no role assigned yet (`role_id` and `role_name` both `null`), as seen with Staff One above. Handle that case in the UI — show something like "No role assigned" rather than leaving it blank.

You must pass a `status` query param: `ACTIVE`, `SUSPENDED`, or `DISMISSED`. There's no "show everyone regardless of status" option — this is intentional, since active staff, suspended staff, and dismissed staff are meant to be viewed as separate lists/tabs in the UI, not one mixed table.

Depending on which status you query, the response includes a relevant timestamp:
- `status: "SUSPENDED"` → response includes `suspended_at`
- `status: "DISMISSED"` → response includes `dismissed_at`
- `status: "ACTIVE"` → no extra timestamp, since there's nothing to show

You can also filter by `role_id` or `staff_id` if you need a narrower list.

## Inviting Staff

`POST /store/:store_id/staff/invite`

The body is an array, not a single object — even if you're only inviting one person, wrap it in an array of one. This is so a store can invite multiple staff members in a single request instead of looping API calls on the frontend.

```json
[
  {
    "email": "staff@example.com",
    "phone": "+2348012345678",
    "first_name": "John",
    "last_name": "Doe",
    "role_id": "0a41626e-c5d9-4dfd-8695-5b97ee1257dc"
  }
]
```

`role_id` is optional — staff can be invited without a role and assigned one later.

Behind the scenes: a password is auto-generated and emailed to each staff member along with their login email. They log in with that, and can change it whenever they like from their profile — nothing forces them to.

**Possible errors to handle:**

If a `role_id` you sent doesn't exist or doesn't belong to this store, you'll get:
```json
{
  "status": 400,
  "message": "Some roles are invalid or do not belong to this store",
  "invalid_role_ids": ["..."]
}
```

If any submitted email or phone number is already in use by an existing account (staff, customer, anyone), you'll get:
```json
{
  "status": 409,
  "message": "Some staff details are already in use",
  "conflicts": [
    { "field": "email", "value": "taken@example.com" },
    { "field": "phone", "value": "+2348012345678" }
  ]
}
```

The whole invite request is all-or-nothing — if there's a conflict or invalid role anywhere in the batch, nothing in that batch gets created. Fix the offending entries and resubmit.

You'll also get standard validation errors (missing fields, bad email format, duplicate email/phone *within the same request*, etc.) in the usual field/message shape.

## Managing Staff Status

There are three actions: suspend, reinstate, and dismiss. Think of them like this:

**Suspend** — `PATCH /store/:store_id/staff/:staff_id/suspend`

Use this when a staff member has done something wrong and the store wants to temporarily send them away without fully cutting ties. It's reversible. No body needed, just hit the endpoint.

**Reinstate** — `PATCH /store/:store_id/staff/:staff_id/reinstate`

The opposite of suspend. Brings a suspended staff member back to active. Only works on someone currently suspended — won't work on someone who's active already or dismissed.

**Dismiss** — `PATCH /store/:store_id/staff/:staff_id/dismiss`

This is permanent. Once dismissed, that's it — there's no "undismiss." If the store wants that person back, they'd have to be invited again as a brand new staff member.

Because this can't be undone, **the frontend needs a confirmation step before calling this endpoint.** Show a dialog warning them this is permanent, and require them to type in the staff member's email to confirm before the action goes through. This confirmation is purely a frontend safeguard — the backend doesn't check the email, so don't skip building it.

A staff member can't suspend, reinstate, or dismiss themselves — the API blocks that regardless of permissions.

## Listing Roles

`GET /store/:store_id/roles`

Returns the roles configured for a store, paginated. You can narrow this down with `role_id` if you just want one specific role. By default, staff members aren't included in the response — pass `show_staff=true` if you want to see who's currently assigned to each role.

Without `show_staff`:

```json
{
    "roles": [
        {
            "role_id": "61923068-5cb0-4466-a470-46d133430438",
            "name": "HR",
            "permissions": {
                "MANAGE_STAFF": true,
                "MANAGE_PRODUCT": false
            }
        }
    ],
    "pagination": {
        "total": 1,
        "page": 1,
        "limit": 10,
        "total_pages": 1,
        "has_next": false,
        "has_prev": false
    }
}
```

With `show_staff=true`:

```json
{
    "roles": [
        {
            "role_id": "61923068-5cb0-4466-a470-46d133430438",
            "name": "HR",
            "permissions": {
                "MANAGE_STAFF": true,
                "MANAGE_PRODUCT": false
            },
            "memberships": [
                {
                    "staff_id": "92c949c8-2fe2-45f6-92f7-6a1ec14ec436",
                    "first_name": "Staff Zero",
                    "last_name": "0",
                    "email": "ninechannel009@gmail.com",
                    "status": "ACTIVE"
                }
            ]
        }
    ],
    "pagination": {
        "total": 1,
        "page": 1,
        "limit": 10,
        "total_pages": 1,
        "has_next": false,
        "has_prev": false
    }
}
```

Notice `permissions` here is a map, not a list — every permission the system supports shows up as a key, with `true` or `false` telling you whether that role has it. This is intentional, and the same shape is used everywhere permissions are sent or received, so a settings screen can render a toggle for every permission without needing to separately know what permissions exist.

## Assigning a Role to Staff

`PATCH /store/:store_id/staff/:staff_id/role`

Send a `role_id` to assign that role to a staff member. Send `null` to remove their current role entirely (this is also how you "revoke" a role — there's no separate revoke endpoint, sending `null` here does it).

```json
{
  "role_id": "61923068-5cb0-4466-a470-46d133430438"
}
```

**Possible errors:**

A staff member can't change their own role:
```json
{
  "status": 403,
  "message": "You cannot change your own role."
}
```

If the `role_id` you sent doesn't exist (or belongs to a different store):
```json
{
  "status": 404,
  "message": "This role does not exist."
}
```

If the target staff member isn't found at this store:
```json
{
  "status": 404,
  "message": "This staff does not work at this store."
}
```

## Listing Permissions

`GET /store/:store_id/staff-permissions`

This is a reference endpoint — use it to build the role creation/editing screen, where the owner toggles permissions on and off for a role. It always returns every permission the system currently supports, with a friendly title and description for each, so you don't need to hardcode permission names anywhere on the frontend.

```json
{
    "permissions": [
        {
            "permission": "MANAGE_STAFF",
            "title": "Manage Staff",
            "description": "Invite, suspend, dismiss staff, and manage roles."
        },
        {
            "permission": "MANAGE_PRODUCT",
            "title": "Manage Products",
            "description": ""
        }
    ]
}
```

`permission` is the raw value you'll send back when creating or editing a role. `title` and `description` are just for display.

## Creating a Role

`POST /store/:store_id/role`

```json
{
  "name": "Cashier",
  "permissions": {
    "MANAGE_STAFF": false,
    "MANAGE_PRODUCT": true
  }
}
```

The `permissions` map must include **every** permission the system supports (the same set you'd get from the list-permissions endpoint), each set explicitly to `true` or `false`. This is deliberate — if you only send the ones you want enabled, the request gets rejected, since we want it to always be unambiguous which permissions were considered and intentionally left off versus simply forgotten.

**Possible error:**

If a role with this name already exists at this store:
```json
{
  "status": 400,
  "message": "Validation Errors",
  "fields": [
    { "field": "name", "message": "A role with this name already exists at this store." }
  ]
}
```

## Editing a Role

`PATCH /store/:store_id/role/:role_id`

```json
{
  "name": "Cashier",
  "permissions": {
    "MANAGE_STAFF": false,
    "MANAGE_PRODUCT": true
  }
}
```

`name` is compulsory on every edit, even if you're not changing it — if the name should stay the same, just send the existing name back. Same rule applies to `permissions` as creation: every permission must be explicitly included.

**Possible errors:**

A staff member can't edit a role they currently hold (this prevents someone from accidentally revoking their own access):
```json
{
  "status": 403,
  "message": "You cannot edit a role you currently hold."
}
```

If the role doesn't exist:
```json
{
  "status": 404,
  "message": "This role does not exist."
}
```

If the new name collides with another role at this store:
```json
{
  "status": 400,
  "message": "Validation Errors",
  "fields": [
    { "field": "name", "message": "A role with this name already exists at this store." }
  ]
}
```

## Deleting a Role

`DELETE /store/:store_id/role/:role_id`

No body needed. Any staff currently assigned to this role will simply have their role cleared (back to no role) — they aren't suspended or dismissed, they just lose this specific role. If you want to warn the owner about this before they confirm, you'll need to fetch the role's members yourself first (via list roles with `show_staff=true`) — the backend doesn't hold the delete back for confirmation, it just deletes.

**Possible errors:**

A staff member can't delete a role they currently hold:
```json
{
  "status": 403,
  "message": "You cannot delete a role you currently hold."
}
```

If the role doesn't exist:
```json
{
  "status": 404,
  "message": "This role does not exist."
}
```

## Staff Profile

`GET /profile/staff`

Use this the same way you'd use the customer, rider, or store owner profile endpoints — call it after login to get the logged-in staff member's details.

```json
{
    "first_name": "Staff One",
    "last_name": "1",
    "email": "pamilerinoladoyin@gmail.com",
    "status": "ACTIVE",
    "role_id": null,
    "role_name": null,
    "store_id": "188f9e0c-3a36-4638-a7c0-8a3036ba2e1d",
    "store_name": "Twin Shop",
    "store_address": "Somewhere on earth",
    "store_picture": null,
    "store_institution": "BABCOCK_MAIN_CAMPUS"
}
```

`status` is the most important field here, and the frontend should branch on it:

If `status` is `"ACTIVE"`, everything's normal — show the dashboard as usual.

If `status` is `"SUSPENDED"`, the staff member has been temporarily suspended by the store. They can still log in and see this profile, but the dashboard should be greyed out so they know they can't take any actions right now (and if they somehow try anyway, the backend will reject it regardless of what the UI allows).

If the staff member has been **dismissed**, this endpoint won't return a profile at all — it returns an error instead:

```json
{
  "status": 403,
  "message": "You have been dismissed from your store and no longer have access."
}
```

Important: login itself still works for a dismissed staff member — there's no check at the login stage. The rejection only happens here, at the profile check. So the expected frontend flow is: staff logs in successfully, app immediately calls staff profile to populate the dashboard, and if this specific error comes back, treat it as a hard stop — kick them back to the login screen with a message that they've been dismissed from their store. Don't try to render any dashboard state for this case the way you would for suspended.