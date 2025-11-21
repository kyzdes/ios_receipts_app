const Folder = require('../models/Folder');

const createFolder = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const folder = await Folder.create(userId, req.body);

    res.status(201).json({
      message: 'Folder created successfully',
      folder
    });
  } catch (error) {
    next(error);
  }
};

const getFolders = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const folders = await Folder.findAll(userId);

    res.json({ folders });
  } catch (error) {
    next(error);
  }
};

const getFolderById = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const folder = await Folder.findById(id, userId);
    if (!folder) {
      return res.status(404).json({ error: 'Folder not found' });
    }

    res.json({ folder });
  } catch (error) {
    next(error);
  }
};

const updateFolder = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const folder = await Folder.update(id, userId, req.body);
    if (!folder) {
      return res.status(404).json({ error: 'Folder not found' });
    }

    res.json({
      message: 'Folder updated successfully',
      folder
    });
  } catch (error) {
    next(error);
  }
};

const deleteFolder = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const deleted = await Folder.delete(id, userId);
    if (!deleted) {
      return res.status(404).json({ error: 'Folder not found' });
    }

    res.json({ message: 'Folder deleted successfully' });
  } catch (error) {
    next(error);
  }
};

const addRecipeToFolder = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { folderId, recipeId } = req.params;

    await Folder.addRecipeToFolder(recipeId, folderId, userId);

    res.json({ message: 'Recipe added to folder successfully' });
  } catch (error) {
    next(error);
  }
};

const removeRecipeFromFolder = async (req, res, next) => {
  try {
    const { folderId, recipeId } = req.params;

    await Folder.removeRecipeFromFolder(recipeId, folderId);

    res.json({ message: 'Recipe removed from folder successfully' });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createFolder,
  getFolders,
  getFolderById,
  updateFolder,
  deleteFolder,
  addRecipeToFolder,
  removeRecipeFromFolder
};
