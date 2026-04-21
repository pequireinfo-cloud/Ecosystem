import json
import csv
import random
import math
from datetime import datetime, timedelta

# Constants
TOTAL_RECORDS = 10000
NAVEEN_MARKET = (26.4716, 80.3512)
CITY = "Kanpur"

# Data Pools
FIRST_NAMES = ["Amit", "Rahul", "Sunil", "Rajesh", "Pankaj", "Vikas", "Karan", "Arjun", "Sanjay", "Arvind", 
               "Manoj", "Suresh", "Deepak", "Ankit", "Ravi", "Sandeep", "Ajay", "Vishal", "Pradeep", "Manish",
               "Salman", "Imran", "Irfan", "Sameer", "Shakeel", "Aman", "Rohan", "Deepak", "Sumit", "Jitendra"]
LAST_NAMES = ["Sharma", "Verma", "Singh", "Gupta", "Yadav", "Khan", "Ahmad", "Mishra", "Tiwari", "Dwivedi", 
              "Pandey", "Saini", "Jain", "Agarwal", "Shukla", "Maurya", "Kushwaha", "Chauhan", "Rathore", "Kapoor"]

CATEGORIES = {
    "Carpentry": ["door repair", "cabinet", "bed repair", "furniture polish", "modular kitchen", "window repair", "sofa repair"],
    "Plumbing": ["pipe leak", "geyser", "tap fitting", "toilet blockage", "water tank cleaning", "shower repair", "sink repair"],
    "Electrical": ["AC repair", "fan repair", "wiring", "inverter", "refrigerator", "washing machine", "geyser repair", "LED lighting"],
    "Laundry": ["dry clean", "stain removal", "bridal wear", "woolens", "steam iron", "curtain cleaning", "carpet cleaning"]
}

LOCALITIES = [
    {"name": "Civil Lines", "coords": (26.47, 80.35), "weight": 10},
    {"name": "Kidwai Nagar", "coords": (26.42, 80.33), "weight": 8},
    {"name": "Kalyanpur", "coords": (26.50, 80.26), "weight": 7},
    {"name": "Panki", "coords": (26.48, 80.24), "weight": 5},
    {"name": "Jajmau", "coords": (26.43, 80.40), "weight": 6},
    {"name": "Barra", "coords": (26.41, 80.29), "weight": 9},
    {"name": "Swaroop Nagar", "coords": (26.48, 80.32), "weight": 10},
    {"name": "Kakadeo", "coords": (26.48, 80.29), "weight": 9},
    {"name": "Gumti No. 5", "coords": (26.46, 80.31), "weight": 10},
    {"name": "Naubasta", "coords": (26.40, 80.33), "weight": 7},
    {"name": "Govind Nagar", "coords": (26.44, 80.29), "weight": 8},
    {"name": "Shyam Nagar", "coords": (26.43, 80.37), "weight": 6},
    {"name": "Cantonment", "coords": (26.46, 80.37), "weight": 5},
    {"name": "Azad Nagar", "coords": (26.49, 80.29), "weight": 4},
    {"name": "Vishnupuri", "coords": (26.49, 80.30), "weight": 4},
    {"name": "Bithoor", "coords": (26.61, 80.27), "weight": 2} # Sparse zone
]

LANGUAGES = ["Hindi", "English", "Punjabi", "Bhojpuri"]
SLOTS = ["09:00 AM - 11:00 AM", "11:00 AM - 01:00 PM", "01:00 PM - 03:00 PM", "03:00 PM - 05:00 PM", "05:00 PM - 07:00 PM"]

def haversine(lat1, lon1, lat2, lon2):
    R = 6371  # Earth radius in km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2
    c = 2 * math.asin(math.sqrt(a))
    return R * c

def generate_provider(pid):
    # Name
    name = f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"
    
    # Category & Expertise
    category = random.choice(list(CATEGORIES.keys()))
    expertise = random.sample(CATEGORIES[category], random.randint(2, 6))
    
    # Locality & Coords
    loc_item = random.choices(LOCALITIES, weights=[l["weight"] for l in LOCALITIES])[0]
    # Add some randomness to coords (approx 1-2km)
    lat = loc_item["coords"][0] + random.uniform(-0.015, 0.015)
    lon = loc_item["coords"][1] + random.uniform(-0.015, 0.015)
    
    dist_km = round(haversine(lat, lon, NAVEEN_MARKET[0], NAVEEN_MARKET[1]), 2)
    
    # Performance metrics
    # Most are 3.5 - 5.0
    if random.random() < 0.05: # Edge case: low rated
        rating = round(random.uniform(1.0, 3.4), 1)
    else:
        rating = round(random.uniform(3.5, 5.0), 1)
        
    jobs = random.randint(0, 500)
    if random.random() < 0.1: # New provider
        jobs = random.randint(0, 5)
        
    # Status
    status = random.choices(["Online", "Offline", "Busy"], weights=[60, 25, 15])[0]
    
    # Experience
    exp = random.randint(1, 25)
    if jobs > 100:
        exp = max(exp, 3) # Experienced guys usually have jobs
        
    # Phone
    phone = f"+91 {random.randint(6, 9)}{random.randint(0, 9)}{random.randint(10000000, 99999999)}"
    
    # Email
    email = f"{name.lower().replace(' ', '.')}.{pid}@pequire.com"

    return {
        "provider_id": pid,
        "fullName": name,
        "email": email,
        "phoneNumber": phone,
        "serviceType": category,
        "expertise": expertise,
        "experienceYears": exp,
        "status": status,
        "kycStatus": "Verified" if random.random() > 0.1 else "Pending",
        "rating": rating,
        "totalJobsCompleted": jobs,
        "acceptanceRate": random.randint(60, 100),
        "cancellationRate": random.randint(0, 15) if rating > 4 else random.randint(0, 40),
        "avgResponseSeconds": random.randint(30, 3600),
        "serviceRadiusKm": random.randint(5, 25),
        "priceLevel": random.choice(["budget", "standard", "premium"]),
        "location": {
            "latitude": lat,
            "longitude": lon,
            "geo": {
                "type": "Point",
                "coordinates": [lon, lat]
            },
            "address": f"{loc_item['name']}, {CITY}",
            "distance_km": dist_km
        },
        "languages": random.sample(LANGUAGES, random.randint(1, 3)),
        "availableSlots": random.sample(SLOTS, random.randint(2, 5)),
        "createdAt": (datetime.now() - timedelta(days=random.randint(0, 365))).isoformat()
    }

print(f"Generating {TOTAL_RECORDS} records for Kanpur...")
providers = [generate_provider(i+1) for i in range(TOTAL_RECORDS)]

# Special case: Clusters at same location
for i in range(10):
    idx1 = random.randint(0, TOTAL_RECORDS-1)
    idx2 = random.randint(0, TOTAL_RECORDS-1)
    providers[idx2]["location"]["latitude"] = providers[idx1]["location"]["latitude"]
    providers[idx2]["location"]["longitude"] = providers[idx1]["location"]["longitude"]

# Save JSON
with open('providers.json', 'w') as f:
    json.dump(providers, f, indent=2)

# Save CSV
with open('providers.csv', 'w', newline='') as f:
    field_names = list(providers[0].keys())
    field_names.remove("location")
    field_names.extend(["latitude", "longitude", "address", "distance_km"])
    writer = csv.DictWriter(f, fieldnames=field_names)
    writer.writeheader()
    # Flatten location for CSV
    for p in providers:
        row = p.copy()
        loc = row.pop("location")
        row["latitude"] = loc["latitude"]
        row["longitude"] = loc["longitude"]
        row["address"] = loc["address"]
        row["distance_km"] = loc["distance_km"]
        row["expertise"] = ",".join(row["expertise"])
        row["languages"] = ",".join(row["languages"])
        row["availableSlots"] = ",".join(row["availableSlots"])
        writer.writerow(row)

print("Created providers.json and providers.csv")
