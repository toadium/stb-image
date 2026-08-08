# Error Handling

Understanding and handling errors is crucial when working with pycatia and CATIA.

## Common Error Types

### COMError

```python
import pythoncom
from win32com.client import DispatchException

try:
    application = catia()
except COMError as e:
    print(f"COM Error: {e}")
    print(f"Description: {e.desc}")
```

### AttributeError

```python
try:
    part = part_document.part
    unknown_method = part.non_existent_method()
except AttributeError as e:
    print(f"Method not found: {e}")
```

### FileNotFoundError

```python
from pathlib import Path

try:
    part_document = documents.open(Path("nonexistent.CATPart"))
except FileNotFoundError:
    print("Part file not found")
```

## Best Practices

### 1. Check if CATIA is Running

```python
from pycatia import catia

try:
    application = catia()
    if application is None:
        raise RuntimeError("CATIA is not running")
except Exception as e:
    print(f"Failed to connect to CATIA: {e}")
```

### 2. Validate Document Operations

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
part_document: PartDocument = application.active_document

if part_document is None:
    raise RuntimeError("No active document")

part = part_document.part
if part is None:
    raise RuntimeError("Failed to access part")
```

### 3. Handle Update Failures

```python
try:
    part.update()
except Exception as e:
    print(f"Update failed: {e}")
    # Check for errors in CATIA error log
```

### 4. Safe Selection Operations

```python
selection = document.selection
selection.clear()

try:
    selection.add(some_element)
except Exception as e:
    print(f"Selection failed: {e}")
```

## Error Handling Pattern

```python
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument
import logging

logger = logging.getLogger("pycatia")

def safe_part_operation(part_path):
    """Safely perform operations on a part document."""
    try:
        application = catia()
        documents = application.documents
        part_document: PartDocument = documents.open(part_path)
        part = part_document.part
        
        # Perform operations
        part.update()
        part_document.save()
        
        logger.info(f"Successfully processed {part_path}")
        return True
        
    except FileNotFoundError:
        logger.error(f"File not found: {part_path}")
        return False
    except Exception as e:
        logger.error(f"Error processing {part_path}: {e}")
        return False
    finally:
        try:
            part_document.close()
        except:
            pass
```

## CATIA Error Messages

CATIA error messages are often in the CATIA console. Check:

1. The CATIA command line
2. The message area at the bottom of the CATIA window
3. System logs if available
