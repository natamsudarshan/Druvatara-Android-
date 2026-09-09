using System;
using System.IO;
using System.IO.Compression;
using System.Xml.Linq;

class Program {
    static void Main(string[] args) {
        string filePath = args[0];
        using (ZipArchive archive = ZipFile.OpenRead(filePath)) {
            var entry = archive.GetEntry("word/document.xml");
            if (entry != null) {
                using (var stream = entry.Open()) {
                    XDocument doc = XDocument.Load(stream);
                    XNamespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
                    var texts = doc.Descendants(w + "t").Select(e => e.Value);
                    Console.WriteLine(string.Join(" ", texts));
                }
            }
        }
    }
}