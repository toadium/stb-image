# Save Parts to STEP

Export child parts from a product to STEP format.

## Usage

```python
python save_child_parts_to_stp.py
```

## How It Works

1. Opens the active product document
2. Recursively finds all child parts
3. Exports each part to STEP format
4. Saves to the specified directory

## Code Example

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument
from pathlib import Path

application = catia()
product_document: ProductDocument = application.active_document

# Get all referenced parts
parts = product_document.get_all_parts()

for part in parts:
    output_path = Path(f"output/{part.name}.stp")
    part.export_data(output_path, "stp")
```
