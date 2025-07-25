const fs = require('fs');
const path = require('path');

const rootDir = path.join(__dirname, '..');
const envExamplePath = path.join(rootDir, '.env.sample');
const envPath = path.join(rootDir, '.env');

function setupEnvironment() {
  console.log('Setting up environment files...');

  // Check if .env already exists
  if (fs.existsSync(envPath)) {
    console.log('✅ .env file already exists');
    return;
  }

  // Check if .env.sample exists
  if (!fs.existsSync(envExamplePath)) {
    console.error('❌ .env.sample file not found');
    process.exit(1);
  }

  // Copy .env.sample to .env
  try {
    fs.copyFileSync(envExamplePath, envPath);
    console.log('✅ Created .env file from .env.sample');
    console.log('⚠️  Please update the .env file with your actual configuration values');
  } catch (error) {
    console.error('❌ Failed to create .env file:', error.message);
    process.exit(1);
  }

  // Create app-specific env files if needed
  const apps = ['api', 'mobile'];
  apps.forEach(app => {
    const appEnvPath = path.join(rootDir, 'apps', app, '.env');
    const appEnvExamplePath = path.join(rootDir, 'apps', app, '.env.example');
    
    if (fs.existsSync(appEnvExamplePath) && !fs.existsSync(appEnvPath)) {
      try {
        fs.copyFileSync(appEnvExamplePath, appEnvPath);
        console.log(`✅ Created apps/${app}/.env file`);
      } catch (error) {
        console.warn(`⚠️  Could not create apps/${app}/.env:`, error.message);
      }
    }
  });
}

if (require.main === module) {
  setupEnvironment();
}

module.exports = { setupEnvironment };