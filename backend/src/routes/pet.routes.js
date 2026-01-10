const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');

// @desc    Get all pets for current user
// @route   GET /api/v1/pets
// @access  Private
router.get('/', protect, (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Get pets - Coming soon'
  });
});

// @desc    Add new pet
// @route   POST /api/v1/pets
// @access  Private
router.post('/', protect, (req, res) => {
  res.status(201).json({
    success: true,
    message: 'Add pet - Coming soon'
  });
});

module.exports = router;
