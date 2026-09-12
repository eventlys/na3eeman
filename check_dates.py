import yaml
import urllib.request
import json

with open("pubspec.yaml", "r") as f:
    data = yaml.safe_load(f)

deps = data.get("dependencies", {})
for name, version in deps.items():
    if name in ["flutter", "flutter_localizations"]: continue
    if type(version) is not str: continue
    
    try:
        url = f"https://pub.dev/api/packages/{name}"
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as response:
            res_data = json.loads(response.read().decode())
        
        latest = res_data.get("latest", {})
        published = latest.get("published", "")
        print(f"{name}: {published}")
    except Exception as e:
        print(f"{name}: error {e}")
