# Part & Product

Working with parts and products is the core of pycatia usage.

## PartDocument

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part
```

## Part Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | str | Part name |
| `path` | Path | Full path to part file |
| `bodies` | Bodies | Collection of geometric bodies |
| `hybrid_bodies` | HybridBodies | Collection of hybrid bodies |
| `parameters` | Parameters | Parameter collection |
| `relations` | Relations | Knowledge relations |
| `annotation_sets` | AnnotationSets | Annotation sets |

## Part Methods

```python
# Update the part
part.update()

# Get a shape by name
shape = part.get_hybrid_shape_by_name("MyShape")

# Create reference
reference = part.create_reference_from_object(shape)
```

## ProductDocument

```python
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
product = product_document.product
```

## Product Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | str | Product name |
| `products` | Products | Child products collection |
| `products_reference` | ProductsReference | Reference products |
| `constraints` | Constraints | Product constraints |
| `parameters` | Parameters | Product parameters |

## Product Methods

```python
# Generate all CATPart files
product.generate_all_catparts()

# Activate terminal mode
product.activate_terminal_mode()

# Move product
product.move(target_position)
```

## Getting Document Type

```python
from pycatia import catia

application = catia()
document = application.active_document

if document.type == "Part":
    part_doc = document
elif document.type == "Product":
    product_doc = document
elif document.type == "Drawing":
    drawing_doc = document
```

## Document Handler

```python
from pycatia import CATIADocHandler
from pycatia.mec_mod_interfaces.part_document import PartDocument
from pathlib import Path

part_path = Path("my_part.CATPart")

with CATIADocHandler(part_path) as caa:
    part_document: PartDocument = caa.document
    part = part_document.part
    # Work with part
    part.update()
```
