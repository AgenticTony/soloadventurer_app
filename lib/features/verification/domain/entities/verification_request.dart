import 'package:equatable/equatable.dart';
import '../enums/verification_status.dart';
import '../enums/verification_type.dart';

/// Represents a verification request submitted by a user
class VerificationRequest extends Equatable {
  /// Creates a new [VerificationRequest]
  const VerificationRequest({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    this.imageUrl,
    this.documentFrontUrl,
    this.documentBackUrl,
    this.providerRef,
    this.failureReason,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  /// The unique identifier of this verification request
  final String id;

  /// The user who submitted the verification
  final String userId;

  /// The type of verification
  final VerificationType type;

  /// Current status of the verification
  final VerificationStatus status;

  /// URL of the selfie/photo for photo verification
  final String? imageUrl;

  /// URL of the front of the ID document
  final String? documentFrontUrl;

  /// URL of the back of the ID document
  final String? documentBackUrl;

  /// Reference ID from the verification provider (Onfido, etc.)
  final String? providerRef;

  /// Reason for failure if status is failed
  final String? failureReason;

  /// When the request was created
  final DateTime createdAt;

  /// When the request was last updated
  final DateTime? updatedAt;

  /// When this verification expires
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        status,
        imageUrl,
        documentFrontUrl,
        documentBackUrl,
        providerRef,
        failureReason,
        createdAt,
        updatedAt,
        expiresAt,
      ];

  /// Creates a copy with updated fields
  VerificationRequest copyWith({
    String? id,
    String? userId,
    VerificationType? type,
    VerificationStatus? status,
    String? imageUrl,
    String? documentFrontUrl,
    String? documentBackUrl,
    String? providerRef,
    String? failureReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      documentFrontUrl: documentFrontUrl ?? this.documentFrontUrl,
      documentBackUrl: documentBackUrl ?? this.documentBackUrl,
      providerRef: providerRef ?? this.providerRef,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
