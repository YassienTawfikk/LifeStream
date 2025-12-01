import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/models/index.dart';
import 'package:life_stream/widgets/index.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  int _selectedCategory = 0;
  final List<String> categories = ['All', 'Nature', 'City', 'Adventure'];

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
    Item(
      id: '4',
      title: 'Mountain Peak',
      description: 'Standing on the top of the world',
      rating: 4.9,
      views: 3100,
      createdAt: DateTime.now(),
      category: 'Nature',
      imageUrl: 'https://via.placeholder.com/300x200?text=Mountain',
    ),
  ];

  List<Item> get filteredItems {
    if (_selectedCategory == 0) return mockItems;
    return mockItems
        .where((item) => item.category == categories[_selectedCategory])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Explore'),
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;
                return FilterChip(
                  label: Text(categories[index]),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedCategory = index);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Items Grid
          Expanded(
            child: filteredItems.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.inbox_outlined,
                    title: 'No Items Found',
                    description:
                        'Try changing your filter or search for something else',
                    onRetry: () => setState(() => _selectedCategory = 0),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return ItemCard(
                        title: filteredItems[index].title,
                        description: filteredItems[index].description,
                        imageUrl: filteredItems[index].imageUrl,
                        rating: filteredItems[index].rating,
                        onTap: () =>
                            context.push('/detail/${filteredItems[index].id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
