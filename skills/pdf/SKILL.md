---
name: pdf
description: PDF processing and manipulation. Use when user needs to read, create, merge, split, extract text/tables from PDFs, or convert documents. Triggers on "pdf", "extract text from pdf", "merge pdfs", "split pdf", "pdf to text".
---

# PDF Processing

## Quick Reference

| Task | Library | Command |
|------|---------|---------|
| Extract text | pdfplumber | `page.extract_text()` |
| Extract tables | pdfplumber | `page.extract_tables()` |
| Merge PDFs | pypdf | `PdfMerger()` |
| Split PDF | pypdf | `PdfReader/PdfWriter` |
| Create PDF | reportlab | `canvas.Canvas()` |
| CLI text extract | poppler | `pdftotext file.pdf` |

## Installation

```bash
pip install pypdf pdfplumber reportlab
# CLI tools (macOS)
brew install poppler qpdf
```

## Text Extraction (pdfplumber)

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        print(text)
```

### Extract with layout preservation

```python
text = page.extract_text(layout=True)
```

## Table Extraction (pdfplumber)

```python
import pdfplumber
import pandas as pd

with pdfplumber.open("document.pdf") as pdf:
    page = pdf.pages[0]
    tables = page.extract_tables()

    for table in tables:
        df = pd.DataFrame(table[1:], columns=table[0])
        print(df)
```

## Merge PDFs (pypdf)

```python
from pypdf import PdfMerger

merger = PdfMerger()
merger.append("file1.pdf")
merger.append("file2.pdf")
merger.append("file3.pdf", pages=(0, 3))  # Only pages 0-2
merger.write("merged.pdf")
merger.close()
```

## Split PDF (pypdf)

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("document.pdf")

# Extract single page
writer = PdfWriter()
writer.add_page(reader.pages[0])
writer.write("page1.pdf")

# Extract page range
writer = PdfWriter()
for page in reader.pages[2:5]:
    writer.add_page(page)
writer.write("pages_3_to_5.pdf")
```

## Get Metadata (pypdf)

```python
from pypdf import PdfReader

reader = PdfReader("document.pdf")
meta = reader.metadata

print(f"Title: {meta.title}")
print(f"Author: {meta.author}")
print(f"Pages: {len(reader.pages)}")
```

## Rotate Pages (pypdf)

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("document.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.rotate(90)  # 90, 180, 270
    writer.add_page(page)

writer.write("rotated.pdf")
```

## Create PDF (reportlab)

```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

c = canvas.Canvas("output.pdf", pagesize=letter)
c.drawString(100, 750, "Hello, World!")
c.drawString(100, 730, "This is a PDF created with reportlab.")
c.showPage()
c.save()
```

### Multi-page with styles

```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("styled.pdf", pagesize=letter)
styles = getSampleStyleSheet()
story = []

story.append(Paragraph("Document Title", styles['Heading1']))
story.append(Spacer(1, 12))
story.append(Paragraph("This is body text.", styles['Normal']))
story.append(Spacer(1, 12))
story.append(Paragraph("Another paragraph.", styles['Normal']))

doc.build(story)
```

## CLI Tools

### pdftotext (poppler)

```bash
# Basic extraction
pdftotext document.pdf output.txt

# Preserve layout
pdftotext -layout document.pdf output.txt

# Specific pages
pdftotext -f 1 -l 5 document.pdf output.txt
```

### qpdf

```bash
# Merge
qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf

# Split (extract pages 1-5)
qpdf document.pdf --pages . 1-5 -- output.pdf

# Rotate all pages
qpdf document.pdf --rotate=90 rotated.pdf

# Decrypt
qpdf --decrypt encrypted.pdf decrypted.pdf
```

## OCR for Scanned PDFs

```python
import pytesseract
from pdf2image import convert_from_path

# Convert PDF pages to images
images = convert_from_path("scanned.pdf")

# OCR each page
for i, image in enumerate(images):
    text = pytesseract.image_to_string(image)
    print(f"--- Page {i+1} ---")
    print(text)
```

Requires: `pip install pytesseract pdf2image` and Tesseract installed (`brew install tesseract`).
