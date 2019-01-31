const path = require('path');
const fs = require('fs');
const solc = require('solc');

const crudUSPath = path.resolve(__dirname, 'contracts', 'crudUS.sol');
const source = fs.readFileSync(crudUSPath, 'utf8');

module.exports = solc.compile(source, 1).contracts[':crudUS'];