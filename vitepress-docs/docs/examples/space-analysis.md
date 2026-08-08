# Space Analysis Examples

Examples for measuring and analyzing CATIA products and parts.

## Get Measurable

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document

# Get SPA workbench
spa = product_document.spa_workbench

# Get measurable for a product
product = product_document.product
measurable = spa.get_measurable(product)

# Get measurements
volume = measurable.volume
surface = measurable.surface
print(f"Volume: {volume}")
print(f"Surface: {surface}")
```

## Center of Gravity

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
spa = product_document.spa_workbench

product = product_document.product
measurable = spa.get_measurable(product)

# Get center of gravity
cog = measurable.center_of_gravity
print(f"CoG: {cog.x}, {cog.y}, {cog.z}")
```

## Moment of Inertia

```python
from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
spa = product_document.spa_workbench

product = product_document.product
measurable = spa.get_measurable(product)

# Get moments of inertia
ixx = measurable.moment_of_inertia_x
iyy = measurable.moment_of_inertia_y
izz = measurable.moment_of_inertia_z

print(f"Ixx: {ixx}")
print(f"Iyy: {iyy}")
print(f"Izz: {izz}")
```

## Distance Measurement

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

spa = part.spa_workbench

# Get measurable for two points
point1 = part.get_hybrid_shape_by_name("Point.1")
point2 = part.get_hybrid_shape_by_name("Point.2")

measurable = spa.get_measurable(point1)
distance = measurable.minimum_distance(point2)
print(f"Distance: {distance}")
```

## Angle Between Elements

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

spa = part.spa_workbench
measurable = spa.get_measurable_in_context()

# Get angle between two elements
angle = measurable.get_angle_between_in_context()
print(f"Angle: {angle} degrees")
```
