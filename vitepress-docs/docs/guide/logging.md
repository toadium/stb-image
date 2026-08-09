# Logging

pycatia includes built-in logging support for debugging and monitoring.

## Basic Logging

```python
import logging
from pycatia import catia

# Configure logging
logging.basicConfig(level=logging.INFO)

application = catia()
```

## Logger Name

pycatia uses the logger name `pycatia`. You can access it directly:

```python
import logging

logger = logging.getLogger("pycatia")
logger.setLevel(logging.DEBUG)
```

## Log Levels

| Level | Usage |
|-------|-------|
| `DEBUG` | Detailed diagnostic information |
| `INFO` | General information about operations |
| `WARNING` | Unexpected situations |
| `ERROR` | Error conditions |
| `CRITICAL` | Critical errors |

## Example

```python
import logging
from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

# Set up logging to file
logging.basicConfig(
    filename='pycatia.log',
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

application = catia()
part_document: PartDocument = application.active_document

# Operations will be logged
part = part_document.part
part.update()
```

## Example Log Output

```
2024-01-15 10:30:00,123 - pycatia - INFO - CATIA application initialized
2024-01-15 10:30:00,456 - pycatia - DEBUG - Opening document: part.CATPart
2024-01-15 10:30:01,789 - pycatia - INFO - Part updated successfully
```
