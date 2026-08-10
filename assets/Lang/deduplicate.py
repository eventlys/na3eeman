import json
from collections import OrderedDict

def deduplicate_json(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We can't use json.loads because it will automatically overwrite duplicate keys
    # and we want to be sure which one it keeps.
    # Actually, json.loads with object_pairs_hook=OrderedDict will keep the LAST one.
    # Most localization systems prefer the first one or the last one? 
    # Usually the last one is the one that was added later.
    
    try:
        data = json.loads(content, object_pairs_hook=OrderedDict)
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Successfully deduplicated {file_path}")
    except Exception as e:
        print(f"Error deduplicating {file_path}: {e}")

deduplicate_json('/home/azeez/Documents/proj/n3eemn/assets/Lang/en-US.json')
deduplicate_json('/home/azeez/Documents/proj/n3eemn/assets/Lang/ar-EG.json')
