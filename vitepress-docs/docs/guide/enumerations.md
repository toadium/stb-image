# Enumerations

pycatia provides Python IntEnum classes for CATIA constants and enumerations.

## Using Enumerations

```python
from pycatia import catia
from pycatia.enumeration.enums import (
    catShapeType,
    catProductStructureNodeKind,
    mjtState
)

# Use enum values instead of magic numbers
application = catia()
```

## Common Enumerations

### Shape Types

```python
from pycatia.enumeration.enums import catShapeType

# Instead of using magic numbers
point_shape = catShapeType.CatShapePoint
line_shape = catShapeType.CatShapeLine
```

### Product Structure

```python
from pycatia.enumeration.enums import catProductStructureNodeKind

instance = catProductStructureNodeKind.catProductStructureNodeInstance
reference = catProductStructureNodeKind.catProductStructureNodeReference
```

### State Flags

```python
from pycatia.enumeration.enums import mjtState

full_state = mjtState.mjSTATE_FULLPHYSICS
position_state = mjtState.mjSTATE_POSITIONS
```

## Available Enum Modules

| Module | Description |
|--------|-------------|
| `enums.py` | Python IntEnum classes |
| `enumeration_types.py` | Tuple-based enumerations (legacy) |

## Migration from Tuples

```python
# Old style (still supported)
from pycatia.enumeration.enumeration_types import catShapeType

# New style (recommended)
from pycatia.enumeration.enums import catShapeType
```

## Practical Example

```python
from pycatia import catia
from pycatia.enumeration.enums import catShapeType

application = catia()
part_document = application.active_document
part = part_document.part

hsf = part.hybrid_shape_factory

# Create a point using enum
point = hsf.add_new_point_coord(0, 0, 0)
point.name = "Origin"

# Get shape type
shape_type = hsf.get_geometrical_feature_type(part.create_reference_from_object(point))
if shape_type == catShapeType.CatShapePoint:
    print("It's a point!")
```
