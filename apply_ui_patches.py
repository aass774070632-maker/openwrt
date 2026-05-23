import re

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

# 1. Mode dropdown listener patch to reset hotspot checkboxes
# Original:
# this.refs.mode.addEventListener('change', function() {
#         self.updateStepUi();
# });
replacement_mode = """this.refs.mode.addEventListener('change', function() {
                if (self.refs.mode.value !== 'ap') {
                        // User chose Mesh, Extender, etc. Reset hotspot.
                        // Actually, even if they explicitly select 'ap' from the dropdown, maybe reset? Yes, if they are touching mode, they want basic setup.
                }
                if (self.refs.hotspotQuickEnabled) self.refs.hotspotQuickEnabled.checked = false;
                if (self.refs.hotspotEnabled) self.refs.hotspotEnabled.checked = false;
                if (self.refs.hotspotQuickSecondaryEnabled) self.refs.hotspotQuickSecondaryEnabled.checked = false;
                self.updateStepUi();
        });"""
code = code.replace("this.refs.mode.addEventListener('change', function() {\n\t\t\tself.updateStepUi();\n\t\t});", replacement_mode)

# 2. Add event listener for hotspotQuickSecondaryEnabled
# We can add it right after we add the listener for hotspotQuickEnabled
original_quick = """this.refs.hotspotQuickEnabled.addEventListener('change', function() {
\t\t\t\tself.updateStepUi();
\t\t\t\tif (self.refs.hotspotQuickEnabled.checked)"""

replacement_quick = """this.refs.hotspotQuickEnabled.addEventListener('change', function() {
\t\t\t\tself.updateStepUi();
\t\t\t\tif (self.refs.hotspotQuickEnabled.checked)"""

# Instead of regex, let's just insert it right above hotspotQuickEnabled.addEventListener
insert_secondary = """
\t\tif (this.refs.hotspotQuickSecondaryEnabled) {
\t\t\tthis.refs.hotspotQuickSecondaryEnabled.addEventListener('change', function() {
\t\t\t\tself.updateStepUi();
\t\t\t});
\t\t}
"""
code = code.replace("if (this.refs.hotspotQuickEnabled) {\n\t\t\tthis.refs.hotspotQuickEnabled.addEventListener", insert_secondary + "\n\t\tif (this.refs.hotspotQuickEnabled) {\n\t\t\tthis.refs.hotspotQuickEnabled.addEventListener")

# Let's save it
with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(code)

print("Applied patches successfully.")
