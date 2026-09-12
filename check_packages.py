import yaml
import json
import urllib.request
import re
import time

def get_package_info(name):
    try:
        url = f"https://pub.dev/api/packages/{name}"
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
        
        is_discontinued = data.get("isDiscontinued", False)
        
        score_url = f"https://pub.dev/api/packages/{name}/score"
        score_req = urllib.request.Request(score_url)
        try:
            with urllib.request.urlopen(score_req) as response:
                score_data = json.loads(response.read().decode())
                likes = score_data.get("likeCount", 0)
        except Exception:
            likes = 0
            
        latest_version = data.get("latest", {}).get("version", "unknown")
            
        return {
            "discontinued": is_discontinued,
            "likes": likes,
            "latest_version": latest_version
        }
    except Exception as e:
        return {"error": str(e)}

def main():
    with open("pubspec.yaml", "r") as f:
        data = yaml.safe_load(f)
    
    deps = data.get("dependencies", {})
    
    for name, version in deps.items():
        if name in ["flutter", "flutter_localizations"]: continue
        if type(version) is not str: continue
        
        v = str(version)
        is_0_x = v.startswith("^0.") or v.startswith("0.")
        is_beta_alpha = "beta" in v or "alpha" in v or "dev" in v
        
        info = get_package_info(name)
        if "error" in info:
            print(f"{name} ({v}): Error {info['error']}")
        else:
            print(f"{name} ({v}): Likes={info['likes']}, Discontinued={info['discontinued']}, 0.x={is_0_x}, beta/alpha={is_beta_alpha}, latest={info['latest_version']}")
        time.sleep(0.1)

if __name__ == '__main__':
    main()
