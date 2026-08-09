# Selection

The Selection object allows you to interact with user selections and programmatically select elements.

## Getting Selection

```python
from pycatia import catia

application = catia()
document = application.active_document
selection = document.selection
```

## Clearing Selection

```python
selection.clear()
```

## Adding to Selection

```python
from pycatia.product_structure_interfaces.product import Product

product = ...  # get a product object
selection.add(product)
```

## Selecting by Filter

```python
# Select all products
selection.add("Product", "HybridShape")

# Select by name
selection.add("Product.1", "Product")
```

## Selection Methods

| Method | Description |
|--------|-------------|
| `clear()` | Clear selection |
| `add(element)` | Add element to selection |
| `remove(element)` | Remove element from selection |
| `count()` | Get selection count |
| `item(index)` | Get item at index |
| `search(filter, search_type)` | Search for elements |

## Selection Search

```python
# Search for products
selection.search("Product", "All")

# Search for geometry
selection.search("HybridShape", "All")
```

## Indicating Selection

```python
# Prompt user to select an element
result = selection.indicate("Select a product", "Product")
```

## Getting Selected Elements

```python
for i in range(selection.count()):
    element = selection.item(i + 1)  # 1-based indexing
    print(element.name)
```

## Practical Example

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
selection = product_document.selection
selection.clear()

# Select a product by name
product = product_document.product.products.item("Product.1")
selection.add(product)

# Get measurable for selected element
spa = product_document.spa_workbench
measurable = spa.get_measurable(selection.item(1).value)

print(f"Volume: {measurable.volume}")
print(f"Surface Area: {measurable.surface}")
```
