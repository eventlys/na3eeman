import os
import re

app_dir = "lib/Packages"
strings_count = {}

for root, _, files in os.walk(app_dir):
    for filename in files:
        if not filename.endswith(".dart"): continue
        path = os.path.join(root, filename)
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Match Text('...') that doesn't end with .tr()
        matches = re.finditer(r"Text\s*\(\s*['\"](.*?)['\"]\s*(?:,|\))", content)
        for m in matches:
            text = m.group(1).strip()
            # Filter criteria
            if (not text or 
                '.tr()' in m.group(0) or 
                '$' in text or 
                '{' in text or 
                len(text) < 2 or
                text.startswith('/') or
                text.endswith('.png')):
                continue
            
            # Additional heuristic: checking if it's already a translation key
            if '_' in text and text.islower():
                continue
            
            strings_count[text] = strings_count.get(text, 0) + 1

        # Match (title|hintText|labelText): '...'
        matches2 = re.finditer(r"(title|labelText|hintText)\s*:\s*['\"](.*?)['\"]", content)
        for m in matches2:
            text = m.group(2).strip()
            if (not text or 
                '.tr()' in m.group(0) or 
                '$' in text or 
                '{' in text or 
                len(text) < 2 or
                text.startswith('/') or
                text.endswith('.png')):
                continue

            if '_' in text and text.islower():
                continue
            
            strings_count[text] = strings_count.get(text, 0) + 1

# Sort by frequency
sorted_strings = sorted(strings_count.items(), key=lambda x: x[1], reverse=True)

with open('/tmp/untranslated_strings.txt', 'w', encoding='utf-8') as f:
    for text, count in sorted_strings[:150]:
        f.write(f"{text}\n")

print(f"File created with {len(sorted_strings)} unique strings.")
