#!/bin/bash

# ---------------------------------------------------------------------------
# Workaround: cargokit (irondash_engine_context, super_native_extensions) on Gradle 9
#
# Gradle 9 removed Project.exec(), which cargokit's plugin.gradle calls when it
# builds the Rust libraries. The patch runs the same commands through the
# injected ExecOperations service instead. Idempotent.
# ---------------------------------------------------------------------------

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

PACKAGES=("irondash_engine_context-0.5.5" "super_native_extensions-0.9.1")

for package in "${PACKAGES[@]}"; do
    file="$HOME/.pub-cache/hosted/pub.dev/${package}/cargokit/gradle/plugin.gradle"
    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}[patch_cargokit_gradle9] ${package} not found — skipping${NC}"
        continue
    fi
    if grep -q "ExecOperations" "$file"; then
        echo -e "${GREEN}[patch_cargokit_gradle9] ${package} already patched${NC}"
        continue
    fi
    python3 - "$file" <<'PY'
import sys
path = sys.argv[1]
text = open(path).read()
text = text.replace(
    "import org.apache.tools.ant.taskdefs.condition.Os\n",
    "import org.apache.tools.ant.taskdefs.condition.Os\nimport org.gradle.process.ExecOperations\nimport javax.inject.Inject\n",
    1,
)
text = text.replace(
    "abstract class CargoKitBuildTask extends DefaultTask {\n",
    "abstract class CargoKitBuildTask extends DefaultTask {\n\n    @Inject\n    abstract ExecOperations getExecOperations()\n",
    1,
)
text = text.replace("project.exec {", "execOperations.exec {")
open(path, "w").write(text)
PY
    echo -e "${GREEN}[patch_cargokit_gradle9] Patched ${package}${NC}"
done
