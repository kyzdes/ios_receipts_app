const pool = require('../config/database');
const bcrypt = require('bcrypt');

class User {
  static async create({ email, password, username }) {
    const passwordHash = await bcrypt.hash(password, 10);
    const query = `
      INSERT INTO users (email, password_hash, username)
      VALUES ($1, $2, $3)
      RETURNING id, email, username, created_at
    `;
    const result = await pool.query(query, [email, passwordHash, username]);
    return result.rows[0];
  }

  static async findByEmail(email) {
    const query = 'SELECT * FROM users WHERE email = $1';
    const result = await pool.query(query, [email]);
    return result.rows[0];
  }

  static async findById(id) {
    const query = 'SELECT id, email, username, created_at, updated_at FROM users WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  static async verifyPassword(plainPassword, hashedPassword) {
    return await bcrypt.compare(plainPassword, hashedPassword);
  }

  static async updatePassword(userId, newPassword) {
    const passwordHash = await bcrypt.hash(newPassword, 10);
    const query = 'UPDATE users SET password_hash = $1 WHERE id = $2';
    await pool.query(query, [passwordHash, userId]);
  }
}

module.exports = User;
