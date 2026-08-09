# Installation

## Requirements

Before installing pycatia, ensure you have:

- **Python 3.9 or higher**
- **Windows OS** (required for COM automation)
- **CATIA V5** installed and running
- **pywin32** (installed automatically)

## Installing from PyPI

The recommended way to install pycatia is via pip:

```bash
pip install pycatia
```

## Installing from Source

```bash
git clone https://github.com/evereux/pycatia.git
cd pycatia
pip install -e .
```

## Development Installation

For development, install the test requirements:

```bash
pip install -e ".[dev]"
```

Or manually:

```bash
pip install pytest pytest-cov mypy
```

## Verifying Installation

```python
from pycatia import catia

# This will connect to a running CATIA instance
application = catia()
print(f"Connected to CATIA: {application.name}")
```

## Troubleshooting

### COM Registration Issues

If you get COM registration errors, ensure CATIA V5 is properly installed:

```bash
# Check if CATIA COM server is registered
reg query HKCR\CLSID /f "CATIA" /s
```

### Version Compatibility

pycatia supports CATIA V5 R2018 through R2024. Some features may only be available in specific versions.

### Python Version

Ensure you're using Python 3.9 or higher:

```bash
python --version
```

## Additional Dependencies

Some examples may require additional packages:

```bash
# For GUI automation examples
pip install pywinauto natsort

# For type checking
pip install mypy
```
