/// GraphQL queries and mutations for destination discovery feature
///
/// This class contains all GraphQL documents needed for destination data operations
/// including search, retrieval, recommendations, curated lists, and saved destinations.
class DestinationQueries {
  // Query: Search destinations with filters
  static const String searchDestinations = r'''
    query SearchDestinations(
      $searchQuery: String
      $budgetLevel: BudgetLevel
      $minSafetyScore: Float
      $minSoloSuitabilityScore: Float
      $activityLevel: ActivityLevel
      $countryCode: String
      $region: String
      $tags: [String!]
      $hiddenGemsOnly: Boolean
      $minPopularityScore: Float
      $maxDailyCost: Int
      $sortBy: DestinationSortOrder
      $offset: Int
      $limit: Int
    ) {
      searchDestinations(
        searchQuery: $searchQuery
        budgetLevel: $budgetLevel
        minSafetyScore: $minSafetyScore
        minSoloSuitabilityScore: $minSoloSuitabilityScore
        activityLevel: $activityLevel
        countryCode: $countryCode
        region: $region
        tags: $tags
        hiddenGemsOnly: $hiddenGemsOnly
        minPopularityScore: $minPopularityScore
        maxDailyCost: $maxDailyCost
        sortBy: $sortBy
        offset: $offset
        limit: $limit
      ) {
        id
        name
        description
        latitude
        longitude
        countryCode
        region
        safetyScore
        safetyInsights {
          category
          description
          severity
          tips
        }
        soloSuitabilityScore
        soloSuitabilityFactors {
          safety
          nightlife
          walkability
          accommodation
          soloDining
          communication
          overall
        }
        budgetLevel
        activityLevels
        tags
        images
        coverImageUrl
        popularActivities {
          id
          name
          description
          category
          soloFriendly
          costLevel
          imageUrl
        }
        bestTimeToVisit
        averageDailyCost
        currencyCode
        language
        timezone
        isHiddenGem
        popularityScore
        createdAt
        updatedAt
      }
    }
  ''';

  // Query: Get destination by ID
  static const String getDestinationById = r'''
    query GetDestinationById($id: ID!) {
      getDestinationById(id: $id) {
        id
        name
        description
        latitude
        longitude
        countryCode
        region
        safetyScore
        safetyInsights {
          category
          description
          severity
          tips
        }
        soloSuitabilityScore
        soloSuitabilityFactors {
          safety
          nightlife
          walkability
          accommodation
          soloDining
          communication
          overall
        }
        budgetLevel
        activityLevels
        tags
        images
        coverImageUrl
        popularActivities {
          id
          name
          description
          category
          soloFriendly
          costLevel
          imageUrl
        }
        bestTimeToVisit
        averageDailyCost
        currencyCode
        language
        timezone
        isHiddenGem
        popularityScore
        createdAt
        updatedAt
      }
    }
  ''';

  // Query: Get personalized recommendations
  static const String getPersonalizedRecommendations = r'''
    query GetPersonalizedRecommendations($userId: ID!) {
      getPersonalizedRecommendations(userId: $userId) {
        id
        userId
        recommendations {
          destination {
            id
            name
            description
            latitude
            longitude
            countryCode
            region
            safetyScore
            safetyInsights {
              category
              description
              severity
              tips
            }
            soloSuitabilityScore
            soloSuitabilityFactors {
              safety
              nightlife
              walkability
              accommodation
              soloDining
              communication
              overall
            }
            budgetLevel
            activityLevels
            tags
            images
            coverImageUrl
            popularActivities {
              id
              name
              description
              category
              soloFriendly
              costLevel
              imageUrl
            }
            bestTimeToVisit
            averageDailyCost
            currencyCode
            language
            timezone
            isHiddenGem
            popularityScore
            createdAt
            updatedAt
          }
          matchScore
          reason
          matchingFactors
          isHiddenGemMatch
        }
        source
        summary
        totalCount
        generatedAt
        expiresAt
        preferenceSnapshot
        relatedRecommendationIds
      }
    }
  ''';

  // Query: Get all curated lists
  static const String getCuratedLists = r'''
    query GetCuratedLists {
      getCuratedLists {
        id
        name
        description
        type
        destinations {
          id
          name
          description
          latitude
          longitude
          countryCode
          region
          safetyScore
          soloSuitabilityScore
          soloSuitabilityFactors {
            safety
            nightlife
            walkability
            accommodation
            soloDining
            communication
            overall
          }
          budgetLevel
          activityLevels
          tags
          images
          coverImageUrl
          bestTimeToVisit
          averageDailyCost
          isHiddenGem
          popularityScore
          createdAt
          updatedAt
        }
        coverImageUrl
        images
        curatorName
        curatorImageUrl
        destinationCount
        isFeatured
        displayOrder
        tags
        averageSafetyScore
        averageSoloSuitabilityScore
        budgetRange
        bestTimeToVisit
        recommendedDuration
        viewCount
        saveCount
        createdAt
        updatedAt
        publishedAt
        isPublished
      }
    }
  ''';

  // Query: Get curated list by ID
  static const String getCuratedListById = r'''
    query GetCuratedListById($id: ID!) {
      getCuratedListById(id: $id) {
        id
        name
        description
        type
        destinations {
          id
          name
          description
          latitude
          longitude
          countryCode
          region
          safetyScore
          safetyInsights {
            category
            description
            severity
            tips
          }
          soloSuitabilityScore
          soloSuitabilityFactors {
            safety
            nightlife
            walkability
            accommodation
            soloDining
            communication
            overall
          }
          budgetLevel
          activityLevels
          tags
          images
          coverImageUrl
          popularActivities {
            id
            name
            description
            category
            soloFriendly
            costLevel
            imageUrl
          }
          bestTimeToVisit
          averageDailyCost
          currencyCode
          language
          timezone
          isHiddenGem
          popularityScore
          createdAt
          updatedAt
        }
        coverImageUrl
        images
        curatorName
        curatorImageUrl
        destinationCount
        isFeatured
        displayOrder
        tags
        averageSafetyScore
        averageSoloSuitabilityScore
        budgetRange
        bestTimeToVisit
        recommendedDuration
        viewCount
        saveCount
        createdAt
        updatedAt
        publishedAt
        isPublished
      }
    }
  ''';

  // Mutation: Save destination
  static const String saveDestination = r'''
    mutation SaveDestination(
      $userId: ID!
      $destinationId: ID!
      $saveType: SaveType!
      $tripId: ID
      $notes: String
    ) {
      saveDestination(
        userId: $userId
        destinationId: $destinationId
        saveType: $saveType
        tripId: $tripId
        notes: $notes
      ) {
        id
        userId
        destination {
          id
          name
          description
          latitude
          longitude
          countryCode
          region
          safetyScore
          soloSuitabilityScore
          soloSuitabilityFactors {
            safety
            nightlife
            walkability
            accommodation
            soloDining
            communication
            overall
          }
          budgetLevel
          activityLevels
          tags
          images
          coverImageUrl
          bestTimeToVisit
          averageDailyCost
          isHiddenGem
          popularityScore
          createdAt
          updatedAt
        }
        saveType
        tripId
        notes
        createdAt
        updatedAt
      }
    }
  ''';

  // Mutation: Unsave destination
  static const String unsaveDestination = r'''
    mutation UnsaveDestination(
      $destinationId: ID!
      $userId: ID!
      $saveType: SaveType
    ) {
      unsaveDestination(
        destinationId: $destinationId
        userId: $userId
        saveType: $saveType
      ) {
        success
        message
      }
    }
  ''';

  // Query: Get saved destinations
  static const String getSavedDestinations = r'''
    query GetSavedDestinations(
      $userId: ID!
      $saveType: SaveType
    ) {
      getSavedDestinations(
        userId: $userId
        saveType: $saveType
      ) {
        id
        userId
        destination {
          id
          name
          description
          latitude
          longitude
          countryCode
          region
          safetyScore
          soloSuitabilityScore
          soloSuitabilityFactors {
            safety
            nightlife
            walkability
            accommodation
            soloDining
            communication
            overall
          }
          budgetLevel
          activityLevels
          tags
          images
          coverImageUrl
          bestTimeToVisit
          averageDailyCost
          isHiddenGem
          popularityScore
          createdAt
          updatedAt
        }
        saveType
        tripId
        notes
        createdAt
        updatedAt
      }
    }
  ''';
}
