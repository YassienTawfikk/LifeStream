import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/providers/friends_provider.dart';
import 'package:life_stream/widgets/index.dart';
import 'package:life_stream/models/friend_request.dart';
import 'package:life_stream/models/user.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late TextEditingController _searchController;
  bool _isSearching = false;
  List<User> _searchResults = [];

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

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final results = await ref
          .read(friendsProvider.notifier)
          .searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Find Friends'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onSubmitted: _performSearch, // Search on enter
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _performSearch(_searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? EmptyStateWidget(
                      icon: Icons.search_off,
                      title: 'No Users Found',
                      description:
                          'Try checking the spelling or use a different email.',
                      onRetry: () => _performSearch(_searchController.text),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        final isFriend = friendsState.friends.any(
                          (f) => f.id == user.id,
                        );
                        final isPending = friendsState.sentRequests.any(
                          (r) =>
                              r.receiverId == user.id &&
                              r.status == RequestStatus.pending,
                        );

                        return AppCard(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: UserAvatar(
                              profilePictureUrl: user.profilePictureUrl,
                              name: user.name,
                              radius: 20,
                            ),
                            title: Text(
                              user.name,
                              style: AppTextStyles.titleMedium,
                            ),
                            subtitle: Text(
                              user.email,
                              style: AppTextStyles.bodySmall,
                            ),
                            trailing: isFriend
                                ? const Chip(
                                    label: Text('Friends'),
                                    visualDensity: VisualDensity.compact,
                                  )
                                : isPending
                                ? const Chip(
                                    label: Text('Sent'),
                                    visualDensity: VisualDensity.compact,
                                  )
                                : FilledButton.tonal(
                                    onPressed: () {
                                      ref
                                          .read(friendsProvider.notifier)
                                          .sendRequest(user);
                                    },
                                    child: const Text('Add'),
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
