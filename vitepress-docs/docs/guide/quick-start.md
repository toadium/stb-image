# Quick Start

This guide will help you get started with pycatia in minutes.

## Hello World

```python
from pycatia import catia

# Connect to running CATIA instance
application = catia()

# Get the active document
document = application.active_document
print(f"Active document: {document.name}")
```

## Working with Parts

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument
from pathlib import Path

application = catia()
documents = application.documents

# Open a part document
part_path = Path("my_part.CATPart")
part_document: PartDocument = documents.open(part_path)

# Access the part
part = part_document.part

# Create a point using hybrid shape factory
hsf = part.hybrid_shape_factory
point = hsf.add_new_point_coord(0, 0, 0)
point.name = "Origin"

# Update the part
part.update()

# Save and close
part_document.save()
part_document.close()
```

## Using the Context Manager

The `CATIADocHandler` provides automatic document cleanup:

```python
from pycatia import CATIADocHandler
from pycatia.mec_mod_interfaces.part_document import PartDocument
from pathlib import Path

part_path = Path("my_part.CATPart")

with CATIADocHandler(part_path) as caa:
    part_document: PartDocument = caa.document
    part = part_document.part
    # Do your work here
    part.update()
    # Document is automatically closed when exiting the context
```

## Working with Products

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
product = product_document.product

# List all products
for product in product.products:
    print(product.name)

# Navigate to a child product
child = product.products.item("ChildProduct.1")
```

## Selection and Measurement

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
selection = product_document.selection
selection.clear()

# Add selection filter
selection.add("Product", "HybridShape")

# Get measurable
spa = product_document.spa_workbench
measurable = spa.get_measurable(selection.item(1).value)
print(f"Volume: {measurable.volume}")
```

## Common Patterns

### Getting a Part from Active Document

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part
```

### Creating New Documents

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

### Accessing Parameters

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

# Get all parameters
params = part.parameters
root_set = params.root_parameter_set

# Create a parameter
length = root_set.create_string("Length", "100.0")
```
