import re
from collections import Counter

with open("analyze.txt", "r") as f:
    lines = f.readlines()

counts = Counter()
for line in lines:
    match = re.search(r'\s+-\s+([a-zA-Z0-9_]+)$', line.strip())
    if match:
        counts[match.group(1)] += 1

for k, v in counts.most_common():
    print(f"{k}: {v}")
