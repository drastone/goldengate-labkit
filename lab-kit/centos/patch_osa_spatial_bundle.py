#!/usr/bin/env python3
import hashlib
import pathlib
import sys


ORIGINAL_SHA256 = "dd38791b1dac5f68e7a77e43b9533437e0b8891ef9d05721494a5c4a6b03f5f7"
PATCHED_SHA256 = "130e47692e5dc08901e04526cc9f8e2397be4e2c71994ac1bfb4d74abea05cd1"
ORIGINAL_MODULE_SHA256 = "d50b5b03f8fca664447f0cdbe28e9c1340abb2ada33960d20e2ea1e775e59ab3"
PATCHED_MODULE_SHA256 = "5d7d0af151e54be65aa99f3cd52207cec4994eecf7339f91bdba18c9a00d5723"


def sha256(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


if len(sys.argv) != 2:
    raise SystemExit("usage: patch_osa_spatial_bundle.py BUNDLE")

path = pathlib.Path(sys.argv[1])
content = path.read_text(encoding="utf-8")
current_hash = sha256(content)

if current_hash in (PATCHED_SHA256, PATCHED_MODULE_SHA256):
    print(current_hash)
    raise SystemExit(0)
if current_hash not in (ORIGINAL_SHA256, ORIGINAL_MODULE_SHA256):
    raise SystemExit(f"unsupported OSA bundle sha256: {current_hash}")

if current_hash == ORIGINAL_MODULE_SHA256:
    module_start = 0
    module_end = len(content)
    expected_hash = PATCHED_MODULE_SHA256
else:
    module_start = content.index(
        "define('features/visualization/components/vizChart/SpatialMap'"
    )
    module_end = content.index("\ndefine(", module_start + 1)
    expected_hash = PATCHED_SHA256
module = content[module_start:module_end]

old_center = "center:[0,0],zoom:1"
new_center = "center:[126.978,37.5665],zoom:10"
old_auto_focus = "o.default.setCenterAndZoomWithPlaces(y,t),k(!1)"
new_auto_focus = "k(!1)"
if module.count(old_center) != 1:
    raise SystemExit(f"expected one SpatialMap center, found {module.count(old_center)}")
if module.count(old_auto_focus) != 1:
    raise SystemExit(
        f"expected one SpatialMap auto-focus call, found {module.count(old_auto_focus)}"
    )

module = module.replace(old_center, new_center, 1)
module = module.replace(old_auto_focus, new_auto_focus, 1)
patched = content[:module_start] + module + content[module_end:]
patched_hash = sha256(patched)
if patched_hash != expected_hash:
    raise SystemExit(f"unexpected patched OSA bundle sha256: {patched_hash}")

path.write_text(patched, encoding="utf-8")
print(patched_hash)
