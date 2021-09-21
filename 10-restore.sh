#!/bin/bash
set -euo pipefail

echo "Restoring $DUMP_FILE"
pg_restore -U postgres -C -d postgres --verbose < "$DUMP_FILE"


