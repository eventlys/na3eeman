import json
import urllib.request
import urllib.parse
from pathlib import Path
import time
import os

EN_PATH = "/home/azeez/Documents/proj/na3eeman/assets/Lang/en-US.json"
AR_PATH = "/home/azeez/Documents/proj/na3eeman/assets/Lang/ar-EG.json"

def translate_text(text, target_language, source_language="auto"):
    if not text.strip():
        return text
        
    url = "https://translate.googleapis.com/translate_a/single"
    params = {
        "client": "gtx",
        "sl": source_language,
        "tl": target_language,
        "dt": "t",
        "q": text
    }
    encoded_args = urllib.parse.urlencode(params)
    full_url = f"{url}?{encoded_args}"
    
    try:
        req = urllib.request.Request(full_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            return "".join([x[0] for x in result[0]])
    except Exception as e:
        print(f"Error translating '{text}': {e}")
        return text

def load_json(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_json(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def main():
    print("Loading language files...")
    if not os.path.exists(EN_PATH) or not os.path.exists(AR_PATH):
        print("Could not find translation files. Ensure paths are correct.")
        return

    en_data = load_json(EN_PATH)
    ar_data = load_json(AR_PATH)

    en_keys = set(en_data.keys())
    ar_keys = set(ar_data.keys())

    missing_in_en = ar_keys - en_keys
    missing_in_ar = en_keys - ar_keys

    changes_made = False

    if missing_in_en:
        print(f"Found {len(missing_in_en)} keys missing in English. Translating...")
        for key in missing_in_en:
            ar_text = ar_data[key]
            en_trans = translate_text(ar_text, "en", "ar")
            print(f" [+] {key}: '{ar_text}' -> '{en_trans}'")
            en_data[key] = en_trans
            changes_made = True
            time.sleep(0.5)

    if missing_in_ar:
        print(f"Found {len(missing_in_ar)} keys missing in Arabic. Translating...")
        for key in missing_in_ar:
            en_text = en_data[key]
            ar_trans = translate_text(en_text, "ar", "en")
            print(f" [+] {key}: '{en_text}' -> '{ar_trans}'")
            ar_data[key] = ar_trans
            changes_made = True
            time.sleep(0.5)

    if changes_made:
        print("Saving updated files...")
        save_json(EN_PATH, en_data)
        save_json(AR_PATH, ar_data)
        print("Done! Files successfully synced and translated.")
    else:
        print("Everything is up to date! No missing translations found.")

if __name__ == "__main__":
    main()
