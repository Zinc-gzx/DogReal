const mongoose = require('mongoose');

const friendSchema = new mongoose.Schema({
  // 发起请求的用户
  requester: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  // 接收请求的用户
  recipient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  // 好友状态
  status: {
    type: String,
    enum: ['pending', 'accepted', 'rejected', 'blocked'],
    default: 'pending'
  },
  // 请求发送时间
  createdAt: {
    type: Date,
    default: Date.now
  },
  // 状态更新时间
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// 索引：加速查询
friendSchema.index({ requester: 1, recipient: 1 }, { unique: true });
friendSchema.index({ requester: 1, status: 1 });
friendSchema.index({ recipient: 1, status: 1 });

// 更新时间戳
friendSchema.pre('save', function() {
  this.updatedAt = Date.now();
});

module.exports = mongoose.model('Friend', friendSchema);
