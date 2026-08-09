# Drafting Examples

Examples for working with CATIA 2D drawings.

## Create Drawing View

```python
from pycatia import catia
from pycatia.drafting_interfaces.drawing_document import DrawingDocument

application = catia()
drawing_doc: DrawingDocument = application.active_document

# Get drawing views
views = drawing_doc.views
for view in views:
    print(f"View: {view.name}")
```

## Get Drawing Sheet

```python
from pycatia import catia
from pycatia.drafting_interfaces.drawing_document import DrawingDocument

application = catia()
drawing_doc: DrawingDocument = application.active_document

# Get current sheet
sheet = drawing_doc.sheets.current_sheet
print(f"Sheet: {sheet.name}")

# Get paper size
paper_size = sheet.paper_size
print(f"Paper size: {paper_size}")
```

## Add Dimension

```python
from pycatia import catia
from pycatia.drafting_interfaces.drawing_document import DrawingDocument

application = catia()
drawing_doc: DrawingDocument = application.active_document

factory_2d = drawing_doc.factory_2d

# Add linear dimension
dimension = factory_2d.create_linear_dimension(
    point1,    # Start point
    point2,    # End point
    offset     # Offset distance
)
```

## Drawing Text

```python
from pycatia import catia
from pycatia.drafting_interfaces.drawing_document import DrawingDocument

application = catia()
drawing_doc: DrawingDocument = application.active_document

# Get 2D factory
factory_2d = drawing_doc.factory_2d

# Add text
text = factory_2d.create_text(
    x, y,       # Position
    "Hello",    # Text content
    font_size   # Font size
)
```

## Export Drawing

```python
from pycatia import catia
from pycatia.drafting_interfaces.drawing_document import DrawingDocument
from pathlib import Path

application = catia()
drawing_doc: DrawingDocument = application.active_document

# Export to PDF
pdf_path = Path("drawing.pdf")
drawing_doc.export_data(pdf_path, "pdf")
```
