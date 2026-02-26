const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  createPet,
  getMyPet,
  getPetById,
  updatePet,
  deletePet
} = require('../controllers/pet.controller');

// 所有路由都需要身份验证
router.use(protect);

// 创建宠物档案
router.post('/', createPet);

// 获取当前用户的宠物
router.get('/my-pet', getMyPet);

// 获取指定宠物详情
router.get('/:id', getPetById);

// 更新宠物档案
router.put('/:id', updatePet);

// 删除宠物档案
router.delete('/:id', deletePet);

module.exports = router;
