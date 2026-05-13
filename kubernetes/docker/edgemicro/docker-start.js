const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const os = require('os');

const apigeeRoot = '/opt/apigee';
const configDir = path.join(os.homedir(), '.edgemicro');

// Ensure directories exist
fs.mkdirSync(configDir, { recursive: true });
fs.mkdirSync(path.join(apigeeRoot, 'logs'), { recursive: true });
fs.mkdirSync(path.join(apigeeRoot, 'plugins'), { recursive: true });

// Decode base64 config if provided
if (process.env.EDGEMICRO_CONFIG) {
    const org = process.env.EDGEMICRO_ORG || 'default';
    const env = process.env.EDGEMICRO_ENV || 'default';
    const configPath = path.join(configDir, `${org}-${env}-config.yaml`);
    const decoded = Buffer.from(process.env.EDGEMICRO_CONFIG, 'base64').toString('utf8');
    fs.writeFileSync(configPath, decoded);
}

// Prepare start arguments
const args = ['start'];
if (process.env.EDGEMICRO_ORG) args.push('-o', process.env.EDGEMICRO_ORG);
if (process.env.EDGEMICRO_ENV) args.push('-e', process.env.EDGEMICRO_ENV);
if (process.env.EDGEMICRO_KEY) args.push('-k', process.env.EDGEMICRO_KEY);
if (process.env.EDGEMICRO_SECRET) args.push('-s', process.env.EDGEMICRO_SECRET);

const port = process.env.EDGEMICRO_PORT || '8000';
args.push('-r', port);

const pluginDir = process.env.EDGEMICRO_PLUGIN_DIR || path.join(apigeeRoot, 'plugins');
args.push('-d', pluginDir);

if (process.env.EDGEMICRO_PROCESSES) {
    args.push('-p', process.env.EDGEMICRO_PROCESSES);
}

console.log(`Starting edgemicro with args: ${args.join(' ')}`);

const cliScript = '/app/node_modules/edgemicro/cli/edgemicro';
const child = spawn(process.execPath, [cliScript, ...args], { stdio: 'inherit' });

process.on('SIGTERM', () => {
    console.log('Received SIGTERM, stopping edgemicro...');
    child.kill('SIGTERM');
});

process.on('SIGINT', () => {
    console.log('Received SIGINT, stopping edgemicro...');
    child.kill('SIGINT');
});
