# Rename Instances in Product

Sort and rename product tree instances alphabetically.

## Usage

```python
python rename_instances_in_product.py
```

## Requirements

```bash
pip install pywinauto natsort
```

## How It Works

1. Selects the root product
2. Opens the Graph Tree Reordering command
3. Uses pywinauto to automate the dialog
4. Sorts the product tree alphabetically

## Code Example

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument
from pywinauto import Desktop
from natsort import natsorted

application = catia()
product_document: ProductDocument = application.active_document
product = product_document.product

# Use pywinauto to automate the reordering dialog
# (see full example in repository)
```
