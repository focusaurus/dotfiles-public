#!/usr/bin/env python3
import json
import os
import re
import sys

TRAILING_WHITESPACE = re.compile(r"\s+$", re.M)

obj = None
try:
    obj = json.loads(sys.stdin.read())
except ValueError as info:
    print("Invalid JSON provided", info)
    sys.exit(1)
pretty = json.dumps(obj, sort_keys=True, indent=2)
pretty = TRAILING_WHITESPACE.sub("", pretty)
print(pretty)
