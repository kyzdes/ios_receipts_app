const express = require('express');
const { body } = require('express-validator');
const folderController = require('../controllers/folderController');
const { authenticateToken } = require('../middleware/auth');
const { validate } = require('../middleware/validation');

const router = express.Router();

// Validation rules
const folderValidation = [
  body('name').notEmpty().trim(),
  body('parent_folder_id').optional().isUUID(),
  validate
];

// All routes require authentication
router.use(authenticateToken);

// Folder CRUD
router.post('/', folderValidation, folderController.createFolder);
router.get('/', folderController.getFolders);
router.get('/:id', folderController.getFolderById);
router.put('/:id', folderController.updateFolder);
router.delete('/:id', folderController.deleteFolder);

// Recipe-Folder associations
router.post('/:folderId/recipes/:recipeId', folderController.addRecipeToFolder);
router.delete('/:folderId/recipes/:recipeId', folderController.removeRecipeFromFolder);

module.exports = router;
