
import sys

tsoFile = sys.argv[1]
scFile = sys.argv[2]
diffFile = sys.argv[3]

with open(tsoFile) as f:
    tsoLines = f.readlines()

with open(scFile) as f:
    scLines = f.readlines()

diffLines = set(tsoLines) - set(scLines)

with (open(diffFile, "w")) as f:
    f.writelines(list(diffLines))

