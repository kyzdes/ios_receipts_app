const fs = require('fs');
const path = require('path');
const pool = require('../backend/src/config/database');

async function runMigrations() {
  const migrationsDir = path.join(__dirname, 'migrations');

  try {
    const files = fs.readdirSync(migrationsDir).sort();

    console.log('Starting database migrations...');

    for (const file of files) {
      if (file.endsWith('.sql')) {
        console.log(`Running migration: ${file}`);
        const filePath = path.join(migrationsDir, file);
        const sql = fs.readFileSync(filePath, 'utf8');

        await pool.query(sql);
        console.log(`✓ Completed: ${file}`);
      }
    }

    console.log('All migrations completed successfully!');
  } catch (error) {
    console.error('Migration failed:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

runMigrations().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
