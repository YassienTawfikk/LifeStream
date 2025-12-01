import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/widgets/index.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  bool _isSearching = false;
  final List<String> recentSearches = [
    'Mountains',
    'Nature',
    'Urban',
    'Photography',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    // Mock search
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Search'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _performSearch(value);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results or Recent Searches
            if (_searchController.text.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Searches',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recentSearches
                        .map(
                          (search) => InputChip(
                            label: Text(search),
                            onPressed: () {
                              _searchController.text = search;
                              _performSearch(search);
                              setState(() {});
                            },
                            onDeleted: () {
                              // Remove search
                              setState(() {
                                recentSearches.remove(search);
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Popular Categories',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildCategoryCard(
                        Icons.landscape,
                        'Nature',
                      ),
                      _buildCategoryCard(
                        Icons.apartment,
                        'Urban',
                      ),
                      _buildCategoryCard(
                        Icons.camera,
                        'Photography',
                      ),
                      _buildCategoryCard(
                        Icons.travel_explore,
                        'Adventure',
                      ),
                    ],
                  ),
                ],
              )
            else
              _isSearching
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Searching...',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : EmptyStateWidget(
                      icon: Icons.search_off,
                      title: 'No Results Found',
                      description:
                          'Try searching with different keywords',
                      onRetry: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
        setState(() {});
      },
      child: AppCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
