# Save Drawings to PDF

Export CATIA drawings to PDF format.

## Usage

```python
python save_drawings_to_pdf.py
```

## How It Works

1. Opens the active drawing document
2. Iterates through all sheets
3. Exports each sheet to PDF
4. Saves to the specified output directory

## Requirements

- CATIA V5 running
- A drawing document open

## Code Example

```python
from pycatia import catia
from pycatia.drafting_interfaces.drawing_document import DrawingDocument
from pathlib import Path

application = catia()
drawing_doc: DrawingDocument = application.active_document

# Get all sheets
sheets = drawing_doc.sheets

for sheet in sheets:
    # Export sheet to PDF
    output_path = Path(f"output/{sheet.name}.pdf")
    drawing_doc.export_data(output_path, "pdf")
```
