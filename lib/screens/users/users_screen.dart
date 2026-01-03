import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/admin_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String? _selectedRole;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.desertSand,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search users...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) {
                              provider.fetchUsers(
                                role: _selectedRole,
                                search: value.isEmpty ? null : value,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: _selectedRole,
                          hint: const Text('All Roles'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Roles')),
                            const DropdownMenuItem(value: 'customer', child: Text('Customers')),
                            const DropdownMenuItem(value: 'restaurant', child: Text('Restaurants')),
                            const DropdownMenuItem(value: 'driver', child: Text('Drivers')),
                            const DropdownMenuItem(value: 'admin', child: Text('Admins')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedRole = value);
                            provider.fetchUsers(role: value, search: _searchController.text);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: provider.isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.nileBlue))
                    : provider.users.isEmpty
                        ? const Center(child: Text('No users found'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Phone')),
                                  DataColumn(label: Text('Role')),
                                  DataColumn(label: Text('Verified')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: provider.users.map((user) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(user['name'] ?? 'N/A')),
                                      DataCell(Text(user['email'] ?? 'N/A')),
                                      DataCell(Text(user['phone'] ?? 'N/A')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getRoleColor(user['role']),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            user['role']?.toUpperCase() ?? 'N/A',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Icon(
                                          user['isVerified'] == true
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: user['isVerified'] == true
                                              ? AppColors.palmGreen
                                              : AppColors.error,
                                          size: 20,
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (user['role'] == 'restaurant' &&
                                                user['isVerified'] != true)
                                              IconButton(
                                                icon: Icon(
                                                  Icons.verified,
                                                  color: AppColors.palmGreen,
                                                ),
                                                tooltip: 'Verify Restaurant',
                                                onPressed: () {
                                                  provider.verifyRestaurant(user['_id']);
                                                },
                                              ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: AppColors.error,
                                              ),
                                              tooltip: 'Delete User',
                                              onPressed: () {
                                                _showDeleteDialog(context, provider, user['_id']);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'customer':
        return AppColors.nileBlue;
      case 'restaurant':
        return AppColors.sunsetAmber;
      case 'driver':
        return AppColors.palmGreen;
      case 'admin':
        return AppColors.riverTeal;
      default:
        return AppColors.gray;
    }
  }

  void _showDeleteDialog(BuildContext context, AdminProvider provider, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteUser(userId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
