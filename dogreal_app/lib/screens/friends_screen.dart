import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/friend_provider.dart';
import '../utils/constants.dart';

/// 好友页面 - 包含搜索、好友列表和请求
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 延迟加载数据，避免在build期间调用setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    await Future.wait([
      friendProvider.fetchMyFriends(),
      friendProvider.fetchPendingRequests(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: const Text(
          '好友',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: '搜索'),
            Consumer<FriendProvider>(
              builder: (context, provider, _) => Tab(
                text: '好友 (${provider.friendsCount})',
              ),
            ),
            Consumer<FriendProvider>(
              builder: (context, provider, _) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('请求'),
                    if (provider.pendingRequestsCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${provider.pendingRequestsCount}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildFriendsTab(),
          _buildRequestsTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // 搜索框
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: '搜索用户名或邮箱',
              hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: AppColors.white),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.white),
                      onPressed: () {
                        _searchController.clear();
                        Provider.of<FriendProvider>(context, listen: false).clearSearchResults();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              if (value.trim().length >= 2) {
                Provider.of<FriendProvider>(context, listen: false).searchUsers(value);
              } else {
                Provider.of<FriendProvider>(context, listen: false).clearSearchResults();
              }
              setState(() {});
            },
          ),
        ),
        // 搜索结果
        Expanded(
          child: Consumer<FriendProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                );
              }

              if (provider.searchResults.isEmpty) {
                return Center(
                  child: Text(
                    _searchController.text.trim().isEmpty
                        ? '输入至少2个字符开始搜索'
                        : '未找到用户',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: provider.searchResults.length,
                itemBuilder: (context, index) {
                  final user = provider.searchResults[index];
                  return _buildUserItem(user, provider);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserItem(dynamic user, FriendProvider provider) {
    String buttonText = '添加好友';
    VoidCallback? onPressed = () async {
      final success = await provider.sendFriendRequest(user.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('好友请求已发送')),
        );
      }
    };

    if (user.friendshipStatus == 'pending') {
      buttonText = user.isRequester ? '已发送' : '待接受';
      onPressed = null;
    } else if (user.friendshipStatus == 'accepted') {
      buttonText = '已是好友';
      onPressed = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.white.withOpacity(0.1),
            child: Text(
              user.username[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: onPressed == null 
                  ? AppColors.white.withOpacity(0.3)
                  : AppColors.white,
              foregroundColor: AppColors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Consumer<FriendProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.white),
          );
        }

        if (provider.friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: AppColors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '还没有好友',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '去搜索页面添加好友吧',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: provider.friends.length,
          itemBuilder: (context, index) {
            final friend = provider.friends[index];
            return _buildFriendItem(friend, provider);
          },
        );
      },
    );
  }

  Widget _buildFriendItem(dynamic friend, FriendProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.white.withOpacity(0.1),
            child: Text(
              friend.username[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.username,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  friend.email,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onPressed: () {
              _showFriendOptions(friend, provider);
            },
          ),
        ],
      ),
    );
  }

  void _showFriendOptions(dynamic friend, FriendProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.mediumGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_remove, color: AppColors.error),
              title: const Text(
                '删除好友',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.mediumGrey,
                    title: const Text('确认删除', style: TextStyle(color: AppColors.white)),
                    content: Text(
                      '确定要删除好友 ${friend.username} 吗？',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('删除', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  final success = await provider.removeFriend(friend.id);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已删除好友')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return Consumer<FriendProvider>(
      builder: (context, provider, _) {
        if (provider.pendingRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: AppColors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '没有待处理的请求',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: provider.pendingRequests.length,
          itemBuilder: (context, index) {
            final request = provider.pendingRequests[index];
            return _buildRequestItem(request, provider);
          },
        );
      },
    );
  }

  Widget _buildRequestItem(dynamic request, FriendProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.white.withOpacity(0.1),
            child: Text(
              request.requesterUsername[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.requesterUsername,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  request.requesterEmail,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () async {
                  final success = await provider.acceptFriendRequest(request.id);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已接受好友请求')),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.error),
                onPressed: () async {
                  final success = await provider.rejectFriendRequest(request.id);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已拒绝好友请求')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
