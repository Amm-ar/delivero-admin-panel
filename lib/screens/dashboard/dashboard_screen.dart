import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../users/users_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardTab(),
      const UsersScreen(),
      const AnalyticsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).fetchStats();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: screens[_selectedIndex]),
        ],
      ),
    );
  }
}

// Dashboard Tab
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppColors.nileBlue));
        }

        final stats = provider.stats;
        if (stats == null) {
          return const Center(child: Text('No data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Platform Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Stats grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1200 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        title: 'Total Orders',
                        value: '${stats['totalOrders'] ?? 0}',
                        icon: Icons.shopping_bag,
                        color: AppColors.nileBlue,
                        subtitle: 'All time',
                      ),
                      StatCard(
                        title: 'Total Revenue',
                        value: '${AppConstants.currencySymbol} ${(stats['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                        color: AppColors.palmGreen,
                        subtitle: 'Platform earnings',
                      ),
                      StatCard(
                        title: 'Active Restaurants',
                        value: '${stats['activeRestaurants'] ?? 0}',
                        icon: Icons.restaurant,
                        color: AppColors.sunsetAmber,
                        subtitle: 'Verified',
                      ),
                      StatCard(
                        title: 'Active Drivers',
                        value: '${stats['activeDrivers'] ?? 0}',
                        icon: Icons.delivery_dining,
                        color: AppColors.riverTeal,
                        subtitle: 'Online now',
                      ),
                      StatCard(
                        title: 'Total Customers',
                        value: '${stats['totalCustomers'] ?? 0}',
                        icon: Icons.people,
                        color: AppColors.nileBlue,
                        subtitle: 'Registered',
                      ),
                      StatCard(
                        title: 'Orders Today',
                        value: '${stats['ordersToday'] ?? 0}',
                        icon: Icons.today,
                        color: AppColors.palmGreen,
                        subtitle: DateFormat('MMM dd, yyyy').format(DateTime.now()),
                      ),
                      StatCard(
                        title: 'Avg Order Value',
                        value: '${AppConstants.currencySymbol} ${(stats['averageOrderValue'] ?? 0).toStringAsFixed(2)}',
                        icon: Icons.trending_up,
                        color: AppColors.sunsetAmber,
                        subtitle: 'Per order',
                      ),
                      StatCard(
                        title: 'Commission Rate',
                        value: '20%',
                        icon: Icons.percent,
                        color: AppColors.riverTeal,
                        subtitle: 'From restaurants',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Analytics Tab
class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 80, color: AppColors.gray),
          const SizedBox(height: 16),
          Text(
            'Revenue Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 8),
          Text(
            'Charts and detailed analytics coming soon',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
          ),
        ],
      ),
    );
  }
}

// Stat Card Widget
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.caption?.copyWith(
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
