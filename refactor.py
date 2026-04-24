import os
import re

def to_camel(s):
    if not s: return s
    if s[0].isdigit(): s = 'key_' + s
    c = re.split(r'[^a-zA-Z0-9]', s)
    res = c[0] + ''.join(x.title() for x in c[1:])
    dart_keywords = {
        'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch', 'class', 'const',
        'continue', 'covariant', 'default', 'deferred', 'do', 'dynamic', 'else', 'enum', 'export',
        'extends', 'extension', 'external', 'factory', 'false', 'final', 'finally', 'for', 'Function',
        'get', 'hide', 'if', 'implements', 'import', 'in', 'interface', 'is', 'late', 'library',
        'mixin', 'native', 'new', 'null', 'on', 'operator', 'part', 'required', 'rethrow', 'return',
        'set', 'show', 'static', 'super', 'switch', 'sync', 'this', 'throw', 'true', 'try', 'typedef',
        'var', 'void', 'while', 'with', 'yield'
    }
    if res in dart_keywords:
        res += 'Key'
    return res

tr_pattern = re.compile(r"['\"]([a-zA-Z0-9_]+)['\"]\s*\.tr\(\)")

hardcoded_patterns = {
    "You do not have permission to view this page.": "noPermissionMessage",
    "Back to Home": "backToHome",
    "No data available": "noDataAvailable",
    "Remove Permanently": "removePermanently",
    "Add Stock": "addStock",
    "All stock levels are nominal.": "allStockNominal",
    "No appointments scheduled for today.": "noAppointmentsScheduled"
}

def refactor(path):
    with open(path, 'r') as f:
        content = f.read()
    
    new = content
    matches = tr_pattern.findall(content)
    
    needs_hardcoded = False
    for r in hardcoded_patterns:
        if f"'{r}'" in new or f'"{r}"' in new:
            needs_hardcoded = True
            break
            
    if matches or needs_hardcoded:
        if 'app_localizations.dart' not in new and 'main.dart' not in path and 'app_localizations' not in path:
            new = "import 'package:na3eeman/l10n/app_localizations.dart';\n" + new
            
    for k in matches:
        camel = to_camel(k)
        new = new.replace(f"'{k}'.tr()", f"AppLocalizations.of(context)!.{camel}")
        new = new.replace(f'"{k}".tr()', f"AppLocalizations.of(context)!.{camel}")
        
    for r, k in hardcoded_patterns.items():
        new = new.replace(f"'{r}'", f"AppLocalizations.of(context)!.{k}")
        new = new.replace(f'"{r}"', f"AppLocalizations.of(context)!.{k}")
        
    if content != new:
        with open(path, 'w') as f:
            f.write(new)
        return True
    return False

if __name__ == '__main__':
    count = 0
    # Process only lib/
    base_dir = '/home/azeez/Documents/proj/na3eeman/lib'
    for r, d, fs in os.walk(base_dir):
        # Skip generated or hidden directories
        if 'l10n' in r or '/.' in r:
            continue
        for f in fs:
            if f.endswith('.dart'):
                if refactor(os.path.join(r, f)):
                    count += 1
    print(f"Refactored {count} files")
