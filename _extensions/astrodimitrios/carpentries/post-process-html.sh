# Remove Quarto's bootstrap
find $QUARTO_PROJECT_OUTPUT_DIR -name "*.html" -print0 | xargs -0 sed -i '/..\/site_libs\/bootstrap\/bootstrap/d'
find $QUARTO_PROJECT_OUTPUT_DIR -name "*.html" -print0 | xargs -0 sed -i '/..\/site_libs\/quarto-html/d'
find $QUARTO_PROJECT_OUTPUT_DIR -name "*.html" -print0 | xargs -0 sed -i '/..\/site_libs\/clipboard/d'
find $QUARTO_PROJECT_OUTPUT_DIR -name "*.html" -print0 | xargs -0 sed -i '/..\/site_libs\/quarto-nav/d'
find $QUARTO_PROJECT_OUTPUT_DIR -name "*.html" -print0 | xargs -0 sed -i '/..\/site_libs\/quarto-search/d'
find $QUARTO_PROJECT_OUTPUT_DIR -name "*.html" -print0 | xargs -0 sed -i '/styles.css.map/d'

find $QUARTO_PROJECT_OUTPUT_DIR -name "*extract_all_images.html" -print0 | xargs -0 sed -i '/<script id="quarto-html-after-body"/,/<\/script>/d'
