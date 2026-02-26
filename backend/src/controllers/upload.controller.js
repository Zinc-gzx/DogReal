const path = require('path');

/**
 * @desc    上传头像
 * @route   POST /api/upload/avatar
 * @access  Private
 */
exports.uploadAvatar = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: '请选择要上传的图片'
      });
    }

    // 构建图片URL
    const baseUrl = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
    const imageUrl = `${baseUrl}/uploads/avatars/${req.file.filename}`;

    res.status(200).json({
      success: true,
      data: {
        filename: req.file.filename,
        url: imageUrl,
        size: req.file.size,
        mimetype: req.file.mimetype
      },
      message: '图片上传成功'
    });
  } catch (error) {
    console.error('上传图片错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    上传帖子图片
 * @route   POST /api/upload/image
 * @access  Private
 */
exports.uploadImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: '请选择要上传的图片'
      });
    }

    // 构建图片URL
    const baseUrl = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
    const imageUrl = `${baseUrl}/uploads/posts/${req.file.filename}`;

    res.status(200).json({
      success: true,
      data: {
        filename: req.file.filename,
        url: imageUrl,
        size: req.file.size,
        mimetype: req.file.mimetype
      },
      message: '图片上传成功'
    });
  } catch (error) {
    console.error('上传图片错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};
