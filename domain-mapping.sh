#!/usr/bin/env bash

set -euo pipefail

# -----------------------------------------------------------------------------
# Project paths
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

TEMPLATES_DIR="$PROJECT_ROOT/src/templates/influencers"
OUTPUT_FILE="$PROJECT_ROOT/src/lib/records/prod.ts"


# -----------------------------------------------------------------------------
# Validate templates directory
# -----------------------------------------------------------------------------

if [[ ! -d "$TEMPLATES_DIR" ]]; then
    echo "Templates directory not found:"
    echo "$TEMPLATES_DIR"
    exit 1
fi

# -----------------------------------------------------------------------------
# Create/overwrite prod.ts
# -----------------------------------------------------------------------------

cat > "$OUTPUT_FILE" <<'EOF'
// AUTO-GENERATED FILE.
// DO NOT EDIT MANUALLY.

export const prodHostToTenant: Record<string, string> = {
EOF

# -----------------------------------------------------------------------------
# Generate mappings
# -----------------------------------------------------------------------------

COUNT=0

for file in "$TEMPLATES_DIR"/*.json; do
    [[ -e "$file" ]] || continue

    template="${file##*/}"
    template="${template%.json}"

    domain="${template}.influuencer.com"

    printf "  '%s': '%s',\n" "$domain" "$template" >> "$OUTPUT_FILE"
    echo "Processing: $template"
    COUNT=$((COUNT + 1))
    echo "Counter: $COUNT"
done

# -----------------------------------------------------------------------------
# Close object
# -----------------------------------------------------------------------------

echo "};" >> "$OUTPUT_FILE"

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

echo
echo "Generated $COUNT tenant mappings."
echo "Output: $OUTPUT_FILE"
