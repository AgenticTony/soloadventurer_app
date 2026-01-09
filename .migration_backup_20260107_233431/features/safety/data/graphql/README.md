# Safety Feature GraphQL Operations

This directory contains GraphQL queries and mutations for the Safety Check-in & Location Sharing feature.

## Directory Structure

```
graphql/
├── mutations/          # GraphQL mutations for data modifications
│   ├── add_trusted_contact_mutation.graphql
│   ├── complete_check_in.graphql
│   ├── create_check_in.graphql
│   ├── trigger_sos.graphql
│   └── update_safety_status.graphql
└── queries/            # GraphQL queries for data retrieval
    ├── get_check_ins.graphql
    ├── get_trusted_contact.graphql
    ├── get_trusted_contacts.graphql
    └── get_upcoming_check_ins.graphql
```

## Mutations

### AddTrustedContact
Adds a new trusted contact for the user.

**File:** `mutations/add_trusted_contact_mutation.graphql`

**Variables:**
- `name` (String!): Contact name
- `email` (String): Contact email address
- `phoneNumber` (String): Contact phone number
- `contactSource` (String!): Source of contact (e.g., "phone", "community")
- `notificationPreference` (String!): Notification preferences (e.g., "all")

### CompleteCheckIn
Marks a scheduled check-in as completed with location information.

**File:** `mutations/complete_check_in.graphql`

**Variables:**
- `checkInId` (ID!): ID of the check-in to complete
- `location` (LocationInput!): Current location
- `statusMessage` (String): Optional status message

### CreateCheckIn
Creates a new check-in (manual or scheduled).

**File:** `mutations/create_check_in.graphql`

**Variables:**
- `userId` (ID!): User ID
- `scheduledTime` (String!): ISO 8601 datetime for scheduled check-in
- `deadline` (String): Optional deadline for check-in
- `location` (LocationInput): Optional location
- `statusMessage` (String): Optional status message
- `notifyContactIds` ([String!]): List of contact IDs to notify
- `tripId` (String): Optional associated trip ID
- `triggerType` (String): Type of trigger (manual, scheduled, location_based)

### TriggerEmergencySOS
Triggers an emergency SOS alert to all trusted contacts.

**File:** `mutations/trigger_sos.graphql`

**Variables:**
- `userId` (ID!): User ID
- `message` (String): Optional emergency message
- `location` (SafetyAlertLocationInput!): Current location
- `notifyContactIds` ([String!]!): List of contact IDs to notify
- `batteryLevel` (Int): Optional battery level percentage
- `tripId` (String): Optional associated trip ID

### UpdateSafetyStatus
Updates the user's current safety status.

**File:** `mutations/update_safety_status.graphql`

**Variables:**
- `status` (String!): Safety status (safe, need_help, emergency)
- `message` (String): Optional status message
- `location` (SafetyStatusLocationInput): Optional location
- `batteryLevel` (Int): Optional battery level
- `safetyAlertId` (String): Optional associated safety alert ID
- `checkInId` (String): Optional associated check-in ID

## Queries

### GetCheckIns
Retrieves all check-ins for the current user.

**File:** `queries/get_check_ins.graphql`

**Returns:** List of check-ins with full details including location, status, and timestamps.

### GetTrustedContact
Retrieves a specific trusted contact by ID.

**File:** `queries/get_trusted_contact.graphql`

**Variables:**
- `contactId` (ID!): ID of the contact to retrieve

### GetTrustedContacts
Retrieves all trusted contacts for the current user.

**File:** `queries/get_trusted_contacts.graphql`

**Returns:** List of trusted contacts with their notification preferences.

### GetUpcomingCheckIns
Retrieves all upcoming (not yet completed) check-ins.

**File:** `queries/get_upcoming_check_ins.graphql`

**Returns:** List of upcoming check-ins sorted by scheduled time.

## Usage Example

```dart
// Example: Using a mutation
final mutation = gql('''
  mutation AddTrustedContact(
    \$name: String!
    \$email: String
    \$phoneNumber: String
    \$contactSource: String!
    \$notificationPreference: String!
  ) {
    addTrustedContact(
      name: \$name
      email: \$email
      phoneNumber: \$phoneNumber
      contactSource: \$contactSource
      notificationPreference: \$notificationPreference
    ) {
      id
      userId
      name
      email
      phoneNumber
      contactSource
      receivesCheckInNotifications
      receivesEmergencyAlerts
      receivesLocationUpdates
      createdAt
      updatedAt
    }
  }
''');

final result = await client.mutate(
  MutationOptions(
    document: mutation,
    variables: {
      'name': 'John Doe',
      'email': 'john@example.com',
      'phoneNumber': '+1234567890',
      'contactSource': 'phone',
      'notificationPreference': 'all',
    },
  ),
);
```

## Notes

- All mutations and queries follow the existing patterns in `safety_remote_data_source_impl.dart`
- Input types like `LocationInput`, `SafetyAlertLocationInput`, and `SafetyStatusLocationInput` should be defined in your GraphQL schema
- DateTime fields should be formatted as ISO 8601 strings
- Enum values (status, triggerType, etc.) are passed as lowercase strings corresponding to the enum names
