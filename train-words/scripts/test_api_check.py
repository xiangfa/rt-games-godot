import requests
import json
import time

BASE_URL = "https://rtstgapi-d5e4bjbua2cjbdg6.westus2-01.azurewebsites.net/api"

def probe_dictionary_api():
    session = requests.Session()
    
    # 1. Login (Admin)
    print("Logging in as Admin...")
    login_payload = {
        "email": "nightwithmoon@yahoo.com",
        "password": "Test@1234"
    }
    resp = session.post(f"{BASE_URL}/staffs/sessions", json=login_payload)
    
    if resp.status_code != 201:
        print("Login failed:", resp.text)
        return
    
    token = resp.json().get("data", {}).get("access")
    if not token:
        print("No token.")
        return

    headers = {"Authorization": f"Bearer {token}"}
    print("Admin Login successful.")

    # 2. Fetch Dictionary List (Scan Pages)
    print("Scanning Dictionary List for images...")
    
    found_images = []
    max_pages = 5
    page_size = 100
    
    for page in range(1, max_pages + 1):
        print(f"Fetching Page {page}...")
        resp = session.get(f"{BASE_URL}/dictionary?pageSize={page_size}&current={page}", headers=headers)
        
        if resp.status_code != 200:
            print(f"Page {page} failed: {resp.status_code}")
            continue
            
        data_container = resp.json().get("data", {})
        if isinstance(data_container, list):
            data = data_container
        else:
            data = data_container.get("data", [])
            if not data and "list" in data_container:
                data = data_container["list"]
        
        if not data:
            print("No more data.")
            break
            
        print(f"  Scanned {len(data)} words on page {page}.")
        
        for item in data:
            if item.get("image") and item["image"].get("url"):
                img_url = item["image"]["url"]
                if img_url:
                    found_images.append(item)
                    print(f"  ✓ FOUND Image for word '{item.get('word')}': {img_url}")
                    
        if len(found_images) >= 3:
            print("Found enough images!")
            break
            
    print(f"Total Words with images found: {len(found_images)}")
    
    if len(found_images) > 0:
        print("Sample with Image:")
        print(json.dumps(found_images[0], indent=2))

if __name__ == "__main__":
    probe_dictionary_api()
