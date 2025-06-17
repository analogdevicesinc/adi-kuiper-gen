# -- Import setup -------------------------------------------------------------

from os import path

# -- Project information ------------------------------------------------------

repository = 'adi-kuiper-gen'
project = 'Kuiper'
copyright = '2025, Analog Devices, Inc.'
author = 'Analog Devices, Inc.'
version = '' # documentation version, will be printed on the cover page

# -- General configuration ----------------------------------------------------

extensions = [
    'sphinx.ext.todo',
    'adi_doctools',
    'rst2pdf.pdfbuilder',
    # Try to include sphinx-design if available, fallback gracefully if not
    'sphinx_design',  # For advanced UI components like grids and cards
]

# Handle missing sphinx-design gracefully
import importlib.util
if importlib.util.find_spec('sphinx_design') is None:
    print("Warning: sphinx-design not found. Some UI components may not render correctly.")
    extensions.remove('sphinx_design')

needs_extensions = {
    'adi_doctools': '0.3.47'
}

exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']
source_suffix = '.rst'

# -- External docs configuration ----------------------------------------------

interref_repos = ['doctools', 'documentation', 'pyadi-iio']

# -- Custom extensions configuration ------------------------------------------

hide_collapsible_content = True
validate_links = False

# -- todo configuration -------------------------------------------------------

todo_include_todos = True
todo_emit_warnings = True

# -- WaveDrom configuration ---------------------------------------------------

online_wavedrom_js_url = "https://cdnjs.cloudflare.com/ajax/libs/wavedrom/3.1.0"

# -- Options for HTML output --------------------------------------------------

html_theme = 'cosmic'
html_static_path = ['sources']
html_css_files = ["custom.css"]
html_favicon = path.join("sources", "icon.svg")

html_theme_options = {
    "light_logo": "HDL_logo_cropped.svg",
    "dark_logo": "HDL_logo_w_cropped.svg",
}

# -- Sphinx Design configuration (if available) -------------------------------

# Enable sphinx-design features if the extension is loaded
if 'sphinx_design' in extensions:
    html_css_files.append('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css')