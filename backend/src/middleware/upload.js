const multer = require('multer');
const path = require('path');
const fs = require('fs');

// 确保上传目录存在
const avatarDir = path.join(__dirname, '../../uploads/avatars');
const postsDir = path.join(__dirname, '../../uploads/posts');

if (!fs.existsSync(avatarDir)) {
  fs.mkdirSync(avatarDir, { recursive: true });
}

if (!fs.existsSync(postsDir)) {
  fs.mkdirSync(postsDir, { recursive: true });
}

// 配置存储
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    // 根据字段名选择目录
    if (file.fieldname === 'avatar') {
      cb(null, avatarDir);
    } else if (file.fieldname === 'image') {
      cb(null, postsDir);
    } else {
      cb(null, avatarDir); // 默认
    }
  },
  filename: function(req, file, cb) {
    // 生成唯一文件名：类型_userId_timestamp_随机数.扩展名
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    const prefix = file.fieldname === 'avatar' ? 'avatar' : 'post';
    cb(null, `${prefix}_${req.user._id}_${uniqueSuffix}${ext}`);
  }
});

// 文件过滤器
const fileFilter = (req, file, cb) => {
  console.log('文件上传检查:');
  console.log('- 原始文件名:', file.originalname);
  console.log('- MIME类型:', file.mimetype);
  console.log('- 字段名:', file.fieldname);
  
  // 只允许图片文件 - 主要检查扩展名，因为模拟器的MIME类型可能不准确
  const allowedExtensions = /\.(jpeg|jpg|png|gif|webp)$/i;
  const hasValidExtension = allowedExtensions.test(file.originalname.toLowerCase());
  
  // 允许image/*或application/octet-stream（模拟器上传时的MIME类型）
  const hasValidMimetype = file.mimetype.startsWith('image/') || file.mimetype === 'application/octet-stream';

  console.log('- 扩展名检查:', hasValidExtension);
  console.log('- MIME类型检查:', hasValidMimetype);

  if (hasValidExtension && hasValidMimetype) {
    console.log('✅ 文件验证通过');
    return cb(null, true);
  } else {
    console.log('❌ 文件验证失败');
    cb(new Error('只支持图片文件 (jpeg, jpg, png, gif, webp)'));
  }
};

// 配置multer
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 限制5MB
  },
  fileFilter: fileFilter
});

module.exports = upload;
