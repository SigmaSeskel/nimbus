enum PaymentMethod {
  creditCard,
  paypal,
  bankTransfer,
  cashOnDelivery,
}

extension PaymentMethodExtension on PaymentMethod {
  String get name {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Credit/Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
    }
  }
  
  String get description {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Visa, Mastercard, Amex';
      case PaymentMethod.paypal:
        return 'Pay with your PayPal account';
      case PaymentMethod.bankTransfer:
        return 'Direct bank transfer';
      case PaymentMethod.cashOnDelivery:
        return 'Pay when you receive';
    }
  }
}