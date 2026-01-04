import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/admin_provider.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchUsers(role: 'restaurant');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).fetchUsers(role: 'restaurant');
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.nileBlue));
          }

          final restaurants = provider.users;
          if (restaurants.isEmpty) {
            return const Center(child: Text('No restaurants found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final user = restaurants[index];
              final restaurant = user['restaurantProfile'];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(restaurant?['name'] ?? user['name'] ?? 'Unknown Restaurant'),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusBadge(restaurant?['isVerified'] ?? false),
                      const SizedBox(width: 8),
                      if (!(restaurant?['isVerified'] ?? false))
                        ElevatedButton(
                          onPressed: () => _showVerifyDialog(user['_id'], restaurant?['_id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.palmGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('Verify'),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified ? AppColors.palmGreen.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isVerified ? 'Verified' : 'Unverified',
        style: TextStyle(
          color: isVerified ? AppColors.palmGreen : AppColors.error,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showVerifyDialog(String userId, String? restaurantId) {
    if (restaurantId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Restaurant'),
        content: const Text('Are you sure you want to verify this restaurant? This will allow them to receive orders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).verifyRestaurant(restaurantId);
              Navigator.pop(context);
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}
