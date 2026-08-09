# Parameters Examples

Examples for working with CATIA parameters and knowledge engine.

## Access Parameters

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

# Get all parameters
params = part.parameters
root_set = params.root_parameter_set

# Iterate parameter sets
for param_set in root_set.parameter_sets:
    print(f"Set: {param_set.name}")
    for param in param_set.all_parameters:
        print(f"  {param.name} = {param.value}")
```

## Create Parameters

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

params = part.parameters
root_set = params.root_parameter_set

# Create string parameter
length = root_set.create_string("Length", "100.0")

# Create boolean parameter
activate = root_set.create_boolean("Activate", True)

# Create integer parameter
count = root_set.create_integer("Count", 10)

# Create dimensional parameter
angle = root_set.create_dimension("Angle", "deg", 45.0)
```

## Get Parameter Value

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

params = part.parameters

# Get parameter by name
param = params.item("Length")

# Get value
value = param.value
value_string = param.value_as_string()

print(f"Length = {value_string}")
```

## Set Parameter Value

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

params = part.parameters
param = params.item("Length")

# Set value
param.value = 200.0
param.value_as_string = "150.5"

part.update()
```

## Create Formulas

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

relations = part.relations
params = part.parameters

# Get parameters
width = params.item("Width")
depth = params.item("Depth")
area = params.create_dimension("Area", "mm*mm", 0.0)

# Create formula
relations.create_formula(
    "Area_Formula",
    "Calculate area",
    area,
    width.name,
    depth.name
)

part.update()
```

## List All Parameter Sets

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

params = part.parameters
root = params.root_parameter_set

def print_parameters(param_set, indent=0):
    prefix = "  " * indent
    print(f"{prefix}{param_set.name}")
    for param in param_set.all_parameters:
        print(f"{prefix}  - {param.name}: {param.value}")
    for child in param_set.parameter_sets:
        print_parameters(child, indent + 1)

print_parameters(root)
```
