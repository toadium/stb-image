# Application Object

The `catia` object is the base entry point for all pycatia operations. It represents the CATIA V5 application instance.

## Initialization

```python
from pycatia import catia

# Connect to running CATIA instance
application = catia()

# Initialize with COM initialization (for threaded contexts)
application = catia(co_initialise=True)
```

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | str | CATIA application name |
| `version` | str | CATIA version string |
| `visible` | bool | Application visibility |
| `windows` | Windows | Collection of windows |

## Methods

### Documents

```python
documents = application.documents
```

Returns a `Documents` collection object for managing open documents.

### Active Document

```python
document = application.active_document
```

Returns the currently active document.

### Start Command

```python
application.start_command("Measure Inertia")
```

Executes a CATIA command by name. Useful for commands without direct API access.

### Input Box

```python
result = application.input_box("Enter value:", "Input")
```

Displays a CATIA input box and returns user input.

### System Service

```python
system_service = application.system_service
```

Returns the system service object for file operations and other system functions.

## Full Example

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

# Initialize application
caa = catia()

# Check if CATIA is running
if caa is None:
    raise RuntimeError("CATIA is not running")

# Get documents collection
documents = caa.documents

# Open a part
part_doc: PartDocument = documents.open("part.CATPart")

# Access part
part = part_doc.part

# Get application name
print(f"CATIA: {caa.name}")

# Close document
part_doc.close()
```
