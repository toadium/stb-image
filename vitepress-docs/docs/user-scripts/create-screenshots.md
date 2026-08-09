# Create Screenshot

Capture screenshots of CATIA 3D views.

## Usage

```python
python create_screenshots_of_parts_and_products.py
```

## How It Works

1. Sets up camera positions
2. Renders the view
3. Captures the image
4. Saves to file

## Code Example

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document

# Get viewer
viewer = part_document.viewer

# Set view
viewer.fit_all()

# Capture screenshot
viewer.capture("screenshot.png")
```
