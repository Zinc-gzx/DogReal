const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  createPost,
  getFeed,
  getMyPosts,
  checkTodayPost,
  toggleLike,
  addComment,
  deletePost
} = require('../controllers/post.controller');

// 所有路由都需要身份验证
router.use(protect);

// 创建帖子
router.post('/', createPost);

// 获取Feed
router.get('/feed', getFeed);

// 获取我的帖子
router.get('/my-posts', getMyPosts);

// 检查今天是否已发布
router.get('/check-today', checkTodayPost);

// 点赞/取消点赞
router.post('/:id/like', toggleLike);

// 添加评论
router.post('/:id/comment', addComment);

// 删除帖子
router.delete('/:id', deletePost);

module.exports = router;
