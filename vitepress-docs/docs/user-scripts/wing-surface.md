# Wing Surface from NACA Profile

Create an aircraft wing surface from NACA airfoil data.

## Usage

```python
python wing_surface_from_naca_profile.py
```

## Requirements

- NACA airfoil data file (.dat)
- Parameters file for wing configuration

## How It Works

1. Reads NACA airfoil coordinates from .dat file
2. Creates 2D sketch profiles at different span positions
3. Creates a loft surface through the profiles
4. Applies twist and taper parameters

## Parameters

| Parameter | Description |
|-----------|-------------|
| Root chord | Wing chord at root |
| Tip chord | Wing chord at tip |
| Span | Total wingspan |
| Twist | Geometric twist angle |
| Airfoil file | NACA .dat file path |

## Code Structure

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document
part = part_document.part

# Read NACA profile
points = read_naca_profile("naca0012.dat")

# Create wing surface
wing = create_wing_surface(
    part,
    points,
    root_chord=1000,
    tip_chord=500,
    span=2000
)
```

## Files

- `wing_surface_from_naca_profile.py` — Main script
- `wing_surface_from_naca_profile_support/` — Support modules
