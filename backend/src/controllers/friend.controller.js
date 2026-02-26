const Friend = require('../models/Friend');
const User = require('../models/User');

/**
 * @desc    搜索用户
 * @route   GET /api/friends/search
 * @access  Private
 */
exports.searchUsers = async (req, res) => {
  try {
    const { query } = req.query;
    
    if (!query || query.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: '搜索关键词至少需要2个字符'
      });
    }

    // 搜索用户名或邮箱
    const users = await User.find({
      _id: { $ne: req.user._id }, // 排除自己
      $or: [
        { username: { $regex: query, $options: 'i' } },
        { email: { $regex: query, $options: 'i' } }
      ]
    })
      .select('username email')
      .limit(20);

    // 获取与这些用户的好友关系状态
    const userIds = users.map(u => u._id);
    const friendships = await Friend.find({
      $or: [
        { requester: req.user._id, recipient: { $in: userIds } },
        { requester: { $in: userIds }, recipient: req.user._id }
      ]
    });

    // 构建关系映射
    const friendshipMap = {};
    friendships.forEach(f => {
      const otherUserId = f.requester.toString() === req.user._id.toString() 
        ? f.recipient.toString() 
        : f.requester.toString();
      friendshipMap[otherUserId] = {
        status: f.status,
        isRequester: f.requester.toString() === req.user._id.toString()
      };
    });

    // 添加好友状态到用户信息
    const usersWithStatus = users.map(user => ({
      id: user._id,
      username: user.username,
      email: user.email,
      friendshipStatus: friendshipMap[user._id.toString()]?.status || 'none',
      isRequester: friendshipMap[user._id.toString()]?.isRequester || false
    }));

    res.status(200).json({
      success: true,
      data: usersWithStatus
    });
  } catch (error) {
    console.error('搜索用户错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    发送好友请求
 * @route   POST /api/friends/request
 * @access  Private
 */
exports.sendFriendRequest = async (req, res) => {
  try {
    const { recipientId } = req.body;

    if (!recipientId) {
      return res.status(400).json({
        success: false,
        message: '请提供收件人ID'
      });
    }

    // 不能添加自己为好友
    if (recipientId === req.user._id.toString()) {
      return res.status(400).json({
        success: false,
        message: '不能添加自己为好友'
      });
    }

    // 检查收件人是否存在
    const recipient = await User.findById(recipientId);
    if (!recipient) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      });
    }

    // 检查是否已存在好友关系
    const existingFriendship = await Friend.findOne({
      $or: [
        { requester: req.user._id, recipient: recipientId },
        { requester: recipientId, recipient: req.user._id }
      ]
    });

    if (existingFriendship) {
      if (existingFriendship.status === 'accepted') {
        return res.status(400).json({
          success: false,
          message: '你们已经是好友了'
        });
      } else if (existingFriendship.status === 'pending') {
        return res.status(400).json({
          success: false,
          message: '已发送好友请求，等待对方接受'
        });
      } else if (existingFriendship.status === 'blocked') {
        return res.status(400).json({
          success: false,
          message: '无法发送好友请求'
        });
      }
    }

    // 创建好友请求
    const friendship = await Friend.create({
      requester: req.user._id,
      recipient: recipientId,
      status: 'pending'
    });

    await friendship.populate('recipient', 'username email');

    res.status(201).json({
      success: true,
      data: friendship,
      message: '好友请求已发送'
    });
  } catch (error) {
    console.error('发送好友请求错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    接受好友请求
 * @route   PUT /api/friends/accept/:id
 * @access  Private
 */
exports.acceptFriendRequest = async (req, res) => {
  try {
    const friendship = await Friend.findById(req.params.id);

    if (!friendship) {
      return res.status(404).json({
        success: false,
        message: '好友请求不存在'
      });
    }

    // 只有接收者可以接受请求
    if (friendship.recipient.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: '无权操作'
      });
    }

    if (friendship.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: '好友请求已处理'
      });
    }

    friendship.status = 'accepted';
    await friendship.save();

    await friendship.populate('requester', 'username email');

    res.status(200).json({
      success: true,
      data: friendship,
      message: '已成为好友'
    });
  } catch (error) {
    console.error('接受好友请求错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    拒绝好友请求
 * @route   PUT /api/friends/reject/:id
 * @access  Private
 */
exports.rejectFriendRequest = async (req, res) => {
  try {
    const friendship = await Friend.findById(req.params.id);

    if (!friendship) {
      return res.status(404).json({
        success: false,
        message: '好友请求不存在'
      });
    }

    // 只有接收者可以拒绝请求
    if (friendship.recipient.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: '无权操作'
      });
    }

    friendship.status = 'rejected';
    await friendship.save();

    res.status(200).json({
      success: true,
      message: '已拒绝好友请求'
    });
  } catch (error) {
    console.error('拒绝好友请求错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    删除好友
 * @route   DELETE /api/friends/:id
 * @access  Private
 */
exports.removeFriend = async (req, res) => {
  try {
    const friendship = await Friend.findById(req.params.id);

    if (!friendship) {
      return res.status(404).json({
        success: false,
        message: '好友关系不存在'
      });
    }

    // 只有相关用户可以删除好友关系
    const isRequester = friendship.requester.toString() === req.user._id.toString();
    const isRecipient = friendship.recipient.toString() === req.user._id.toString();

    if (!isRequester && !isRecipient) {
      return res.status(403).json({
        success: false,
        message: '无权操作'
      });
    }

    await Friend.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: '已删除好友'
    });
  } catch (error) {
    console.error('删除好友错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    获取我的好友列表
 * @route   GET /api/friends/my-friends
 * @access  Private
 */
exports.getMyFriends = async (req, res) => {
  try {
    const friendships = await Friend.find({
      $or: [
        { requester: req.user._id, status: 'accepted' },
        { recipient: req.user._id, status: 'accepted' }
      ]
    })
      .populate('requester', 'username email')
      .populate('recipient', 'username email')
      .sort({ updatedAt: -1 });

    // 提取好友信息（排除自己）
    const friends = friendships.map(f => {
      const friend = f.requester._id.toString() === req.user._id.toString()
        ? f.recipient
        : f.requester;
      
      return {
        friendshipId: f._id,
        id: friend._id,
        username: friend.username,
        email: friend.email,
        since: f.updatedAt
      };
    });

    res.status(200).json({
      success: true,
      data: friends,
      count: friends.length
    });
  } catch (error) {
    console.error('获取好友列表错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    获取待处理的好友请求
 * @route   GET /api/friends/pending
 * @access  Private
 */
exports.getPendingRequests = async (req, res) => {
  try {
    const requests = await Friend.find({
      recipient: req.user._id,
      status: 'pending'
    })
      .populate('requester', 'username email')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: requests,
      count: requests.length
    });
  } catch (error) {
    console.error('获取待处理请求错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};
