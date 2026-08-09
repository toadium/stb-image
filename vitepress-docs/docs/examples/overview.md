# Examples Overview

pycatia includes 40+ examples demonstrating various CATIA automation tasks.

## Example Categories

| Category | Description | Examples |
|----------|-------------|----------|
| **Document** | Document handling | 3 examples |
| **Product** | Assembly manipulation | 6 examples |
| **Part** | Part design operations | 3 examples |
| **Hybrid Shape** | Geometry creation | 7 examples |
| **Sketch** | 2D sketching | 2 examples |
| **Selection** | User interaction | 3 examples |
| **Space Analysis** | Measurement & analysis | 3 examples |
| **Drafting** | 2D drawing creation | 3 examples |
| **Parameters** | Knowledge engine | 2 examples |
| **Visual Properties** | Appearance settings | 1 example |
| **Inertia** | Mass properties | 1 example |
| **Material** | Material assignment | 1 example |
| **Assembly Convertor** | BOM generation | 1 example |

## Running Examples

```bash
# Navigate to examples directory
cd examples

# Run a specific example
python example__product__001.py
```

## Example Structure

Each example follows a consistent structure:

```python
"""
Example - Category - Number

Description:
    Brief description of what the example does.

Requirements:
    - List of requirements

Usage:
    Steps to run the example.
"""

from pycatia import catia
# ... example code
```

## Browse Examples

- [Document Examples](/examples/document)
- [Product Examples](/examples/product)
- [Hybrid Shape Examples](/examples/hybrid-shapes)
- [Parameters Examples](/examples/parameters)
- [Selection Examples](/examples/selection)
- [Space Analysis Examples](/examples/space-analysis)
- [Drafting Examples](/examples/drafting)
