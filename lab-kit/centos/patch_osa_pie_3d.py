#!/usr/bin/env python3
import pathlib
import sys


MODULE_PATCHES = {
    "features/visualization/models/charts/PieChart": (
        (
            'userSpecifiedPropertiesToPayload(e){return{groupField:[e.groupField],measureField:[e.measureField],threed:"off"}}',
            'userSpecifiedPropertiesToPayload(e){return{groupField:[e.groupField],measureField:[e.measureField],threed:e.threed||"off"}}',
        ),
        (
            'measureField:null===(i=e.measureField)||void 0===i?void 0:i[0]}}convertPayloadChartPropertiesToOJChartProperties(e){return{type:"pie"}}',
            'measureField:null===(i=e.measureField)||void 0===i?void 0:i[0],threed:e.threed||"off"}}convertPayloadChartPropertiesToOJChartProperties(e){return{type:"pie",styleDefaults:{threeDEffect:e.userSpecifiedProperties.threed||"off"}}}',
        ),
    ),
    "features/visualization/components/vizChart/VizChart": (
        (
            'orientation:p.orientation,legend:p.legend,children:',
            'orientation:p.orientation,legend:p.legend,styleDefaults:p.styleDefaults,children:',
        ),
    ),
    "features/visualization/components/chartProperties/PieChartProperties": (
        (
            '"preact","oj-c/select-single"],(function',
            '"preact","oj-c/select-single","oj-c/checkbox"],(function',
        ),
        (
            '({key:t,value:a.detail.value}))',
            '({key:t,value:"threed"===t?a.detail.value?"on":"off":a.detail.value}))',
        ),
        (
            'onvalueChanged:g("groupField")},"groupField")]})}}));',
            'onvalueChanged:g("groupField")},"groupField"),(0,t.jsx)("oj-c-checkbox",{value:"on"===(null==u?void 0:u.threed),userAssistanceDensity:"compact",onvalueChanged:g("threed"),children:"Use 3D rendering"},"threed")]})}}));',
        ),
    ),
}

FILE_MODULES = {
    "PieChart.js": ("features/visualization/models/charts/PieChart",),
    "VizChart.js": ("features/visualization/components/vizChart/VizChart",),
    "PieChartProperties.js": (
        "features/visualization/components/chartProperties/PieChartProperties",
    ),
    "bundle.js": tuple(MODULE_PATCHES),
}


if len(sys.argv) != 2:
    raise SystemExit("usage: patch_osa_pie_3d.py OSA_JAVASCRIPT_FILE")

path = pathlib.Path(sys.argv[1])
content = path.read_text(encoding="utf-8")
changed = 0

modules = FILE_MODULES.get(path.name)
if not modules:
    raise SystemExit(f"unsupported OSA JavaScript file: {path}")

for module_name in modules:
    if path.name == "bundle.js":
        module_start = content.index(f"define('{module_name}'")
        try:
            module_end = content.index("\ndefine(", module_start + 1)
        except ValueError:
            module_end = len(content)
    else:
        module_start = 0
        module_end = len(content)

    module = content[module_start:module_end]
    module_changed = 0
    for original, patched in MODULE_PATCHES[module_name]:
        original_count = module.count(original)
        patched_count = module.count(patched)
        if original_count == 1 and patched_count == 0:
            module = module.replace(original, patched, 1)
            module_changed += 1
        elif original_count == 0 and patched_count == 1:
            continue
        else:
            raise SystemExit(
                f"unsupported or ambiguous OSA module {module_name} in {path}: "
                f"original={original_count}, patched={patched_count}"
            )

    content = content[:module_start] + module + content[module_end:]
    changed += module_changed

if path.name == "PieChart.js" and "threeDEffect" not in content:
    raise SystemExit(f"unsupported OSA Pie chart module: {path}")
if path.name == "PieChartProperties.js" and "Use 3D rendering" not in content:
    raise SystemExit(f"unsupported OSA Pie chart properties module: {path}")
if "VizChart" in path.name and "styleDefaults:p.styleDefaults" not in content:
    raise SystemExit(f"unsupported OSA chart renderer module: {path}")
if path.name == "bundle.js":
    required = (
        "Use 3D rendering",
        "threeDEffect:e.userSpecifiedProperties.threed",
        "styleDefaults:p.styleDefaults",
    )
    if not all(marker in content for marker in required):
        raise SystemExit(f"unsupported OSA UI bundle: {path}")

if changed:
    path.write_text(content, encoding="utf-8")
    print(f"patched:{changed}")
else:
    print("already-patched")
