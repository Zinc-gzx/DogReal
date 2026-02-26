const express = require('express');
const router = express.Router();
const challengeController = require('../controllers/challenge.controller');
const { protect } = require('../middleware/auth');

// 所有路由都需要认证
router.use(protect);

// 获取今日挑战
router.get('/today', challengeController.getTodayChallenge);

// 创建/更新今日挑战（管理员功能，暂时开放给所有用户）
router.post('/', challengeController.createChallenge);

// 获取挑战历史
router.get('/history', challengeController.getChallengeHistory);

module.exports = router;
