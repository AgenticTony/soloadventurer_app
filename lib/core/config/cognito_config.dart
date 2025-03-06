import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:soloadventurer/app/config/env.dart';

/// Configuration for AWS Cognito
class CognitoConfig {
  static final Env _env = Env();

  /// The User Pool ID from AWS Cognito
  static String get userPoolId => _env.cognitoUserPoolId;

  /// The Client ID from AWS Cognito
  static String get clientId => _env.cognitoClientId;

  /// The AWS Region where your Cognito User Pool is located
  static String get region => _env.awsRegion;

  /// The JWT signing key URL for token validation
  static String get jwksUrl =>
      'https://cognito-idp.$region.amazonaws.com/$userPoolId/.well-known/jwks.json';

  /// The Cognito service endpoint
  static String get cognitoEndpoint =>
      'https://cognito-idp.$region.amazonaws.com';

  /// ARN for the user pool
  static String get userPoolArn =>
      'arn:aws:cognito-idp:$region:198092179835:userpool/$userPoolId';

  /// Callback URL for authentication responses
  static const String callbackUrl = 'soloadventurer://callback';

  /// Sign out URL
  static const String signOutUrl = 'soloadventurer://signout';

  /// OAuth scopes requested by the app
  static const List<String> scopes = [
    'phone',
    'openid',
    'email',
    'profile',
    'aws.cognito.signin.user.admin'
  ];

  /// Authentication flow configuration
  static const List<String> explicitAuthFlows = [
    'ALLOW_USER_SRP_AUTH', // Secure Remote Password (recommended)
    'ALLOW_REFRESH_TOKEN_AUTH', // For token refresh
    'ALLOW_USER_PASSWORD_AUTH', // For direct username/password auth
  ];

  /// Authentication session duration in minutes
  static const int authSessionDuration = 3; // Match AWS Console setting

  /// Access token expiration in minutes
  static const int accessTokenDuration = 60;

  /// ID token expiration in minutes
  static const int idTokenDuration = 60;

  /// Refresh token expiration in days
  static const int refreshTokenDuration = 5;

  /// Maximum failed attempts before temporary lockout
  static const int maxFailedAttempts = 5;

  /// The Cognito User Pool instance with configured authentication flows
  static final CognitoUserPool userPool = CognitoUserPool(
    userPoolId,
    clientId,
    endpoint: cognitoEndpoint,
  );

  /// Identity Pool ID (Optional - only if you're using Identity Pools)
  static String get identityPoolId => _env.cognitoIdentityPoolId;

  /// Get the AWS region for the identity pool (same as user pool region)
  static String get identityPoolRegion => region;

  /// Get the Cognito identity pool configuration
  static CognitoCredentials get credentials => CognitoCredentials(
        identityPoolId,
        userPool,
        region: identityPoolRegion,
      );

  /// Get the OAuth configuration
  static Map<String, dynamic> get oAuthConfig => {
        'redirectUri': callbackUrl,
        'signOutUri': signOutUrl,
        'scopes': scopes,
      };

  /// Private constructor to prevent instantiation
  CognitoConfig._();
}
