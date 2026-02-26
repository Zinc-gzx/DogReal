const mongoose = require('mongoose');

const challengeSchema = new mongoose.Schema({
  // 挑战日期
  date: {
    type: Date,
    required: true
  },
  // 挑战主题
  theme: {
    type: String,
    required: true
  },
  // 挑战图标（emoji）
  icon: {
    type: String,
    required: true
  },
  // 挑战描述
  description: {
    type: String,
    required: true
  },
  // 推送时间
  notificationTime: {
    type: String, // 格式: "HH:mm" 如 "14:30"
    required: true
  },
  // 是否已发送通知
  notificationSent: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// 索引：确保每天只有一个挑战
challengeSchema.index({ date: 1 }, { unique: true });

// 获取今日挑战的静态方法
challengeSchema.statics.getTodayChallenge = async function() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);
  
  let challenge = await this.findOne({
    date: {
      $gte: today,
      $lt: tomorrow
    }
  });
  
  // 如果今天没有挑战，自动创建一个
  if (!challenge) {
    challenge = await this.createTodayChallenge();
  }
  
  return challenge;
};

// 创建今日挑战的静态方法
challengeSchema.statics.createTodayChallenge = async function() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  // 随机挑战主题库
  const themes = [
    {
      theme: '宠物的早餐时光',
      icon: '🍽️',
      description: '拍下你的宠物享用早餐的可爱瞬间'
    },
    {
      theme: '毛茸茸的睡姿',
      icon: '😴',
      description: '记录宠物最萌的睡觉姿势'
    },
    {
      theme: '玩具大作战',
      icon: '🎾',
      description: '展示宠物最喜欢的玩具'
    },
    {
      theme: '散步时光',
      icon: '🐾',
      description: '记录今天的遛弯冒险'
    },
    {
      theme: '窗边的风景',
      icon: '🪟',
      description: '拍下宠物看向窗外的样子'
    },
    {
      theme: '洗澡啦',
      icon: '🛁',
      description: '记录宠物洗澡的有趣瞬间'
    },
    {
      theme: '最佳表情',
      icon: '😊',
      description: '捕捉宠物今天最可爱的表情'
    },
    {
      theme: '零食时间',
      icon: '🦴',
      description: '分享宠物吃零食的幸福时刻'
    },
    {
      theme: '躲猫猫高手',
      icon: '🙈',
      description: '找找宠物藏在哪里'
    },
    {
      theme: '阳光下的慵懒',
      icon: '☀️',
      description: '记录宠物晒太阳的样子'
    },
    {
      theme: '训练时间',
      icon: '🎓',
      description: '展示宠物学会的新技能'
    },
    {
      theme: '好朋友相聚',
      icon: '🐕',
      description: '拍下宠物和朋友玩耍的场景'
    }
  ];
  
  // 随机选择一个主题
  const randomTheme = themes[Math.floor(Math.random() * themes.length)];
  
  // 生成随机推送时间（9:00 - 21:00之间）
  const hour = Math.floor(Math.random() * 12) + 9; // 9-20
  const minute = Math.floor(Math.random() * 60);
  const notificationTime = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
  
  const challenge = await this.create({
    date: today,
    ...randomTheme,
    notificationTime,
    notificationSent: false
  });
  
  return challenge;
};

module.exports = mongoose.model('Challenge', challengeSchema);
