const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const projectRoot = __dirname;
const workspaceRoot = path.resolve(projectRoot, '../..');

const config = getDefaultConfig(projectRoot);

// Watch all files within the monorepo
config.watchFolders = [workspaceRoot];

// Ensure Metro can resolve packages from the workspace
config.resolver.nodeModulesPaths = [
  path.resolve(projectRoot, 'node_modules'),
  path.resolve(workspaceRoot, 'node_modules'),
];

// Include workspace packages in the module resolution
config.resolver.disableHierarchicalLookup = true;

module.exports = config;