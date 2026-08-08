# Product Examples

Examples for working with CATIA product structures and assemblies.

## Navigate Product Tree

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
product = product_document.product

# List all products
for product in product.products:
    print(product.name)
```

## Generate CATPart Files

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: PartDocument = application.active_document
product = product_document.product

# Generate all referenced parts
product.generate_all_catparts()
```

## Product Properties

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
product = product_document.product

# Get product name
print(f"Product: {product.name}")

# Get product type
print(f"Type: {product.type}")

# Get children
for child in product.products:
    print(f"Child: {child.name}")
```

## Working with Constraints

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
product = product_document.product

# Access constraints
constraints = product.constraints
for constraint in constraints:
    print(f"Constraint: {constraint.name}")
```

## Product Parameters

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
product = product_document.product

# Access parameters
params = product.parameters
root_set = params.root_parameter_set

for param_set in root_set.parameter_sets:
    print(f"Parameter set: {param_set.name}")
    for param in param_set.all_parameters:
        print(f"  {param.name} = {param.value}")
```
