---
layout: home

hero:
  name: "pycatia"
  text: "CATIA V5 Python Automation"
  tagline: "A Python module to interface with the CATIA V5 COM object. Automate CAD workflows, manipulate parts and products, and extend CATIA functionality."
  image:
    src: /pycatia-logo.png
    alt: pycatia Logo
  actions:
    - theme: brand
      text: Get Started
      link: /guide/introduction
    - theme: alt
      text: GitHub
      link: https://github.com/evereux/pycatia
    - theme: alt
      text: PyPI
      link: https://pypi.org/project/pycatia/

features:
  - title: COM Automation
    details: "Full Python bindings for the CATIA V5 COM interface. Access all major CATIA functionality through a Pythonic API."
    icon: 🐍
  - title: Type Hints
    details: "Comprehensive type hinting throughout the codebase. Better IDE support, autocomplete, and compile-time checks."
    icon: 📝
  - title: Wide Coverage
    details: "80+ interface modules covering hybrid shapes, manufacturing, drafting, product structure, and more."
    icon: 📦
  - title: Easy Installation
    details: "Single dependency on pywin32. Install with pip and start automating CATIA immediately."
    icon: ⚡
  - title: Context Manager
    details: "Built-in CATIADocHandler for automatic document management. Open and close documents with Python's with statement."
    icon: 🔄
  - title: Active Community
    details: "Extensive example library and user scripts. Active development with regular updates and bug fixes."
    icon: 👥

---

<script setup>
import { ref } from 'vue'

const tabs = ref('product')

const tabContent = {
  product: {
    title: 'Product Structure',
    code: `from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
product = product_document.product

# Navigate product tree
products = product.products
for product in products:
    print(product.name)

# Generate CATPart files
product.generate_all_catparts()`
  },
  part: {
    title: 'Part Design',
    code: `from pycatia import catia
from pycatia.mec_mod_interfaces.part_document import PartDocument

application = catia()
documents = application.documents
part_document: PartDocument = documents.open("part.CATPart")
part = part_document.part

# Access hybrid shape factory
hsf = part.hybrid_shape_factory

# Create a point
point = hsf.add_new_point_coord(0, 0, 0)
point.name = "Origin"

part.update()`
  },
  drawing: {
    title: 'Drafting',
    code: `from pycatia import catia
from pycatia.drafting_interfaces.drawing_document import DrawingDocument

application = catia()
drawing_doc: DrawingDocument = application.active_document

# Access drawing views
views = drawing_doc.views
for view in views:
    print(view.name)

# Add a dimension
factory_2d = drawing_doc.factory_2d`
  }
}
</script>

<div class="custom-layout">
  <div class="code-demo">
    <div class="tab-buttons">
      <button :class="['tab-btn', { active: tabs === 'product' }]" @click="tabs = 'product'">Product</button>
      <button :class="['tab-btn', { active: tabs === 'part' }]" @click="tabs = 'part'">Part</button>
      <button :class="['tab-btn', { active: tabs === 'drawing' }]" @click="tabs = 'drawing'">Drawing</button>
    </div>
    <div class="code-block">
      <div class="code-header">
        <span>python</span>
        <span class="code-title">{{ tabContent[tabs].title }}</span>
      </div>
      <pre><code>{{ tabContent[tabs].code }}</code></pre>
    </div>
  </div>

  <div class="interface-grid">
    <h2>Interface Coverage</h2>
    <div class="interface-grid-inner">
      <div class="interface-category">
        <h3>🔧 Core Interfaces</h3>
        <div class="interface-list">
          <span class="interface-tag">mec_mod_interfaces</span>
          <span class="interface-tag">product_structure_interfaces</span>
          <span class="interface-tag">part_interfaces</span>
          <span class="interface-tag">drafting_interfaces</span>
          <span class="interface-tag">knowledge_interfaces</span>
        </div>
      </div>
      <div class="interface-category">
        <h3>📐 Geometry</h3>
        <div class="interface-list">
          <span class="interface-tag">hybrid_shape_interfaces</span>
          <span class="interface-tag">sketcher_interfaces</span>
          <span class="interface-tag">shape_factory</span>
          <span class="interface-tag">space_analyses_interfaces</span>
        </div>
      </div>
      <div class="interface-category">
        <h3>🏭 Manufacturing</h3>
        <div class="interface-list">
          <span class="interface-tag">manufacturing_interfaces</span>
          <span class="interface-tag">prismatic_machining_interfaces</span>
          <span class="interface-tag">surface_machining_interfaces</span>
          <span class="interface-tag">abq_automation_interfaces</span>
        </div>
      </div>
      <div class="interface-category">
        <h3>📊 Analysis</h3>
        <div class="interface-list">
          <span class="interface-tag">analysis_interfaces</span>
          <span class="interface-tag">simulation_interfaces</span>
          <span class="interface-tag">kinematics_interfaces</span>
          <span class="interface-tag">behavior_interfaces</span>
        </div>
      </div>
    </div>
  </div>

  <div class="quick-start">
    <h2>Quick Start</h2>
    <div class="steps">
      <div class="step">
        <div class="step-num">1</div>
        <div class="step-content">
          <h4>Install pycatia</h4>
          <div class="code-inline">pip install pycatia</div>
        </div>
      </div>
      <div class="step">
        <div class="step-num">2</div>
        <div class="step-content">
          <h4>Initialize CATIA</h4>
          <div class="code-inline">from pycatia import catia
application = catia()</div>
        </div>
      </div>
      <div class="step">
        <div class="step-num">3</div>
        <div class="step-content">
          <h4>Access Documents</h4>
          <div class="code-inline">documents = application.documents
part_doc = documents.open("part.CATPart")</div>
        </div>
      </div>
      <div class="step">
        <div class="step-num">4</div>
        <div class="step-content">
          <h4>Automate</h4>
          <div class="code-inline">part = part_doc.part
part.update()</div>
        </div>
      </div>
    </div>
  </div>

  <div class="requirements">
    <h2>Requirements</h2>
    <div class="req-grid">
      <div class="req-item">
        <div class="req-icon">🐍</div>
        <div class="req-info">
          <strong>Python 3.9+</strong>
          <p>Python 3.9 or higher required</p>
        </div>
      </div>
      <div class="req-item">
        <div class="req-icon">🪟</div>
        <div class="req-info">
          <strong>Windows</strong>
          <p>Windows OS required for COM automation</p>
        </div>
      </div>
      <div class="req-item">
        <div class="req-icon">🔧</div>
        <div class="req-info">
          <strong>CATIA V5</strong>
          <p>CATIA V5 running on the system</p>
        </div>
      </div>
      <div class="req-item">
        <div class="req-icon">📦</div>
        <div class="req-info">
          <strong>pywin32</strong>
          <p>Single dependency: pywin32>=224</p>
        </div>
      </div>
    </div>
  </div>
</div>

<style scoped>
.custom-layout {
  display: flex;
  flex-direction: column;
  gap: 3rem;
  margin-top: 2rem;
}

.code-demo {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  padding: 1.5rem;
}

.tab-buttons {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.tab-btn {
  padding: 0.5rem 1rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  cursor: pointer;
  transition: all 0.2s;
}

.tab-btn.active {
  background: var(--vp-c-brand-1);
  color: white;
  border-color: var(--vp-c-brand-1);
}

.interface-grid, .quick-start, .requirements {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  padding: 2rem;
}

.interface-grid h2, .quick-start h2, .requirements h2 {
  margin-top: 0;
  border-bottom: 2px solid var(--vp-c-border);
  padding-bottom: 0.5rem;
}

.interface-grid-inner {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.interface-category h3 {
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
  color: var(--vp-c-text-2);
}

.interface-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.interface-tag {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  padding: 0.25rem 0.5rem;
  font-size: 0.75rem;
  font-family: monospace;
}

.steps {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.step {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
}

.step-num {
  width: 32px;
  height: 32px;
  background: var(--vp-c-brand-1);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  flex-shrink: 0;
}

.step-content h4 {
  margin: 0 0 0.5rem 0;
}

.code-inline {
  background: var(--vp-code-block-bg);
  padding: 0.5rem;
  border-radius: 6px;
  font-family: monospace;
  font-size: 0.85rem;
  white-space: pre-wrap;
}

.req-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 1rem;
}

.req-item {
  display: flex;
  gap: 1rem;
  align-items: center;
  background: var(--vp-c-bg);
  padding: 1rem;
  border-radius: 8px;
}

.req-icon {
  font-size: 2rem;
}

.req-info strong {
  display: block;
}

.req-info p {
  margin: 0;
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
}

.code-block {
  background: var(--vp-code-block-bg);
  border-radius: 8px;
  overflow: hidden;
}

.code-header {
  background: var(--vp-c-gray-3);
  padding: 0.25rem 0.75rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.code-header span:first-child {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
  text-transform: uppercase;
}

.code-title {
  font-size: 0.85rem;
  color: var(--vp-c-text-1);
}

pre {
  margin: 0 !important;
  padding: 1rem !important;
  background: transparent !important;
}

code {
  font-family: 'JetBrains Mono', ui-monospace, monospace;
  font-size: 0.85rem;
}
</style>
