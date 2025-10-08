import 'package:flutter/material.dart';
import 'package:nimbus/services/checkout_service.dart';
import 'package:nimbus/models/payment_method.dart';
import 'package:nimbus/screens/order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;

  const CheckoutScreen({
    Key? key,
    required this.cartItems,
    required this.subtotal,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CheckoutService _checkoutService = CheckoutService();
  final _formKey = GlobalKey<FormState>();
  final _couponController = TextEditingController();
  
  int _currentStep = 0;
  bool _isProcessing = false;
  
  // Payment method
  PaymentMethod? _selectedPaymentMethod;
  
  // Billing address
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  String _selectedCountry = 'Thailand';
  
  // Coupon
  String? _appliedCoupon;
  double _discount = 0.0;
  bool _isCouponLoading = false;
  
  // Tax and shipping
  final double _taxRate = 0.07; // 7% tax
  final double _shippingFee = 5.99;
  
  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }
  
  @override
  void dispose() {
    _couponController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSavedAddress() async {
    // Load saved billing address from user profile
    final savedAddress = await _checkoutService.getSavedBillingAddress();
    if (savedAddress != null && mounted) {
      setState(() {
        _nameController.text = savedAddress['name'] ?? '';
        _emailController.text = savedAddress['email'] ?? '';
        _phoneController.text = savedAddress['phone'] ?? '';
        _addressController.text = savedAddress['address'] ?? '';
        _cityController.text = savedAddress['city'] ?? '';
        _zipController.text = savedAddress['zip'] ?? '';
        _selectedCountry = savedAddress['country'] ?? 'Thailand';
      });
    }
  }
  
  double get _totalBeforeDiscount => widget.subtotal + _shippingFee;
  double get _tax => (widget.subtotal - _discount) * _taxRate;
  double get _total => widget.subtotal + _shippingFee + _tax - _discount;
  
  Future<void> _applyCoupon() async {
    if (_couponController.text.isEmpty) return;
    
    setState(() => _isCouponLoading = true);
    
    try {
      final couponData = await _checkoutService.validateCoupon(
        _couponController.text.trim(),
        widget.subtotal,
      );
      
      if (couponData != null) {
        setState(() {
          _appliedCoupon = _couponController.text.trim();
          _discount = couponData['discount'];
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Coupon applied! \$${_discount.toStringAsFixed(2)} off'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isCouponLoading = false);
    }
  }
  
  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _discount = 0.0;
      _couponController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon removed'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      // Save billing address
      await _checkoutService.saveBillingAddress({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'zip': _zipController.text,
        'country': _selectedCountry,
      });
      
      // Process payment
      final orderId = await _checkoutService.processPayment(
        paymentMethod: _selectedPaymentMethod!,
        billingAddress: {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'zip': _zipController.text,
          'country': _selectedCountry,
        },
        cartItems: widget.cartItems,
        subtotal: widget.subtotal,
        tax: _tax,
        shipping: _shippingFee,
        discount: _discount,
        total: _total,
        couponCode: _appliedCoupon,
      );
      
      if (mounted) {
        // Navigate to order confirmation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(
              orderId: orderId,
              total: _total,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 0) ...[
                      _buildBillingAddressSection(),
                    ] else if (_currentStep == 1) ...[
                      _buildPaymentMethodSection(),
                    ] else ...[
                      _buildOrderReviewSection(),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom action bar
          _buildBottomActionBar(),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepIndicator(0, 'Address', Icons.location_on),
          _buildStepConnector(0),
          _buildStepIndicator(1, 'Payment', Icons.payment),
          _buildStepConnector(1),
          _buildStepIndicator(2, 'Review', Icons.receipt_long),
        ],
      ),
    );
  }
  
  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF64B5F6)
                  : Colors.grey[300],
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: const Color(0xFF64B5F6), width: 3)
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isActive ? const Color(0xFF64B5F6) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepConnector(int step) {
    final isActive = _currentStep > step;
    
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 30),
        color: isActive ? const Color(0xFF64B5F6) : Colors.grey[300],
      ),
    );
  }
  
  Widget _buildBillingAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Billing Address'),
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'John Doe',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'john@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: '+66 123 456 789',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _addressController,
          label: 'Street Address',
          hint: '123 Main Street',
          icon: Icons.home_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Bangkok',
                icon: Icons.location_city,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _zipController,
                label: 'ZIP Code',
                hint: '10110',
                icon: Icons.markunread_mailbox,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildCountryDropdown(),
      ],
    );
  }
  
  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Payment Method'),
        const SizedBox(height: 16),
        
        _buildPaymentOption(
          PaymentMethod.creditCard,
          'Credit/Debit Card',
          Icons.credit_card,
          'Visa, Mastercard, Amex',
        ),
        
        const SizedBox(height: 12),
        
        _buildPaymentOption(
          PaymentMethod.paypal,
          'PayPal',
          Icons.account_balance_wallet,
          'Pay with your PayPal account',
        ),
        
        const SizedBox(height: 12),
        
        _buildPaymentOption(
          PaymentMethod.bankTransfer,
          'Bank Transfer',
          Icons.account_balance,
          'Direct bank transfer',
        ),
        
        const SizedBox(height: 12),
        
        _buildPaymentOption(
          PaymentMethod.cashOnDelivery,
          'Cash on Delivery',
          Icons.local_shipping,
          'Pay when you receive',
        ),
        
        if (_selectedPaymentMethod == PaymentMethod.creditCard) ...[
          const SizedBox(height: 24),
          _buildCreditCardForm(),
        ],
      ],
    );
  }
  
  Widget _buildOrderReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Order Summary'),
        const SizedBox(height: 16),
        
        // Cart items
        _buildCartItemsList(),
        
        const SizedBox(height: 24),
        
        // Coupon code
        _buildCouponSection(),
        
        const SizedBox(height: 24),
        
        // Price breakdown
        _buildPriceBreakdown(),
        
        const SizedBox(height: 24),
        
        // Billing address summary
        _buildAddressSummary(),
        
        const SizedBox(height: 24),
        
        // Payment method summary
        _buildPaymentSummary(),
      ],
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34495E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF64B5F6)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF64B5F6),
                width: 2,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
  
  Widget _buildCountryDropdown() {
    final countries = ['Thailand', 'United States', 'United Kingdom', 'Japan', 'Singapore'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Country',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34495E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountry,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64B5F6)),
              items: countries.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCountry = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPaymentOption(
    PaymentMethod method,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedPaymentMethod == method;
    
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF64B5F6) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF64B5F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF64B5F6)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedPaymentMethod,
              activeColor: const Color(0xFF64B5F6),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPaymentMethod = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCreditCardForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Expiry',
                    hintText: 'MM/YY',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCartItemsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.cartItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          return ListTile(
            leading: Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(item['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              item['title'],
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('Qty: ${item['quantity']}'),
            trailing: Text(
              '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF64B5F6),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Have a coupon code?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_appliedCoupon == null) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      prefixIcon: const Icon(Icons.local_offer),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    textCapitalization: TextInputType.text as TextCapitalization,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isCouponLoading ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64B5F6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: _isCouponLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Apply'),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appliedCoupon!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Discount: \$${_discount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _removeCoupon,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', widget.subtotal),
          const SizedBox(height: 12),
          _buildPriceRow('Shipping', _shippingFee),
          const SizedBox(height: 12),
          _buildPriceRow('Tax (7%)', _tax),
          if (_discount > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow('Discount', -_discount, isDiscount: true),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64B5F6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceRow(String label, double amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '\$${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddressSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Billing Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_nameController.text),
          Text(_emailController.text),
          Text(_phoneController.text),
          Text(_addressController.text),
          Text('${_cityController.text}, ${_zipController.text}'),
          Text(_selectedCountry),
        ],
      ),
    );
  }
  
  Widget _buildPaymentSummary() {
    if (_selectedPaymentMethod == null) return const SizedBox.shrink();
    
    String methodName = '';
    IconData methodIcon = Icons.payment;
    
    switch (_selectedPaymentMethod!) {
      case PaymentMethod.creditCard:
        methodName = 'Credit/Debit Card';
        methodIcon = Icons.credit_card;
        break;
      case PaymentMethod.paypal:
        methodName = 'PayPal';
        methodIcon = Icons.account_balance_wallet;
        break;
      case PaymentMethod.bankTransfer:
        methodName = 'Bank Transfer';
        methodIcon = Icons.account_balance;
        break;
      case PaymentMethod.cashOnDelivery:
        methodName = 'Cash on Delivery';
        methodIcon = Icons.local_shipping;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF64B5F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(methodIcon, color: const Color(0xFF64B5F6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  methodName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _currentStep = 1),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF64B5F6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64B5F6),
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: _currentStep > 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () {
                  if (_currentStep < 2) {
                    if (_currentStep == 0 && !_formKey.currentState!.validate()) {
                      return;
                    }
                    setState(() => _currentStep++);
                  } else {
                    _processPayment();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF64B5F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        _currentStep < 2 ? 'Continue' : 'Place Order',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}