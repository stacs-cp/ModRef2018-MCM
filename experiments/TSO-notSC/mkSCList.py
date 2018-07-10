
import sys

with open(sys.argv[1]) as f:
    lines = f.readlines()

print("    { " + "    , ".join(lines) + "    }")
