import 'package:flutter/material.dart';
import 'models/buddy_post.dart';
import 'models/group_order.dart';
import 'widgets/buddy_card.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/order_card.dart';
import 'widgets/create_group_order_sheet.dart';
import 'widgets/create_post_sheet.dart';
import 'services/community_service.dart';
import 'services/order_service.dart';
import 'package:mobile/core/models/conversation.dart';
import 'package:mobile/features/chat/services/chat_service.dart';
import 'package:mobile/features/chat/screens/chat_screen.dart';

enum CommunityTab { buddyMatch, groupOrders }

class CommunityBoardScreen extends StatefulWidget {
  const CommunityBoardScreen({super.key});

  @override
  State<CommunityBoardScreen> createState() => _CommunityBoardScreenState();
}

class _CommunityBoardScreenState extends State<CommunityBoardScreen> {
  CommunityTab _activeTab = CommunityTab.buddyMatch;
  PostCategory? _selectedCategory;
  bool _showSavedPostsOnly = false;
  OrderStatus? _selectedStatus;

  List<BuddyPost> _posts = [];
  bool _isLoadingPosts = true;
  String? _postsError;

  List<GroupOrder> _orders = [];
  bool _isLoadingOrders = true;
  String? _ordersError;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadOrders();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoadingPosts = true;
      _postsError = null;
    });
    try {
      final data = await CommunityService.getPosts(
        category: _selectedCategory?.apiValue,
      );
      setState(() {
        _posts = data.map((j) => BuddyPost.fromJson(j)).toList();
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        _postsError = e.toString().replaceAll('Exception: ', '');
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoadingOrders = true;
      _ordersError = null;
    });
    try {
      final data = await OrderService.getOrders(
        status: _selectedStatus?.apiValue,
      );
      setState(() {
        _orders = data.map((j) => GroupOrder.fromJson(j)).toList();
        _isLoadingOrders = false;
      });
    } catch (e) {
      setState(() {
        _ordersError = e.toString().replaceAll('Exception: ', '');
        _isLoadingOrders = false;
      });
    }
  }

  List<BuddyPost> get _filteredPosts {
    if (_showSavedPostsOnly) {
      return _posts.where((p) => p.isFavorited).toList();
    }
    if (_selectedCategory == null) return _posts;
    return _posts.where((p) => p.category == _selectedCategory).toList();
  }

  List<GroupOrder> get _filteredOrders {
    if (_selectedStatus == null) return _orders;
    return _orders.where((o) => o.status == _selectedStatus).toList();
  }

  int get _joinedCount => _orders.where((o) => o.isJoined).length;

  String get _headerSubtitle => _activeTab == CommunityTab.buddyMatch
      ? '${_posts.length} posts'
      : '$_joinedCount joined · ${_orders.length} orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(child: _buildHeader()),
        ],
        body: _activeTab == CommunityTab.buddyMatch
            ? _buildBuddyMatchBody()
            : _buildGroupOrdersBody(),
      ),
    );
  }

  Widget _buildBuddyMatchBody() {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: CategoryFilterBar(
            selected: _selectedCategory,
            savingsSelected: _showSavedPostsOnly,
            onChanged: (cat) {
              setState(() {
                _selectedCategory = cat;
                _showSavedPostsOnly = false;
              });
              _loadPosts();
            },
            onSavingsToggle: () {
              setState(() {
                _showSavedPostsOnly = !_showSavedPostsOnly;
                if (_showSavedPostsOnly) _selectedCategory = null;
              });
              if (_showSavedPostsOnly) _loadPosts();
            },
          ),
        ),
        Expanded(
          child: _isLoadingPosts
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                )
              : _postsError != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _postsError!,
                            style: const TextStyle(color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 12),
                          TextButton(onPressed: _loadPosts, child: const Text('Retry')),
                        ],
                      ),
                    )
                  : _filteredPosts.isEmpty
                      ? Center(
                          child: Text(
                            _showSavedPostsOnly ? 'No saved posts yet.' : 'No posts yet.',
                            style: const TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          itemCount: _filteredPosts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => BuddyCard(
                            post: _filteredPosts[i],
                            onMessage: () => _handleSendMessage(_filteredPosts[i]),
                            onToggleFavorite: () => _handleToggleFavorite(_filteredPosts[i]),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildGroupOrdersBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    const Text(
                      'Prices shown in SGD',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              _OrderStatusFilterBar(
                selected: _selectedStatus,
                onChanged: (s) {
                  setState(() => _selectedStatus = s);
                  _loadOrders();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingOrders
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                )
              : _ordersError != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _ordersError!,
                            style: const TextStyle(color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 12),
                          TextButton(onPressed: _loadOrders, child: const Text('Retry')),
                        ],
                      ),
                    )
                  : _filteredOrders.isEmpty
                      ? const Center(
                          child: Text(
                            'No orders in this status.',
                            style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          itemCount: _filteredOrders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final order = _filteredOrders[i];
                            return OrderCard(
                              order: order,
                              onJoin: () => _handleJoin(order),
                              onLeave: () => _handleLeave(order),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 172,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A00C8), Color(0xFF3A10E0), Color(0xFF5B2CF5),
                Color(0xFFC084FC), Color(0xFFF9D4FF),
              ],
              stops: [0.085, 0.292, 0.458, 0.666, 0.915],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: SizedBox(
                  height: 54,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Community Board',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2)),
                            Text(_headerSubtitle,
                                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _handleNewPost,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text('Post', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      _TabButton(
                        label: 'Buddy Match', icon: Icons.people_outline,
                        isSelected: _activeTab == CommunityTab.buddyMatch,
                        onTap: () => setState(() => _activeTab = CommunityTab.buddyMatch),
                      ),
                      _TabButton(
                        label: 'Group Orders', icon: Icons.shopping_bag_outlined,
                        isSelected: _activeTab == CommunityTab.groupOrders,
                        onTap: () => setState(() => _activeTab = CommunityTab.groupOrders),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleNewPost() {
    if (_activeTab == CommunityTab.groupOrders) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CreateGroupOrderSheet(
          onCreated: _loadOrders,
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CreatePostSheet(
          onCreated: _loadPosts,
        ),
      );
    }
  }

  void _handleSendMessage(BuddyPost post) async {
    if (post.authorId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to start a chat with this user.')),
        );
      }
      return;
    }

    try {
      final conversationId = await ChatService.startDirectChat(post.authorId!);
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversation: Conversation(
              id: conversationId,
              type: ConversationType.direct,
              otherUserId: post.authorId,
              otherUserName: post.name,
            ),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _handleToggleFavorite(BuddyPost post) async {
    try {
      final favorited = await CommunityService.toggleFavorite(post.id);
      setState(() {
        final idx = _posts.indexWhere((p) => p.id == post.id);
        if (idx != -1) _posts[idx] = _posts[idx].copyWith(isFavorited: favorited);
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _handleJoin(GroupOrder order) async {
    await _loadOrders();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined "${order.title}"!')),
      );
    }
  }

  void _handleLeave(GroupOrder order) async {
    try {
      await OrderService.leaveOrder(order.id);
      setState(() {
        final idx = _orders.indexWhere((o) => o.id == order.id);
        if (idx != -1) _orders[idx] = _orders[idx].copyWith(isJoined: false);
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? const [BoxShadow(color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13,
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.white.withValues(alpha: 0.75)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? const Color(0xFF7C3AED) : Colors.white.withValues(alpha: 0.75),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderStatusFilterBar extends StatelessWidget {
  final OrderStatus? selected;
  final ValueChanged<OrderStatus?> onChanged;

  const _OrderStatusFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final statuses = [null, ...OrderStatus.values];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final status = statuses[i];
          final isSelected = status == selected;
          final label = status?.label ?? 'All';
          final color = status?.color ?? const Color(0xFF818CF8);

          return GestureDetector(
            onTap: () => onChanged(status),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? (status?.bgColor ?? const Color(0xFF818CF8).withValues(alpha: 0.12))
                    : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected ? color.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? color : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}