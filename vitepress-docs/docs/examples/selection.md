# Selection Examples

Examples for working with CATIA selections and user interaction.

## Clear Selection

```python
from pycatia import catia

application = catia()
document = application.active_document
selection = document.selection
selection.clear()
```

## Add to Selection

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
selection = part_document.selection
selection.clear()

# Add a product to selection
product = part_document.product.products.item("Product.1")
selection.add(product)
```

## Selection by Filter

```python
from pycatia import catia

application = catia()
document = application.active_document
selection = document.selection

# Select all products
selection.search("Product", "All")

# Select all hybrid shapes
selection.search("HybridShape", "All")
```

## Get Selection Count

```python
from pycatia import catia

application = catia()
document = application.active_document
selection = document.selection

count = selection.count()
print(f"Selected elements: {count}")

for i in range(1, count + 1):
    element = selection.item(i)
    print(f"Element {i}: {element.name}")
```

## User Selection Prompt

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
selection = product_document.selection
selection.clear()

# Prompt user to select
input("Select a product, then press ENTER...")

# Get selected element
if selection.count() > 0:
    selected = selection.item(1)
    print(f"Selected: {selected.name}")
```

## Indicate Element

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
selection = product_document.selection

# Indicate a product
result = selection.indicate("Select a product", "Product")

if result == "Cancel":
    print("User cancelled")
else:
    element = selection.item(1)
    print(f"Selected: {element.name}")
```
