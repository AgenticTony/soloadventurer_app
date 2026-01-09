/// Budget range categories for travel planning
///
/// Used during onboarding to understand the user's spending preferences
/// and generate appropriate recommendations for accommodations, activities, and dining.
enum BudgetRange {
  /// Budget-friendly options (hostels, street food, free activities)
  budgetFriendly('Budget-Friendly', r'$', 'Economy options with great value'),

  /// Moderate budget (mid-range hotels, mix of casual and fine dining)
  moderate('Moderate', r'$$', 'Comfortable mid-range options'),

  /// Flexible budget (willing to spend for quality experiences)
  flexible('Flexible', r'$$$', 'Premium experiences when worth it');

  /// Human-readable display name
  final String label;

  /// Symbol representing the budget level
  final String symbol;

  /// Description of what this budget level includes
  final String description;

  /// Creates a BudgetRange with label, symbol, and description
  const BudgetRange(this.label, this.symbol, this.description);

  /// Returns a display-friendly string with symbol and label
  String get displayName => '$symbol $label';
}
