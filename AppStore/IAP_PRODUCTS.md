# In-App Purchase Setup

App Store Connect must contain the same products as the local StoreKit configuration and `fastlane/iap_products.json`.

## Subscription Group

| Field | Value |
|---|---|
| Reference name | Music Teacher Studio Pro |
| Display name | 樂課管家 Pro |

## Products

| Product ID | Type | Reference name | Display name | Price | Review status target |
|---|---|---|---|---|---|
| `studio.pro.monthly` | Auto-renewable subscription | Pro Monthly | Pro 月訂閱 | TWD 120 | Ready to Submit |
| `studio.pro.yearly` | Auto-renewable subscription | Pro Yearly | Pro 年訂閱 | TWD 990 | Ready to Submit |
| `studio.pro.lifetime` | Non-consumable | Pro Lifetime | 樂課管家 Pro 終身版 | TWD 2490 | Ready to Submit |

Current App Store Connect IDs:

| Product ID | ASC ID | Current ASC state |
|---|---:|---|
| `studio.pro.monthly` | `6772977179` | `MISSING_METADATA` |
| `studio.pro.yearly` | `6772977265` | `MISSING_METADATA` |
| `studio.pro.lifetime` | `6772977405` | `MISSING_METADATA` |

Monthly includes a 7-day free trial. Yearly has no introductory offer. Lifetime is one-time purchase and must not be placed inside the subscription group.

## Review Checks

- Attach all three IAPs to app version `1.0` before submitting the app.
- Confirm the IAP display names and descriptions are public-audience safe.
- Confirm restore purchases is visible in Settings and on the paywall.
- Confirm App Review notes mention no login is required and list all product IDs.
- Confirm the screenshot set includes the paywall or Settings screen so paid features are obvious.
