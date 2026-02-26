const mongoose = require('mongoose');

const petSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, '请输入宠物名字'],
    trim: true,
    maxlength: [50, '宠物名字不能超过50个字符']
  },
  breed: {
    type: String,
    required: [true, '请选择宠物品种'],
    trim: true
  },
  birthday: {
    type: Date,
    required: [true, '请选择宠物生日']
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'unknown'],
    default: 'unknown'
  },
  avatar: {
    type: String,
    default: '' // 头像URL，可选
  },
  owner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  bio: {
    type: String,
    maxlength: [500, '个人简介不能超过500个字符'],
    default: ''
  },
  weight: {
    type: Number, // 体重（kg）
    min: 0
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true, // 自动添加createdAt和updatedAt
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// 虚拟字段：计算宠物年龄
petSchema.virtual('age').get(function() {
  if (!this.birthday) return 0;
  const today = new Date();
  const birthDate = new Date(this.birthday);
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
});

// 索引优化
petSchema.index({ owner: 1, isActive: 1 });
petSchema.index({ createdAt: -1 });

module.exports = mongoose.model('Pet', petSchema);
