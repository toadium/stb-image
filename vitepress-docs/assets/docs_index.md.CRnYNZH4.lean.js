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
factory_2d = drawing_doc.factory_2d`}};return(C,t)=>(r(),o("div",null,[a("div",l,[a("div",u,[a("div",m,[a("button",{class:i(["tab-btn",{active:e.value==="product"}]),onClick:t[0]||(t[0]=n=>e.value="product")},"Product",2),a("button",{class:i(["tab-btn",{active:e.value==="part"}]),onClick:t[1]||(t[1]=n=>e.value="part")},"Part",2),a("button",{class:i(["tab-btn",{active:e.value==="drawing"}]),onClick:t[2]||(t[2]=n=>e.value="drawing")},"Drawing",2)]),a("div",f,[a("div",g,[t[3]||(t[3]=a("span",null,"python",-1)),a("span",_,d(s[e.value].title),1)]),a("pre",null,[a("code",null,d(s[e.value].code),1)])])]),t[4]||(t[4]=v("",3))])]))}}),P=c(y,[["__scopeId","data-v-35325556"]]);export{b as __pageData,P as default};
