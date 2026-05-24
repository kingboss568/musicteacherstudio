# App Privacy Details

Use this as the App Store Connect App Privacy answer set for version `1.0`.

## Data Collection

Answer: `Data Not Collected`

Rationale: The app has no backend server, account system, analytics SDK, advertising SDK, tracking SDK, or external AI service. Student, parent, lesson, payment, assignment, recording, and report data stays in the local app sandbox unless the user manually exports or shares a PDF/CSV file.

## Tracking

Answer: `No`

- No IDFA.
- No cross-app or cross-site tracking.
- No third-party advertising.

## Purchases

In-app purchases are handled by Apple StoreKit. The app reads entitlement status to unlock Pro features, but it does not receive or store payment card details, Apple ID, or billing identity.

## Permissions

The app does not request Contacts, Location, Camera, Microphone, Calendar, Health, or Tracking permissions in version `1.0`.

The file picker/share sheet is used only when the teacher chooses to import a recording or export/share PDF/CSV files.
