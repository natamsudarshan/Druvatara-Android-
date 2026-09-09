const fs = require('fs');
const path = require('path');
const { DOMParser } = require('xmldom');
const JSZip = require('jszip');

async function extractDocx(filePath) {
    const content = fs.readFileSync(filePath);
    const zip = await JSZip.loadAsync(content);
    const docXml = await zip.file('word/document.xml').async('string');
    const parser = new DOMParser();
    const doc = parser.parseFromString(docXml, 'text/xml');
    const texts = doc.getElementsByTagName('w:t');
    let result = '';
    for (let i = 0; i < texts.length; i++) {
        result += texts[i].textContent + ' ';
    }
    return result;
}

const filePath = process.argv[2];
extractDocx(filePath).then(text => console.log(text)).catch(console.error);