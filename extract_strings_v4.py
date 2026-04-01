import os
import re
import json

app_dir = "lib"
strings_count = {}

for root, _, files in os.walk(app_dir):
    for filename in files:
        if not filename.endswith(".dart"): continue
        path = os.path.join(root, filename)
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Match Text('...') and Text("...")
        matches = re.finditer(r"Text\s*\(\s*(['\"])(.*?)\1\s*(?:,|\))", content)
        for m in matches:
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
            if re.search(r'[\u0600-\u06FF]', text): # Arabic text already
                continue
            
            strings_count[text] = strings_count.get(text, 0) + 1

        # Match (title|labelText|hintText|content|text|label): '...'
        matches2 = re.finditer(r"(title|labelText|hintText|content|text|label|message)\s*:\s*(['\"])(.*?)\2", content)
        for m in matches2:
            text = m.group(3).strip()
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
            if re.search(r'[\u0600-\u06FF]', text): # Arabic text already
                continue
            
            strings_count[text] = strings_count.get(text, 0) + 1

# Sort by frequency
sorted_strings = sorted(strings_count.items(), key=lambda x: x[1], reverse=True)

final_strings = [text for text, count in sorted_strings[:200]]

with open('/tmp/untranslated_strings_v4.json', 'w', encoding='utf-8') as f:
    json.dump(final_strings, f, indent=2)

print(f"Extracted {len(final_strings)} strings.")
