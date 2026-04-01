import os
import json
import csv
import sys

EN_PATH = "assets/Lang/en-US.json"
AR_PATH = "assets/Lang/ar-EG.json"
CSV_PATH = "translations.csv"

def export_to_csv():
    # Load JSON files
    with open(EN_PATH, 'r', encoding='utf-8') as f:
        en_data = json.load(f)
    
    with open(AR_PATH, 'r', encoding='utf-8') as f:
        ar_data = json.load(f)

    # Collect all unique keys
    all_keys = sorted(list(set(en_data.keys()).union(set(ar_data.keys()))))
    
    with open(CSV_PATH, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Key', 'English (en-US)', 'Arabic (ar-EG)'])
        
        for key in all_keys:
            en_text = en_data.get(key, "")
            ar_text = ar_data.get(key, "")
            writer.writerow([key, en_text, ar_text])

    print(f"✅ Successfully exported all translations to: {CSV_PATH}")
    print("You can now open translations.csv in Excel/Numbers, make changes, and run 'python3 translations_manager.py import' to save them back.")


def import_from_csv():
    if not os.path.exists(CSV_PATH):
        print(f"❌ Error: {CSV_PATH} not found.")
        return

    en_data = {}
    ar_data = {}

    with open(CSV_PATH, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        header = next(reader, None) # skip header
        
        for row in reader:
            if not row or len(row) < 3: continue
            key, en_text, ar_text = row[0].strip(), row[1].strip(), row[2].strip()
            if not key: continue

            en_data[key] = en_text
            ar_data[key] = ar_text

    # Write back to JSON
    with open(EN_PATH, 'w', encoding='utf-8') as f:
        json.dump(en_data, f, ensure_ascii=False, indent=2)
    
    with open(AR_PATH, 'w', encoding='utf-8') as f:
        json.dump(ar_data, f, ensure_ascii=False, indent=2)

    print(f"✅ Successfully imported {len(en_data)} translations!")
    print(f"Updated: {EN_PATH}\nUpdated: {AR_PATH}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print("  To export JSON to CSV: python3 translations_manager.py export")
        print("  To import CSV to JSON: python3 translations_manager.py import")
        sys.exit(1)
        
    command = sys.argv[1].lower()
    if command == "export":
        export_to_csv()
    elif command == "import":
        import_from_csv()
    else:
        print("Unknown command. Use 'export' or 'import'")
