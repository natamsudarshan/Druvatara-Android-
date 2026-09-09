Add-Type -AssemblyName DocumentFormat.OpenXml
$doc = [DocumentFormat.OpenXml.Packaging.WordprocessingDocument]::Open('001-Executive Vision & Product Strategy Document.docx', $false)
$body = $doc.MainDocumentPart.Document.Body
$text = $body.InnerText
Write-Host $text
$doc.Close()