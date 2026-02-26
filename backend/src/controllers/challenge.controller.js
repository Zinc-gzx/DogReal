const Challenge = require('../models/Challenge');

// 获取今日挑战
exports.getTodayChallenge = async (req, res) => {
  try {
    const challenge = await Challenge.getTodayChallenge();
    
    res.status(200).json({
      success: true,
      data: challenge
    });
  } catch (error) {
    console.error('Get today challenge error:', error);
    res.status(500).json({
      success: false,
      message: error.message || '获取今日挑战失败'
    });
  }
};

// 手动创建今日挑战（管理员功能）
exports.createChallenge = async (req, res) => {
  try {
    const { theme, icon, description, notificationTime } = req.body;
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    // 检查今天是否已有挑战
    const existingChallenge = await Challenge.findOne({
      date: {
        $gte: today,
        $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
      }
    });
    
    if (existingChallenge) {
      // 更新现有挑战
      existingChallenge.theme = theme;
      existingChallenge.icon = icon;
      existingChallenge.description = description;
      existingChallenge.notificationTime = notificationTime;
      existingChallenge.notificationSent = false;
      
      await existingChallenge.save();
      
      return res.status(200).json({
        success: true,
        data: existingChallenge,
        message: '挑战已更新'
      });
    }
    
    // 创建新挑战
    const challenge = await Challenge.create({
      date: today,
      theme,
      icon,
      description,
      notificationTime,
      notificationSent: false
    });
    
    res.status(201).json({
      success: true,
      data: challenge
    });
  } catch (error) {
    console.error('Create challenge error:', error);
    res.status(500).json({
      success: false,
      message: error.message || '创建挑战失败'
    });
  }
};

// 获取历史挑战
exports.getChallengeHistory = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    
    const challenges = await Challenge.find()
      .sort({ date: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));
    
    const total = await Challenge.countDocuments();
    
    res.status(200).json({
      success: true,
      data: {
        challenges,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get challenge history error:', error);
    res.status(500).json({
      success: false,
      message: error.message || '获取挑战历史失败'
    });
  }
};
