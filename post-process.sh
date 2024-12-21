find _site/ -name "*.html" -print0 | xargs -0 sed -i '/..\/site_libs\/quarto-html/d'
find _site/ -name "*.html" -print0 | xargs -0 sed -i '/..\/site_libs\/clipboard/d'