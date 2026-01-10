const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');

// @desc    Get user profile
// @route   GET /api/v1/users/:id
// @access  Private
router.get('/:id', protect, (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Get user profile - Coming soon'
  });
});

// @desc    Update user profile
// @route   PUT /api/v1/users/:id
// @access  Private
router.put('/:id', protect, (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Update user profile - Coming soon'
  });
});

module.exports = router;
