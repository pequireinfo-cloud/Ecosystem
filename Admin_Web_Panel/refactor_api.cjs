const fs = require('fs');
const path = require('path');

const srcDir = path.join(__dirname, 'src');

function walk(dir) {
  const files = fs.readdirSync(dir);
  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stats = fs.statSync(filePath);
    if (stats.isDirectory()) {
      walk(filePath);
    } else if (file.endsWith('.jsx')) {
      refactorFile(filePath);
    }
  });
}

function refactorFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  
  // Skip files already refactored
  if (content.includes("import api from '../utils/api'")) return;

  // Determine relative path to utils/api
  // All our files are in src/pages or src/components
  const relativeImport = "import api from '../utils/api';";
  
  let changed = false;

  // Replace import
  if (content.includes("import axios from 'axios';")) {
    content = content.replace("import axios from 'axios';", relativeImport);
    changed = true;
  }

  // Replace axios calls (handle both single and double quotes)
  const regex = /axios\.(get|post|put|delete)\(['"]http:\/\/localhost:3000\/api([^'"]*)['"]/g;
  if (regex.test(content)) {
    content = content.replace(regex, "api.$1('$2'");
    changed = true;
  }

  if (changed) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`Refactored: ${filePath}`);
  }
}

walk(srcDir);
