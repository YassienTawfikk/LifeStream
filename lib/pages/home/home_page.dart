import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/models/index.dart';
import 'package:life_stream/providers/auth_provider.dart';
import 'package:life_stream/widgets/index.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Item> mockItems = [
    Item(
      id: '1',
      title: 'Beautiful Sunset',
      description: 'A stunning sunset view from the mountains',
      rating: 4.5,
      views: 1200,
      createdAt: DateTime.now(),
      category: 'Nature',
      imageUrl: 'https://via.placeholder.com/300x200?text=Sunset',
    ),
    Item(
      id: '2',
      title: 'Urban Photography',
      description: 'Modern city life captured in a frame',
      rating: 4.8,
      views: 2500,
      createdAt: DateTime.now(),
      category: 'City',
      imageUrl: 'https://via.placeholder.com/300x200?text=City',
    ),
    Item(
      id: '3',
      title: 'Forest Adventure',
      description: 'Exploring the hidden trails of nature',
      rating: 4.2,
      views: 890,
      createdAt: DateTime.now(),
      category: 'Adventure',
      imageUrl: 'https://via.placeholder.com/300x200?text=Forest',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${user?.name ?? 'User'}!',
          style: AppTextStyles.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Section
            Text(
              'Featured',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: mockItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ItemCard(
                      title: mockItems[index].title,
                      description: mockItems[index].description,
                      imageUrl: mockItems[index].imageUrl,
                      rating: mockItems[index].rating,
                      onTap: () => context.push('/detail/${mockItems[index].id}'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/list'),
                    child: AppCard(
                      child: Column(
                        children: [
                          Icon(
                            Icons.grid_view,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Browse',
                            style: AppTextStyles.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/search'),
                    child: AppCard(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Search',
                            style: AppTextStyles.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Items',
                  style: AppTextStyles.headlineSmall,
                ),
                CustomTextButton(
                  label: 'See All',
                  onPressed: () => context.push('/list'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return ItemCard(
                  title: mockItems[index].title,
                  description: mockItems[index].description,
                  imageUrl: mockItems[index].imageUrl,
                  rating: mockItems[index].rating,
                  onTap: () => context.push('/detail/${mockItems[index].id}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
