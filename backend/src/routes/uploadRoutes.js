const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');
const { uploadAvatar, uploadImage } = require('../controllers/upload.controller');

// 上传头像（需要身份验证）
router.post('/avatar', protect, upload.single('avatar'), uploadAvatar);

// 上传帖子图片（需要身份验证）
router.post('/image', protect, upload.single('image'), uploadImage);

module.exports = router;
