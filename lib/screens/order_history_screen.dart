import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedFilter = 'All';

  // Sample orders data
  final List<Map<String, dynamic>> _orders = [
    {
      'orderId': 'ORD-2024-001',
      'date': '2024-01-15',
      'status': 'Delivered',
      'total': 42.97,
      'itemCount': 3,
      'books': [
        {
          'title': 'The Great Gatsby',
          'author': 'F. Scott Fitzgerald',
          'price': 9.99,
          'image': 'https://via.placeholder.com/80x110/64B5F6/FFFFFF?text=Book+1',
        },
        {
          'title': '1984',
          'author': 'George Orwell',
          'price': 10.99,
          'image': 'https://via.placeholder.com/80x110/FF6B6B/FFFFFF?text=Book+2',
        },
        {
          'title': 'Atomic Habits',
          'author': 'James Clear',
          'price': 13.99,
          'image': 'https://via.placeholder.com/80x110/42A5F5/FFFFFF?text=Book+3',
        },
      ],
    },
    {
      'orderId': 'ORD-2024-002',
      'date': '2024-01-10',
      'status': 'Processing',
      'total': 28.98,
      'itemCount': 2,
      'books': [
        {
          'title': 'Sapiens',
          'author': 'Yuval Noah Harari',
          'price': 15.99,
          'image': 'https://via.placeholder.com/80x110/FFA726/FFFFFF?text=Book+4',
        },
        {
          'title': 'The Lean Startup',
          'author': 'Eric Ries',
          'price': 14.99,
          'image': 'https://via.placeholder.com/80x110/AB47BC/FFFFFF?text=Book+5',
        },
      ],
    },
    {
      'orderId': 'ORD-2024-003',
      'date': '2024-01-05',
      'status': 'Delivered',
      'total': 12.99,
      'itemCount': 1,
      'books': [
        {
          'title': 'To Kill a Mockingbird',
          'author': 'Harper Lee',
          'price': 12.99,
          'image': 'https://via.placeholder.com/80x110/81C784/FFFFFF?text=Book+6',
        },
      ],
    },
    {
      'orderId': 'ORD-2023-004',
      'date': '2023-12-28',
      'status': 'Cancelled',
      'total': 16.99,
      'itemCount': 1,
      'books': [
        {
          'title': 'Thinking, Fast and Slow',
          'author': 'Daniel Kahneman',
          'price': 16.99,
          'image': 'https://via.placeholder.com/80x110/FF8A65/FFFFFF?text=Book+7',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> _getFilteredOrders() {
    if (_selectedFilter == 'All') {
      return _orders;
    }
    return _orders.where((order) => order['status'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Processing':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Delivered':
        return Icons.check_circle;
      case 'Processing':
        return Icons.access_time;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Order Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(order['status']),
                            size: 16,
                            color: _getStatusColor(order['status']),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order['status'],
                            style: TextStyle(
                              color: _getStatusColor(order['status']),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Order Info
                _buildInfoRow('Order ID', order['orderId']),
                _buildInfoRow('Order Date', order['date']),
                _buildInfoRow('Total Items', '${order['itemCount']}'),
                _buildInfoRow('Total Amount', '\$${order['total'].toStringAsFixed(2)}'),

                const SizedBox(height: 24),

                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(height: 12),

                // Order Items
                ...List.generate(
                  order['books'].length,
                  (index) => _buildOrderItem(order['books'][index]),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                if (order['status'] == 'Delivered') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _reorder(order);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reorder'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64B5F6),
                        side: const BorderSide(color: Color(0xFF64B5F6), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _downloadReceipt(order);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Receipt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64B5F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(book['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book['author'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${book['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64B5F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _reorder(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('${order['itemCount']} items added to cart'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _downloadReceipt(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Receipt for ${order['orderId']} downloaded'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text(
          'Order History',
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
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['All', 'Delivered', 'Processing', 'Cancelled'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: const Color(0xFF64B5F6).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF64B5F6) : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF64B5F6) : Colors.transparent,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? 'Start shopping to see your orders here'
                : 'No $_selectedFilter orders',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return GestureDetector(
      onTap: () => _showOrderDetails(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['orderId'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(order['status']),
                        size: 14,
                        color: _getStatusColor(order['status']),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        order['status'],
                        style: TextStyle(
                          color: _getStatusColor(order['status']),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Book Previews
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: order['books'].length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(order['books'][index]['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Order Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order['itemCount']} ${order['itemCount'] == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '\$${order['total'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64B5F6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}