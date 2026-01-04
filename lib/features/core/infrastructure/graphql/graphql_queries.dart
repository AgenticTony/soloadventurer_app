class GraphQLQueries {
  // User queries
  static String getUserProfile = '''
    query GetUserProfile(\$userId: ID!) {
      getUserProfile(userId: \$userId) {
        id
        username
        email
        firstName
        lastName
        profilePictureUrl
        createdAt
        updatedAt
      }
    }
  ''';

  static String updateUserProfile = '''
    mutation UpdateUserProfile(
      \$userId: ID!
      \$firstName: String
      \$lastName: String
      \$profilePictureUrl: String
    ) {
      updateUserProfile(
        userId: \$userId
        firstName: \$firstName
        lastName: \$lastName
        profilePictureUrl: \$profilePictureUrl
      ) {
        id
        username
        email
        firstName
        lastName
        profilePictureUrl
        createdAt
        updatedAt
      }
    }
  ''';

  // Travel Preferences queries
  static String getTravelPreference = '''
    query GetTravelPreference(\$userId: ID!) {
      getTravelPreference(userId: \$userId) {
        id
        userId
        travelStyles
        accommodationTypes
        transportationTypes
        minBudget
        maxBudget
        minTripDuration
        maxTripDuration
        preferredDestinations
        avoidDestinations
        isFlexibleDates
        createdAt
        updatedAt
      }
    }
  ''';

  static String createTravelPreference = '''
    mutation CreateTravelPreference(
      \$userId: ID!
      \$travelStyles: [String!]!
      \$accommodationTypes: [String!]!
      \$transportationTypes: [String!]!
      \$minBudget: Int!
      \$maxBudget: Int!
      \$minTripDuration: Int!
      \$maxTripDuration: Int!
      \$preferredDestinations: [String!]!
      \$avoidDestinations: [String!]!
      \$isFlexibleDates: Boolean!
    ) {
      createTravelPreference(
        userId: \$userId
        travelStyles: \$travelStyles
        accommodationTypes: \$accommodationTypes
        transportationTypes: \$transportationTypes
        minBudget: \$minBudget
        maxBudget: \$maxBudget
        minTripDuration: \$minTripDuration
        maxTripDuration: \$maxTripDuration
        preferredDestinations: \$preferredDestinations
        avoidDestinations: \$avoidDestinations
        isFlexibleDates: \$isFlexibleDates
      ) {
        id
        userId
        travelStyles
        accommodationTypes
        transportationTypes
        minBudget
        maxBudget
        minTripDuration
        maxTripDuration
        preferredDestinations
        avoidDestinations
        isFlexibleDates
        createdAt
        updatedAt
      }
    }
  ''';

  static String updateTravelPreference = '''
    mutation UpdateTravelPreference(
      \$id: ID!
      \$travelStyles: [String!]
      \$accommodationTypes: [String!]
      \$transportationTypes: [String!]
      \$minBudget: Int
      \$maxBudget: Int
      \$minTripDuration: Int
      \$maxTripDuration: Int
      \$preferredDestinations: [String!]
      \$avoidDestinations: [String!]
      \$isFlexibleDates: Boolean
    ) {
      updateTravelPreference(
        id: \$id
        travelStyles: \$travelStyles
        accommodationTypes: \$accommodationTypes
        transportationTypes: \$transportationTypes
        minBudget: \$minBudget
        maxBudget: \$maxBudget
        minTripDuration: \$minTripDuration
        maxTripDuration: \$maxTripDuration
        preferredDestinations: \$preferredDestinations
        avoidDestinations: \$avoidDestinations
        isFlexibleDates: \$isFlexibleDates
      ) {
        id
        userId
        travelStyles
        accommodationTypes
        transportationTypes
        minBudget
        maxBudget
        minTripDuration
        maxTripDuration
        preferredDestinations
        avoidDestinations
        isFlexibleDates
        createdAt
        updatedAt
      }
    }
  ''';

  // Trip queries
  static String getTrips = '''
    query GetTrips(\$userId: ID!) {
      getTrips(userId: \$userId) {
        id
        userId
        title
        description
        startDate
        endDate
        destination
        latitude
        longitude
        status
        budget
        coverImageUrl
        travelCompanionIds
        createdAt
        updatedAt
      }
    }
  ''';

  static String getTrip = '''
    query GetTrip(\$id: ID!) {
      getTrip(id: \$id) {
        id
        userId
        title
        description
        startDate
        endDate
        destination
        latitude
        longitude
        status
        budget
        coverImageUrl
        travelCompanionIds
        createdAt
        updatedAt
      }
    }
  ''';

  static String createTrip = '''
    mutation CreateTrip(
      \$userId: ID!
      \$title: String!
      \$description: String
      \$startDate: String!
      \$endDate: String!
      \$destination: String!
      \$latitude: Float
      \$longitude: Float
      \$status: String!
      \$budget: Int!
      \$coverImageUrl: String
      \$travelCompanionIds: [String!]
    ) {
      createTrip(
        userId: \$userId
        title: \$title
        description: \$description
        startDate: \$startDate
        endDate: \$endDate
        destination: \$destination
        latitude: \$latitude
        longitude: \$longitude
        status: \$status
        budget: \$budget
        coverImageUrl: \$coverImageUrl
        travelCompanionIds: \$travelCompanionIds
      ) {
        id
        userId
        title
        description
        startDate
        endDate
        destination
        latitude
        longitude
        status
        budget
        coverImageUrl
        travelCompanionIds
        createdAt
        updatedAt
      }
    }
  ''';

  static String updateTrip = '''
    mutation UpdateTrip(
      \$id: ID!
      \$title: String
      \$description: String
      \$startDate: String
      \$endDate: String
      \$destination: String
      \$latitude: Float
      \$longitude: Float
      \$status: String
      \$budget: Int
      \$coverImageUrl: String
      \$travelCompanionIds: [String!]
    ) {
      updateTrip(
        id: \$id
        title: \$title
        description: \$description
        startDate: \$startDate
        endDate: \$endDate
        destination: \$destination
        latitude: \$latitude
        longitude: \$longitude
        status: \$status
        budget: \$budget
        coverImageUrl: \$coverImageUrl
        travelCompanionIds: \$travelCompanionIds
      ) {
        id
        userId
        title
        description
        startDate
        endDate
        destination
        latitude
        longitude
        status
        budget
        coverImageUrl
        travelCompanionIds
        createdAt
        updatedAt
      }
    }
  ''';

  static String deleteTrip = '''
    mutation DeleteTrip(\$id: ID!) {
      deleteTrip(id: \$id) {
        id
        success
      }
    }
  ''';

  // Incremental sync queries with 'since' parameter
  static String getTripsIncremental = '''
    query GetTripsIncremental(\$userId: ID!, \$since: DateTime!) {
      getTripsIncremental(userId: \$userId, since: \$since) {
        id
        userId
        title
        description
        startDate
        endDate
        destination
        latitude
        longitude
        status
        budget
        coverImageUrl
        travelCompanionIds
        createdAt
        updatedAt
      }
    }
  ''';

  static String getJournalsIncremental = '''
    query GetJournalsIncremental(\$tripId: ID!, \$since: DateTime!) {
      getJournalsIncremental(tripId: \$tripId, since: \$since) {
        id
        tripId
        userId
        title
        content
        entryDate
        mood
        location
        imageUrls
        tags
        createdAt
        updatedAt
      }
    }
  ''';

  static String getUserProfileIncremental = '''
    query GetUserProfileIncremental(\$userId: ID!, \$since: DateTime!) {
      getUserProfileIncremental(userId: \$userId, since: \$since) {
        id
        username
        email
        firstName
        lastName
        profilePictureUrl
        createdAt
        updatedAt
      }
    }
  ''';
}
