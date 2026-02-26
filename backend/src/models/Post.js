const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  pet: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pet',
    required: true
  },
  images: [{
    url: {
      type: String,
      required: true
    },
    type: {
      type: String,
      enum: ['front', 'back'],
      required: true
    }
  }],
  caption: {
    type: String,
    maxlength: [500, '描述不能超过500个字符'],
    default: ''
  },
  location: {
    type: String,
    default: ''
  },
  likes: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  likesCount: {
    type: Number,
    default: 0
  },
  comments: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    text: {
      type: String,
      required: true,
      maxlength: 200
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  commentsCount: {
    type: Number,
    default: 0
  },
  isLate: {
    type: Boolean,
    default: false
  },
  postedAt: {
    type: Date,
    default: Date.now
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// 索引优化
postSchema.index({ user: 1, createdAt: -1 });
postSchema.index({ pet: 1, createdAt: -1 });
postSchema.index({ postedAt: -1 });
postSchema.index({ isActive: 1, createdAt: -1 });

// 虚拟字段：检查是否是今天发布的
postSchema.virtual('isToday').get(function() {
  const now = new Date();
  const posted = new Date(this.postedAt);
  return (
    now.getFullYear() === posted.getFullYear() &&
    now.getMonth() === posted.getMonth() &&
    now.getDate() === posted.getDate()
  );
});

// 更新点赞数
postSchema.methods.updateLikesCount = function() {
  this.likesCount = this.likes.length;
  return this.save();
};

// 更新评论数
postSchema.methods.updateCommentsCount = function() {
  this.commentsCount = this.comments.length;
  return this.save();
};

// 检查用户是否点赞
postSchema.methods.isLikedBy = function(userId) {
  return this.likes.some(like => like.toString() === userId.toString());
};

module.exports = mongoose.model('Post', postSchema);
