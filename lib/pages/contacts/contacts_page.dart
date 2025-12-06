import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';

import 'package:life_stream/providers/friends_provider.dart';
import 'package:life_stream/widgets/index.dart';
import 'package:life_stream/models/friend_request.dart';

class EmergencyContactsPage extends ConsumerStatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  ConsumerState<EmergencyContactsPage> createState() =>
      _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends ConsumerState<EmergencyContactsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Friends'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => context.push('/search'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Friends'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Friends List
          friendsState.friends.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: 'No Emergency Friends',
                  description:
                      'Add friends to notify them in case of emergency.',
                  onRetry: () => context.push('/search'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: friendsState.friends.length,
                  itemBuilder: (context, index) {
                    final friend = friendsState.friends[index];
                    return AppCard(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        leading: UserAvatar(
                          profilePictureUrl: friend.profilePictureUrl,
                          name: friend.name,
                          radius: 20,
                        ),
                        title: Text(
                          friend.name,
                          style: AppTextStyles.titleMedium,
                        ),
                        subtitle: Text(
                          friend.email,
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: const Icon(
                          Icons.shield,
                          color: AppColors.success,
                        ),
                      ),
                    );
                  },
                ),

          // Requests List
          friendsState.receivedRequests
                  .where((r) => r.status == RequestStatus.pending)
                  .isEmpty
              ? const Center(child: Text('No pending requests'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: friendsState.receivedRequests
                      .where((r) => r.status == RequestStatus.pending)
                      .length,
                  itemBuilder: (context, index) {
                    final request = friendsState.receivedRequests
                        .where((r) => r.status == RequestStatus.pending)
                        .toList()[index];
                    return AppCard(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              request.senderName,
                              style: AppTextStyles.titleMedium,
                            ),
                            subtitle: Text(
                              request.senderEmail,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(friendsProvider.notifier)
                                      .rejectRequest(request.id);
                                },
                                child: const Text('Decline'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: () {
                                  ref
                                      .read(friendsProvider.notifier)
                                      .acceptRequest(request);
                                },
                                child: const Text('Accept'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
