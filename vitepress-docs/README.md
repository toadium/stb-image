# pycatia Documentation

[VitePress](https://vitepress.dev) documentation site for pycatia — a Python interface for CATIA V5 COM automation.

## Project Information

- **Version**: 0.9.6
- **Author**: Paul Bourne
- **Repository**: [github.com/evereux/pycatia](https://github.com/evereux/pycatia)
- **Package**: [pypi.org/project/pycatia](https://pypi.org/project/pycatia)
- **License**: MIT

## Requirements

- Python 3.9+
- Windows OS
- CATIA V5 running
- pywin32>=224

## Documentation Structure

### Guide
- [Introduction](/guide/introduction) — What is pycatia
- [Installation](/guide/installation) — Setup instructions
- [Quick Start](/guide/quick-start) — First steps
- [Application Object](/guide/application) — CATIA application
- [Documents](/guide/documents) — Document management
- [Selection](/guide/selection) — Selection handling
- [Part & Product](/guide/part-product) — Working with parts/products
- [Context Manager](/guide/context-manager) — CATIADocHandler
- [Logging](/guide/logging) — Logging setup
- [Enumerations](/guide/enumerations) — CATIA constants
- [Error Handling](/guide/error-handling) — Debugging tips

### API Reference
- [Application](/api/application) — Main API
- [HybridShapeFactory](/api/hybrid-shape-factory) — Geometry creation
- [Product](/api/product) — Product structure

### Examples
- [Overview](/examples/overview) — Example gallery
- [Document](/examples/document) — Document handling
- [Product](/examples/product) — Assembly operations
- [Hybrid Shapes](/examples/hybrid-shapes) — Geometry creation
- [Parameters](/examples/parameters) — Knowledge engine
- [Selection](/examples/selection) — User interaction
- [Space Analysis](/examples/space-analysis) — Measurements
- [Drafting](/examples/drafting) — 2D drawings

### User Scripts
- [Overview](/user-scripts/overview) — Script gallery
- [Save Drawings to PDF](/user-scripts/save-drawings-pdf)
- [Rename Instances](/user-scripts/rename-instances)
- [Create Screenshots](/user-scripts/create-screenshots)
- [Save Parts to STEP](/user-scripts/save-parts-stp)
- [Wing Surface](/user-scripts/wing-surface)

## Quick Install

```bash
pip install pycatia
```

## Quick Start

```python
from pycatia import catia

application = catia()
documents = application.documents
part_doc = documents.open("part.CATPart")
part = part_doc.part
part.update()
```
