# Document Examples

Examples for opening, creating, and managing CATIA documents.

## Open Document with Context Manager

```python
from pycatia import CATIADocHandler
from pycatia.mec_mod_interfaces.part_document import PartDocument
from pathlib import Path

part_path = Path("tests/cat_files/part_measurable.CATPart")

with CATIADocHandler(part_path) as caa:
    part_document: PartDocument = caa.document
    part = part_document.part
    # Do work
    part.update()
    # Document automatically closed
```

## Open Document Manually

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument
from pathlib import Path

application = catia()
documents = application.documents

part_document: PartDocument = documents.open(Path("part.CATPart"))
part = part_document.part

# Do work
part.update()

# Clean up
part_document.save()
part_document.close()
```

## Create New Document

```python
from pycatia import catia

application = catia()
documents = application.documents

# Create new part
part_doc = documents.add('Part')

# Create new product
product_doc = documents.add('Product')

# Create new drawing
drawing_doc = documents.add('Drawing')
```

## List Open Documents

```python
from pycatia import catia

application = catia()
documents = application.documents

for doc in documents:
    print(f"Document: {doc.name} (Type: {doc.type})")
```

## Check Document Type

```python
from pycatia import catia

application = catia()
document = application.active_document

if document.type == "Part":
    from pycatia.mec_mod_interfaces.part_document import PartDocument
    part_doc = document
elif document.type == "Product":
    from pycatia.product_structure_interfaces.product_document import ProductDocument
    product_doc = document
elif document.type == "Drawing":
    from pycatia.drafting_interfaces.drawing_document import DrawingDocument
    drawing_doc = document
```
