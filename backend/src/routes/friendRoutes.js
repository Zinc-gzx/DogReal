const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  searchUsers,
  sendFriendRequest,
  acceptFriendRequest,
  rejectFriendRequest,
  removeFriend,
  getMyFriends,
  getPendingRequests
} = require('../controllers/friend.controller');

// 搜索用户
router.get('/search', protect, searchUsers);

// 发送好友请求
router.post('/request', protect, sendFriendRequest);

// 接受好友请求
router.put('/accept/:id', protect, acceptFriendRequest);

// 拒绝好友请求
router.put('/reject/:id', protect, rejectFriendRequest);

// 删除好友
router.delete('/:id', protect, removeFriend);

// 获取我的好友列表
router.get('/my-friends', protect, getMyFriends);

// 获取待处理的好友请求
router.get('/pending', protect, getPendingRequests);

module.exports = router;
