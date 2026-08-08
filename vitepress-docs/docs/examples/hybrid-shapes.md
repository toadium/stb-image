# Hybrid Shape Examples

Examples for creating and manipulating hybrid shapes (geometric features).

## Create Points

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

hsf = part.hybrid_shape_factory

# Create point at coordinates
point = hsf.add_new_point_coord(100, 50, 25)
point.name = "MyPoint"

part.update()
```

## Create Lines

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

hsf = part.hybrid_shape_factory

# Create line between two points
line = hsf.add_new_line_ptpt(
    point1,   # Start point
    point2    # End point
)
line.name = "MyLine"

part.update()
```

## Create Planes

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

hsf = part.hybrid_shape_factory

# Create offset plane
plane = hsf.add_new_plane_offset(
    distance=50.0,
    ref=reference_plane
)
plane.name = "OffsetPlane"

part.update()
```

## Create Extrusions

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

hsf = part.hybrid_shape_factory

# Create extrusion
extrusion = hsf.add_new_extrusion(
    shape=sketch,
    limit1=dimension1,
    limit2=dimension2
)
extrusion.name = "MyExtrusion"

part.update()
```

## Get Shape Type

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

hsf = part.hybrid_shape_factory

# Get shape type
shape_type = hsf.get_geometrical_feature_type(reference)
print(f"Shape type: {shape_type}")
```

## Rename Shapes

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

# Rename all points in a hybrid body
hybrid_body = part.hybrid_bodies.item("MyBody")
shapes = hybrid_body.hybrid_shapes

for i in range(len(shapes)):
    shape = shapes.item(i + 1)
    shape.name = f"Point_{i+1}"
```
