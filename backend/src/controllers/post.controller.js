const Post = require('../models/Post');
const Pet = require('../models/Pet');

/**
 * @desc    创建帖子
 * @route   POST /api/posts
 * @access  Private
 */
exports.createPost = async (req, res) => {
  try {
    const { petId, images, caption, location, isLate } = req.body;

    // 验证必填字段
    if (!petId || !images || images.length === 0) {
      return res.status(400).json({
        success: false,
        message: '请提供宠物ID和图片'
      });
    }

    // 验证宠物归属
    const pet = await Pet.findById(petId);
    if (!pet) {
      return res.status(404).json({
        success: false,
        message: '未找到宠物'
      });
    }

    if (pet.owner.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: '无权限使用此宠物发布'
      });
    }

    // 检查今天是否已发布
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const existingPost = await Post.findOne({
      user: req.user._id,
      postedAt: {
        $gte: today,
        $lt: tomorrow
      },
      isActive: true
    });

    if (existingPost) {
      return res.status(400).json({
        success: false,
        message: '今天已经发布过了'
      });
    }

    // 创建帖子
    const post = await Post.create({
      user: req.user._id,
      pet: petId,
      images,
      caption: caption || '',
      location: location || '',
      isLate: isLate || false,
      postedAt: new Date()
    });

    // 填充用户和宠物信息
    await post.populate('user', 'username email');
    await post.populate('pet', 'name breed avatar');

    res.status(201).json({
      success: true,
      data: post,
      message: '发布成功'
    });
  } catch (error) {
    console.error('创建帖子错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    获取Feed（只显示今天的帖子）
 * @route   GET /api/posts/feed
 * @access  Private
 */
exports.getFeed = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    // BeReal核心机制：只显示今天的帖子
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // 查询今天发布的帖子
    const posts = await Post.find({
      isActive: true,
      postedAt: {
        $gte: today,
        $lt: tomorrow
      }
    })
      .populate('user', 'username email')
      .populate('pet', 'name breed avatar age')
      .populate('comments.user', 'username')
      .sort({ postedAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Post.countDocuments({
      isActive: true,
      postedAt: {
        $gte: today,
        $lt: tomorrow
      }
    });

    res.status(200).json({
      success: true,
      data: posts,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('获取Feed错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    获取我的帖子
 * @route   GET /api/posts/my-posts
 * @access  Private
 */
exports.getMyPosts = async (req, res) => {
  try {
    const posts = await Post.find({
      user: req.user._id,
      isActive: true
    })
      .populate('pet', 'name breed avatar age')
      .sort({ postedAt: -1 });

    res.status(200).json({
      success: true,
      data: posts
    });
  } catch (error) {
    console.error('获取我的帖子错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    检查今天是否已发布
 * @route   GET /api/posts/check-today
 * @access  Private
 */
exports.checkTodayPost = async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const post = await Post.findOne({
      user: req.user._id,
      postedAt: {
        $gte: today,
        $lt: tomorrow
      },
      isActive: true
    });

    res.status(200).json({
      success: true,
      data: {
        hasPostedToday: !!post,
        post: post || null
      }
    });
  } catch (error) {
    console.error('检查今日发布错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    点赞/取消点赞
 * @route   POST /api/posts/:id/like
 * @access  Private
 */
exports.toggleLike = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: '未找到帖子'
      });
    }

    const isLiked = post.isLikedBy(req.user._id);

    if (isLiked) {
      // 取消点赞
      post.likes = post.likes.filter(
        like => like.toString() !== req.user._id.toString()
      );
    } else {
      // 点赞
      post.likes.push(req.user._id);
    }

    await post.updateLikesCount();

    res.status(200).json({
      success: true,
      data: {
        isLiked: !isLiked,
        likesCount: post.likesCount
      },
      message: isLiked ? '已取消点赞' : '点赞成功'
    });
  } catch (error) {
    console.error('点赞错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    添加评论
 * @route   POST /api/posts/:id/comment
 * @access  Private
 */
exports.addComment = async (req, res) => {
  try {
    const { text } = req.body;

    if (!text || text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: '请输入评论内容'
      });
    }

    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: '未找到帖子'
      });
    }

    post.comments.push({
      user: req.user._id,
      text: text.trim(),
      createdAt: new Date()
    });

    await post.updateCommentsCount();
    await post.populate('comments.user', 'username');

    res.status(201).json({
      success: true,
      data: post.comments[post.comments.length - 1],
      message: '评论成功'
    });
  } catch (error) {
    console.error('添加评论错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    删除帖子
 * @route   DELETE /api/posts/:id
 * @access  Private
 */
exports.deletePost = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: '未找到帖子'
      });
    }

    // 验证所有者
    if (post.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: '无权限删除此帖子'
      });
    }

    // 软删除
    post.isActive = false;
    await post.save();

    res.status(200).json({
      success: true,
      message: '帖子已删除'
    });
  } catch (error) {
    console.error('删除帖子错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};
