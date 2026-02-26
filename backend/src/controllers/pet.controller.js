const Pet = require('../models/Pet');

/**
 * @desc    创建宠物档案
 * @route   POST /api/pets
 * @access  Private
 */
exports.createPet = async (req, res) => {
  try {
    const { name, breed, birthday, gender, bio, weight, avatar } = req.body;

    // 验证必填字段
    if (!name || !breed || !birthday) {
      return res.status(400).json({
        success: false,
        message: '请填写宠物名字、品种和生日'
      });
    }

    // 检查用户是否已有激活的宠物档案
    const existingPet = await Pet.findOne({ 
      owner: req.user._id, 
      isActive: true 
    });

    if (existingPet) {
      // 如果已有宠物档案，更新它
      existingPet.name = name;
      existingPet.breed = breed;
      existingPet.birthday = birthday;
      existingPet.gender = gender || 'unknown';
      existingPet.bio = bio || '';
      existingPet.weight = weight || null;
      // 只有提供了新头像时才更新头像
      if (avatar !== undefined && avatar !== null) {
        existingPet.avatar = avatar;
      }
      
      await existingPet.save();
      await existingPet.populate('owner', 'username email');
      
      return res.status(200).json({
        success: true,
        data: existingPet,
        message: '宠物档案更新成功'
      });
    }

    // 创建新宠物
    const pet = await Pet.create({
      name,
      breed,
      birthday,
      gender: gender || 'unknown',
      bio: bio || '',
      weight: weight || null,
      avatar: avatar || '',
      owner: req.user._id
    });

    // 填充owner信息
    await pet.populate('owner', 'username email');

    res.status(201).json({
      success: true,
      data: pet,
      message: '宠物档案创建成功'
    });
  } catch (error) {
    console.error('创建宠物档案错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    获取当前用户的宠物档案
 * @route   GET /api/pets/my-pet
 * @access  Private
 */
exports.getMyPet = async (req, res) => {
  try {
    const pet = await Pet.findOne({ 
      owner: req.user._id, 
      isActive: true 
    }).populate('owner', 'username email');

    if (!pet) {
      return res.status(404).json({
        success: false,
        message: '未找到宠物档案'
      });
    }

    res.status(200).json({
      success: true,
      data: pet
    });
  } catch (error) {
    console.error('获取宠物档案错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    获取指定宠物详情
 * @route   GET /api/pets/:id
 * @access  Private
 */
exports.getPetById = async (req, res) => {
  try {
    const pet = await Pet.findById(req.params.id).populate('owner', 'username email');

    if (!pet) {
      return res.status(404).json({
        success: false,
        message: '未找到宠物'
      });
    }

    res.status(200).json({
      success: true,
      data: pet
    });
  } catch (error) {
    console.error('获取宠物详情错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    更新宠物档案
 * @route   PUT /api/pets/:id
 * @access  Private
 */
exports.updatePet = async (req, res) => {
  try {
    const { name, breed, birthday, gender, bio, weight, avatar } = req.body;

    // 查找宠物
    let pet = await Pet.findById(req.params.id);

    if (!pet) {
      return res.status(404).json({
        success: false,
        message: '未找到宠物'
      });
    }

    // 验证所有者
    if (pet.owner.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: '无权限修改此宠物档案'
      });
    }

    // 更新字段
    if (name) pet.name = name;
    if (breed) pet.breed = breed;
    if (birthday) pet.birthday = birthday;
    if (gender) pet.gender = gender;
    if (bio !== undefined) pet.bio = bio;
    if (weight !== undefined) pet.weight = weight;
    if (avatar !== undefined) pet.avatar = avatar;

    await pet.save();
    await pet.populate('owner', 'username email');

    res.status(200).json({
      success: true,
      data: pet,
      message: '宠物档案更新成功'
    });
  } catch (error) {
    console.error('更新宠物档案错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};

/**
 * @desc    删除宠物档案（软删除）
 * @route   DELETE /api/pets/:id
 * @access  Private
 */
exports.deletePet = async (req, res) => {
  try {
    const pet = await Pet.findById(req.params.id);

    if (!pet) {
      return res.status(404).json({
        success: false,
        message: '未找到宠物'
      });
    }

    // 验证所有者
    if (pet.owner.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: '无权限删除此宠物档案'
      });
    }

    // 软删除
    pet.isActive = false;
    await pet.save();

    res.status(200).json({
      success: true,
      message: '宠物档案已删除'
    });
  } catch (error) {
    console.error('删除宠物档案错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器错误',
      error: error.message
    });
  }
};
