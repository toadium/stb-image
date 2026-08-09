# Context Manager

The `CATIADocHandler` provides a convenient context manager for document handling.

## Basic Usage

```python
from pycatia import CATIADocHandler
from pycatia.mec_mod_interfaces.part_document import PartDocument
from pathlib import Path

part_path = Path("my_part.CATPart")

with CATIADocHandler(part_path) as caa:
    part_document: PartDocument = caa.document
    part = part_document.part
    # Do work
    part.update()
    # Document automatically closed
```

## With Application

```python
from pycatia import CATIADocHandler
from pycatia.product_structure_interfaces.product_document import ProductDocument

product_path = Path("my_product.Product")

with CATIADocHandler(product_path) as caa:
    product_document: ProductDocument = caa.document
    product = product_document.product
    # Modify product structure
    product.generate_all_catparts()
```

## Creating New Documents

```python
from pycatia import CATIADocHandler
from pycatia.mec_mod_interfaces.part_document import PartDocument

# Create new part
with CATIADocHandler(new_doc="Part") as caa:
    part_document: PartDocument = caa.document
    part = part_document.part
    # Build part
    part.update()
    part_document.save_as(Path("new_part.CATPart"))
```

## Exceptions

```python
from pycatia import CATIADocHandler

try:
    with CATIADocHandler("nonexistent.CATPart") as caa:
        pass
except FileNotFoundError:
    print("File not found")
except COMError as e:
    print(f"COM error: {e}")
```

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `document` | Document | The opened document |
| `application` | Application | CATIA application object |
| `selection` | Selection | Document selection |

## Comparison with Manual Handling

```python
# Manual approach
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
documents = application.documents
part_document: PartDocument = documents.open("part.CATPart")
try:
    part = part_document.part
    part.update()
finally:
    part_document.close()

# Context manager approach (cleaner)
from pycatia import CATIADocHandler
from pycatia.mec_mod_interfaces.part_document import PartDocument

with CATIADocHandler("part.CATPart") as caa:
    part_document: PartDocument = caa.document
    part = part_document.part
    part.update()
    # Automatic cleanup
```
