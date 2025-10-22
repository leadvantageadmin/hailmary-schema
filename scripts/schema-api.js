const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();
const port = process.env.PORT || 3001;

// Middleware
app.use(express.json());

// Get schema version
app.get('/api/schema/version/:version', (req, res) => {
  const version = req.params.version;
  const versionPath = path.join(__dirname, '..', 'versions', version);
  
  try {
    if (!fs.existsSync(versionPath)) {
      return res.status(404).json({ error: 'Schema version not found' });
    }
    
    const schemaPath = path.join(versionPath, 'schema.prisma');
    const metadataPath = path.join(versionPath, 'metadata.json');
    
    if (!fs.existsSync(schemaPath)) {
      return res.status(404).json({ error: 'Schema file not found' });
    }
    
    const schema = fs.readFileSync(schemaPath, 'utf8');
    const metadata = fs.existsSync(metadataPath) 
      ? JSON.parse(fs.readFileSync(metadataPath, 'utf8'))
      : null;
    
    res.json({
      version,
      schema,
      metadata
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Client endpoints removed - client generation support has been discontinued

// List available versions
app.get('/api/schema/versions', (req, res) => {
  try {
    const versionsPath = path.join(__dirname, '..', 'versions');
    const versions = fs.readdirSync(versionsPath)
      .filter(item => {
        const itemPath = path.join(versionsPath, item);
        return fs.statSync(itemPath).isDirectory() && item !== 'latest';
      })
      .sort((a, b) => {
        // Sort versions (simple string sort for now)
        return b.localeCompare(a);
      });
    
    res.json({ versions });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get latest version
app.get('/api/schema/latest', (req, res) => {
  try {
    const latestPath = path.join(__dirname, '..', 'versions', 'latest');
    
    if (!fs.existsSync(latestPath)) {
      return res.status(404).json({ error: 'Latest version not found' });
    }
    
    const realPath = fs.readlinkSync(latestPath);
    const version = path.basename(realPath);
    
    const metadataPath = path.join(latestPath, 'metadata.json');
    const metadata = fs.existsSync(metadataPath) 
      ? JSON.parse(fs.readFileSync(metadataPath, 'utf8'))
      : null;
    
    res.json({
      version,
      metadata
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get migrations for version
app.get('/api/schema/migrations/:version', (req, res) => {
  const version = req.params.version;
  const migrationsPath = path.join(__dirname, '..', 'migrations', version);
  
  try {
    if (!fs.existsSync(migrationsPath)) {
      return res.status(404).json({ error: 'Migrations not found' });
    }
    
    const migrations = fs.readdirSync(migrationsPath)
      .filter(file => file.endsWith('.sql'))
      .sort();
    
    const migrationContents = migrations.map(file => {
      const content = fs.readFileSync(path.join(migrationsPath, file), 'utf8');
      return {
        file,
        content
      };
    });
    
    res.json({
      version,
      migrations: migrationContents
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    version: process.env.SCHEMA_VERSION || 'latest'
  });
});

// Start server
app.listen(port, () => {
  console.log(`Schema API running on port ${port}`);
  console.log(`Schema version: ${process.env.SCHEMA_VERSION || 'latest'}`);
});
