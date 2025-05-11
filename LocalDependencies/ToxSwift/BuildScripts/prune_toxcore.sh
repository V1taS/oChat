#!/usr/bin/env bash
set -euo pipefail

ROOT="Sources/CTox/toxcore"
CDIR="$(cd "$(dirname "$0")" && pwd)"
cd "$CDIR/$ROOT"

echo "🧹  Cleaning $PWD …"

# ─── 1. каталоги, которые удаляем целиком
drop_dirs=(auto_tests testing fuzzing other examples example test tests)

for dir in "${drop_dirs[@]}"; do
  find . -type d -name "$dir" -prune -exec rm -rf {} +
done

# ─── 2. одиночные test/bench-файлы
find . -type f \( -name 'test*.[cC][cCpPxX]*'  -o \
                  -name '*_test.*'             -o \
                  -name '*_bench.*'            \) -print0 | xargs -0 rm -f

echo "✅  Done."