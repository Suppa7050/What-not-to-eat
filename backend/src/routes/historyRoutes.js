const express = require('express');
const router = express.Router();
const { getHistory, getScanById, deleteScan } = require('../controllers/historyController');
const { verifyToken } = require('../middlewares/authMiddleware');

router.get('/', verifyToken, getHistory);
router.get('/:id', verifyToken, getScanById);
router.delete('/:id', verifyToken, deleteScan);

module.exports = router;
