#!/usr/bin/env python3
"""
update_graphify.py — Fast, local-first Graphify knowledge graph update script for freeOCR.me.

Enforces:
1. Local-first execution without external network delays (skips Pollinations/cloud LLM calls).
2. Filters out huge minified Flutter build artifacts (main.dart.js, canvaskit, .dart_tool) from lineage analysis to avoid catastrophic regex backtracking.
"""

import sys
import time
from pathlib import Path

# Ensure graphify can be imported
import graphify.ai
import graphify.watch
import graphify.lineage

# 1. Local-first: no hanging HTTP calls to external APIs
graphify.ai.Summarizer.is_available = lambda self: False

# 2. Skip minified build artifacts in lineage analysis
def fast_lineage(self):
    for py_path in self.root.glob('**/*.py'):
        if any(x in str(py_path) for x in ('node_modules', 'graphify-out', 'build', '.dart_tool')):
            continue
        self._analyze_python(py_path)
    for ext in ('*.js', '*.ts', '*.tsx'):
        for path in self.root.glob(f'**/{ext}'):
            if any(x in str(path) for x in ('node_modules', 'graphify-out', 'build', '.dart_tool')):
                continue
            self._analyze_javascript(path)
    return self.lineage_edges

graphify.lineage.LineageAnalyzer.analyze = fast_lineage

def main():
    root = Path(__file__).resolve().parent.parent / "src"
    t0 = time.time()
    print(f"Starting Graphify update for {root}...", flush=True)
    ok = graphify.watch._rebuild_code(root)
    if ok:
        print(f"Graphify knowledge graph successfully updated in {time.time()-t0:.2f}s.", flush=True)
        sys.exit(0)
    else:
        print("Graphify update failed.", file=sys.stderr, flush=True)
        sys.exit(1)

if __name__ == "__main__":
    main()
