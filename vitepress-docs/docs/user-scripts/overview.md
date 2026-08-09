# User Scripts Overview

pycatia includes a collection of user-contributed scripts for common CATIA automation tasks.

## Available Scripts

| Script | Description |
|--------|-------------|
| `save_drawings_to_pdf.py` | Export all drawings to PDF |
| `rename_instances_in_product.py` | Rename product instances alphabetically |
| `create_screenshots_of_parts_and_products.py` | Take screenshots of 3D views |
| `save_child_parts_to_stp.py` | Export all child parts to STEP |
| `wing_surface_from_naca_profile.py` | Create wing surface from NACA profile |
| `create_parameters_from_yaml.py` | Create parameters from YAML file |
| `create_lines_normal_to_surface.py` | Create normal lines to surface |
| `create_bounding_box.py` | Create bounding box around selection |
| `coords_relative_to_axis_system.py` | Get coordinates relative to axis |

## Running Scripts

```bash
# Navigate to user_scripts directory
cd user_scripts

# Run a script
python save_drawings_to_pdf.py
```

## Prerequisites

Most scripts require:
- CATIA V5 running
- An open document
- Appropriate CATIA configuration

## Script Details

### Save Drawings to PDF

Export all drawing sheets to individual PDF files:

```python
# Usage
python save_drawings_to_pdf.py
```

### Rename Instances in Product

Sort and rename product tree alphabetically:

```python
# Requirements
pip install pywinauto natsort

# Usage
python rename_instances_in_product.py
```

### Create Screenshots

Capture screenshots of 3D views:

```python
# Usage
python create_screenshots_of_parts_and_products.py
```

### Save Child Parts to STEP

Export all referenced parts to STEP format:

```python
# Usage
python save_child_parts_to_stp.py
```

### Wing Surface from NACA Profile

Create aircraft wing surface from NACA airfoil data:

```python
# Usage
python wing_surface_from_naca_profile.py
```

## Contributing Scripts

Want to add your own script? See [CONTRIBUTING.md](https://github.com/evereux/pycatia/blob/main/CONTRIBUTING.md) in the repository.
