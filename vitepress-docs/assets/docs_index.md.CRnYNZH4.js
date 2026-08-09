import{_ as c,o as r,c as o,b as a,n as i,t as d,a as v,r as p}from"./chunks/framework.DB-sBtQe.js";const l={class:"custom-layout"},u={class:"code-demo"},m={class:"tab-buttons"},f={class:"code-block"},g={class:"code-header"},_={class:"code-title"},b=JSON.parse(`{"title":"","description":"","frontmatter":{"layout":"home","hero":{"name":"pycatia","text":"CATIA V5 Python Automation","tagline":"A Python module to interface with the CATIA V5 COM object. Automate CAD workflows, manipulate parts and products, and extend CATIA functionality.","image":{"src":"/pycatia-logo.png","alt":"pycatia Logo"},"actions":[{"theme":"brand","text":"Get Started","link":"/guide/introduction"},{"theme":"alt","text":"GitHub","link":"https://github.com/evereux/pycatia"},{"theme":"alt","text":"PyPI","link":"https://pypi.org/project/pycatia/"}]},"features":[{"title":"COM Automation","details":"Full Python bindings for the CATIA V5 COM interface. Access all major CATIA functionality through a Pythonic API.","icon":"🐍"},{"title":"Type Hints","details":"Comprehensive type hinting throughout the codebase. Better IDE support, autocomplete, and compile-time checks.","icon":"📝"},{"title":"Wide Coverage","details":"80+ interface modules covering hybrid shapes, manufacturing, drafting, product structure, and more.","icon":"📦"},{"title":"Easy Installation","details":"Single dependency on pywin32. Install with pip and start automating CATIA immediately.","icon":"⚡"},{"title":"Context Manager","details":"Built-in CATIADocHandler for automatic document management. Open and close documents with Python's with statement.","icon":"🔄"},{"title":"Active Community","details":"Extensive example library and user scripts. Active development with regular updates and bug fixes.","icon":"👥"}]},"headers":[],"relativePath":"docs/index.md","filePath":"docs/index.md"}`),h={name:"docs/index.md"},y=Object.assign(h,{setup(A){const e=p("product"),s={product:{title:"Product Structure",code:`from pycatia import catia
from pycatia.product_structure_interfaces.product_document import ProductDocument

application = catia()
product_document: ProductDocument = application.active_document
product = product_document.product

# Navigate product tree
products = product.products
for product in products:
    print(product.name)

# Generate CATPart files
product.generate_all_catparts()`},part:{title:"Part Design",code:`from pycatia import catia
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

part.update()`},drawing:{title:"Drafting",code:`from pycatia import catia
from pycatia.drafting_interfaces.drawing_document import DrawingDocument

application = catia()
drawing_doc: DrawingDocument = application.active_document

# Access drawing views
views = drawing_doc.views
for view in views:
    print(view.name)

# Add a dimension
factory_2d = drawing_doc.factory_2d`}};return(C,t)=>(r(),o("div",null,[a("div",l,[a("div",u,[a("div",m,[a("button",{class:i(["tab-btn",{active:e.value==="product"}]),onClick:t[0]||(t[0]=n=>e.value="product")},"Product",2),a("button",{class:i(["tab-btn",{active:e.value==="part"}]),onClick:t[1]||(t[1]=n=>e.value="part")},"Part",2),a("button",{class:i(["tab-btn",{active:e.value==="drawing"}]),onClick:t[2]||(t[2]=n=>e.value="drawing")},"Drawing",2)]),a("div",f,[a("div",g,[t[3]||(t[3]=a("span",null,"python",-1)),a("span",_,d(s[e.value].title),1)]),a("pre",null,[a("code",null,d(s[e.value].code),1)])])]),t[4]||(t[4]=v('<div class="interface-grid" data-v-35325556><h2 data-v-35325556>Interface Coverage</h2><div class="interface-grid-inner" data-v-35325556><div class="interface-category" data-v-35325556><h3 data-v-35325556>🔧 Core Interfaces</h3><div class="interface-list" data-v-35325556><span class="interface-tag" data-v-35325556>mec_mod_interfaces</span><span class="interface-tag" data-v-35325556>product_structure_interfaces</span><span class="interface-tag" data-v-35325556>part_interfaces</span><span class="interface-tag" data-v-35325556>drafting_interfaces</span><span class="interface-tag" data-v-35325556>knowledge_interfaces</span></div></div><div class="interface-category" data-v-35325556><h3 data-v-35325556>📐 Geometry</h3><div class="interface-list" data-v-35325556><span class="interface-tag" data-v-35325556>hybrid_shape_interfaces</span><span class="interface-tag" data-v-35325556>sketcher_interfaces</span><span class="interface-tag" data-v-35325556>shape_factory</span><span class="interface-tag" data-v-35325556>space_analyses_interfaces</span></div></div><div class="interface-category" data-v-35325556><h3 data-v-35325556>🏭 Manufacturing</h3><div class="interface-list" data-v-35325556><span class="interface-tag" data-v-35325556>manufacturing_interfaces</span><span class="interface-tag" data-v-35325556>prismatic_machining_interfaces</span><span class="interface-tag" data-v-35325556>surface_machining_interfaces</span><span class="interface-tag" data-v-35325556>abq_automation_interfaces</span></div></div><div class="interface-category" data-v-35325556><h3 data-v-35325556>📊 Analysis</h3><div class="interface-list" data-v-35325556><span class="interface-tag" data-v-35325556>analysis_interfaces</span><span class="interface-tag" data-v-35325556>simulation_interfaces</span><span class="interface-tag" data-v-35325556>kinematics_interfaces</span><span class="interface-tag" data-v-35325556>behavior_interfaces</span></div></div></div></div><div class="quick-start" data-v-35325556><h2 data-v-35325556>Quick Start</h2><div class="steps" data-v-35325556><div class="step" data-v-35325556><div class="step-num" data-v-35325556>1</div><div class="step-content" data-v-35325556><h4 data-v-35325556>Install pycatia</h4><div class="code-inline" data-v-35325556>pip install pycatia</div></div></div><div class="step" data-v-35325556><div class="step-num" data-v-35325556>2</div><div class="step-content" data-v-35325556><h4 data-v-35325556>Initialize CATIA</h4><div class="code-inline" data-v-35325556>from pycatia import catia application = catia()</div></div></div><div class="step" data-v-35325556><div class="step-num" data-v-35325556>3</div><div class="step-content" data-v-35325556><h4 data-v-35325556>Access Documents</h4><div class="code-inline" data-v-35325556>documents = application.documents part_doc = documents.open(&quot;part.CATPart&quot;)</div></div></div><div class="step" data-v-35325556><div class="step-num" data-v-35325556>4</div><div class="step-content" data-v-35325556><h4 data-v-35325556>Automate</h4><div class="code-inline" data-v-35325556>part = part_doc.part part.update()</div></div></div></div></div><div class="requirements" data-v-35325556><h2 data-v-35325556>Requirements</h2><div class="req-grid" data-v-35325556><div class="req-item" data-v-35325556><div class="req-icon" data-v-35325556>🐍</div><div class="req-info" data-v-35325556><strong data-v-35325556>Python 3.9+</strong><p data-v-35325556>Python 3.9 or higher required</p></div></div><div class="req-item" data-v-35325556><div class="req-icon" data-v-35325556>🪟</div><div class="req-info" data-v-35325556><strong data-v-35325556>Windows</strong><p data-v-35325556>Windows OS required for COM automation</p></div></div><div class="req-item" data-v-35325556><div class="req-icon" data-v-35325556>🔧</div><div class="req-info" data-v-35325556><strong data-v-35325556>CATIA V5</strong><p data-v-35325556>CATIA V5 running on the system</p></div></div><div class="req-item" data-v-35325556><div class="req-icon" data-v-35325556>📦</div><div class="req-info" data-v-35325556><strong data-v-35325556>pywin32</strong><p data-v-35325556>Single dependency: pywin32&gt;=224</p></div></div></div></div>',3))])]))}}),P=c(y,[["__scopeId","data-v-35325556"]]);export{b as __pageData,P as default};
