const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');
const { v4: uuidv4 } = require('uuid');

// Ensure upload directory exists
const uploadDir = process.env.UPLOAD_DIR || './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueName = `${uuidv4()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

// File filter
const fileFilter = (req, file, cb) => {
  const allowedTypes = (process.env.ALLOWED_FILE_TYPES || 'image/jpeg,image/png,image/jpg,image/webp').split(',');

  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only JPEG, PNG, JPG, and WebP images are allowed.'), false);
  }
};

// Configure multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5242880 // 5MB default
  }
});

// Image optimization middleware
const optimizeImage = async (req, res, next) => {
  if (!req.files || req.files.length === 0) {
    return next();
  }

  try {
    for (const file of req.files) {
      const filePath = file.path;
      const optimizedPath = filePath.replace(path.extname(filePath), '_optimized' + path.extname(filePath));

      await sharp(filePath)
        .resize(1200, 1200, {
          fit: 'inside',
          withoutEnlargement: true
        })
        .jpeg({ quality: 85 })
        .toFile(optimizedPath);

      // Replace original with optimized
      fs.unlinkSync(filePath);
      fs.renameSync(optimizedPath, filePath);
    }

    next();
  } catch (error) {
    next(error);
  }
};

module.exports = {
  upload,
  optimizeImage
};
