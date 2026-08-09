# API Reference

## Application

The `catia` function returns the CATIA application object.

```python
from pycatia import catia
application = catia()
```

### Methods

| Method | Description |
|--------|-------------|
| `start_command(name)` | Execute a CATIA command by name |
| `input_box(prompt, title)` | Display input dialog |
| `system_service` | Get system service object |

## Documents

Collection of open documents.

```python
documents = application.documents
```

### Methods

| Method | Description |
|--------|-------------|
| `open(path)` | Open a document |
| `add(doc_type)` | Create new document |
| `close(index)` | Close document |
| `count()` | Get document count |

## PartDocument

```python
from pycatia.mec_mod_interfaces.part_document import PartDocument
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `part` | Part | Part object |
| `selection` | Selection | Selection object |

### Methods

| Method | Description |
|--------|-------------|
| `save()` | Save document |
| `save_as(path)` | Save with new path |
| `close()` | Close document |

## ProductDocument

```python
from pycatia.product_structure_interfaces.product_document import ProductDocument
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `product` | Product | Root product |
| `selection` | Selection | Selection object |

## Selection

```python
selection = document.selection
```

### Methods

| Method | Description |
|--------|-------------|
| `clear()` | Clear selection |
| `add(element)` | Add to selection |
| `remove(element)` | Remove from selection |
| `count()` | Get count |
| `item(index)` | Get item by index |
| `search(filter, mode)` | Search elements |

## Part

```python
part = part_document.part
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `bodies` | Bodies | Geometric bodies |
| `hybrid_bodies` | HybridBodies | Hybrid bodies |
| `parameters` | Parameters | Parameter collection |
| `relations` | Relations | Knowledge relations |
| `analysis` | Analysis | Analysis workbench |

### Methods

| Method | Description |
|--------|-------------|
| `update()` | Update part |
| `get_hybrid_shape_by_name(name)` | Get shape by name |
| `create_reference_from_object(obj)` | Create reference |

## HybridShapeFactory

```python
hsf = part.hybrid_shape_factory
```

### Methods

| Method | Description |
|--------|-------------|
| `add_new_point_coord(x, y, z)` | Create point |
| `add_new_line_hyperbola(...)` | Create hyperbola line |
| `add_new_plane_offset(distance, ref)` | Create offset plane |
| `add_new_extrusion(shape, limit1, limit2)` | Create extrusion |
| `get_geometrical_feature_type(ref)` | Get shape type |

## Product

```python
product = product_document.product
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `products` | Products | Child products |
| `constraints` | Constraints | Product constraints |
| `parameters` | Parameters | Product parameters |

### Methods

| Method | Description |
|--------|-------------|
| `generate_all_catparts()` | Generate all parts |
| `activate_terminal_mode()` | Activate terminal mode |
| `move(position)` | Move product |
