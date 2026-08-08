# Documents

The Documents collection manages all open CATIA documents.

## Getting Documents

```python
from pycatia import catia

application = catia()
documents = application.documents
```

## Opening Documents

```python
from pathlib import Path
from pycatia.mec_mod_interfaces.part_document import PartDocument

# Open by path
part_doc: PartDocument = documents.open(Path("my_part.CATPart"))

# Open by string path
part_doc = documents.open("my_part.CATPart")

# Open with read-only
part_doc = documents.open("my_part.CATPart", False)
```

## Creating Documents

```python
# Create new part
part_doc = documents.add('Part')

# Create new product
product_doc = documents.add('Product')

# Create new drawing
drawing_doc = documents.add('Drawing')
```

## Available Document Types

| Type | Description |
|------|-------------|
| `Part` | CAD part document |
| `Product` | Product assembly document |
| `Drawing` | 2D drawing document |
| `Analysis` | Analysis document |
| `CATMaterial` | Material catalog |
| `CATProcess` | Process document |
| `CatalogDocument` | Catalog document |

## Closing Documents

```python
part_doc.close()

# Close without saving
part_doc.close(skip_save=True)
```

## Iterating Documents

```python
for doc in documents:
    print(doc.name)
```

## Current Documents

```python
# Get count of open documents
count = len(documents)

# Check if document exists
exists = documents.is_file("my_part.CATPart")
```
