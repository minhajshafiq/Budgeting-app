enum TransactionPeriod {
  past,    // Transactions antérieures au jour actuel
  today,   // Transactions du jour actuel
  future,  // Transactions postérieures au jour actuel
}

extension TransactionPeriodExtension on TransactionPeriod {
  String get displayName {
    switch (this) {
      case TransactionPeriod.past:
        return 'Passé';
      case TransactionPeriod.today:
        return 'En cours';
      case TransactionPeriod.future:
        return 'Planifié';
    }
  }

  String get description {
    switch (this) {
      case TransactionPeriod.past:
        return 'Transactions antérieures à aujourd\'hui';
      case TransactionPeriod.today:
        return 'Transactions d\'aujourd\'hui';
      case TransactionPeriod.future:
        return 'Transactions postérieures à aujourd\'hui';
    }
  }
} 