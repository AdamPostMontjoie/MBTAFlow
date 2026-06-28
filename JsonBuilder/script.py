import requests
import datetime
import json

# --- CONFIGURATION ---
# Set how many stops you want to process and print. 
# Set to None to process the entire route.
MAX_STOPS_TO_PROCESS = 5 
# ---------------------

def test_mbta_sequence():
    def print_json(data):
        print(json.dumps(data, indent=4))

    today = datetime.datetime.now().strftime('%Y-%m-%d')
    headers = {"accept": "application/vnd.api+json"}

    # ==========================================
    # STEP 1: FETCH THE TRIP
    # ==========================================
    print(f"--- Step 1: Fetching active trip for Red-1-0 on {today} ---")
    trips_url = f"https://api-v3.mbta.com/trips?filter[route_pattern]=Red-1-0&filter[date]={today}&page[limit]=1"
    trips_response = requests.get(trips_url, headers=headers).json()

    if not trips_response.get("data"):
        print("\nError: No trips found for this pattern today.")
        return

    trip_id = trips_response["data"][0]["id"]
    print(f"✅ Extracted Trip ID: '{trip_id}'")

    # ==========================================
    # STEP 2: FETCH THE SCHEDULE (SEQUENCE)
    # ==========================================
    print(f"\n--- Step 2: Fetching sequence for Trip {trip_id} ---")
    schedules_url = f"https://api-v3.mbta.com/schedules?filter[trip]={trip_id}&sort=stop_sequence"
    schedules_response = requests.get(schedules_url, headers=headers).json()

    schedules_data = schedules_response.get("data", [])
    if not schedules_data:
        print("\nFailed: Schedule array is empty.")
        return

    # Apply the limit to the array if one is set
    total_stops = len(schedules_data)
    if MAX_STOPS_TO_PROCESS:
        schedules_data = schedules_data[:MAX_STOPS_TO_PROCESS]
        print(f"⚠️ Limiting output to the first {MAX_STOPS_TO_PROCESS} of {total_stops} stops.")

    # Extract the limited platform IDs
    platform_ids = []
    for schedule in schedules_data:
        stop_id = schedule["relationships"]["stop"]["data"]["id"]
        platform_ids.append(stop_id)

    # ==========================================
    # STEP 3: FETCH THE PHYSICAL STOP DATA
    # ==========================================
    comma_separated_ids = ",".join(platform_ids)
    
    print(f"\n--- Step 3: Fetching physical data for {len(platform_ids)} platforms ---")
    stops_url = f"https://api-v3.mbta.com/stops?filter[id]={comma_separated_ids}"
    stops_response = requests.get(stops_url, headers=headers).json()

    print("\n[RAW JSON] STOPS RESPONSE (Limited Data):")
    print_json(stops_response)

    # ==========================================
    # FINAL OUTPUT (Side-by-Side Tabular)
    # ==========================================
    print("\n--- FINAL EXTRACTED DATA SUMMARY ---")
    stops_data = stops_response.get("data", [])
    
    stop_lookup = {stop["id"]: stop for stop in stops_data}

    # Print the table header
    print(f"{'SEQ':<5} | {'PLATFORM ID':<15} | {'PARENT ID':<15} | {'PLATFORM NAME'}")
    print("-" * 80)

    for schedule in schedules_data:
        seq = schedule["attributes"]["stop_sequence"]
        p_id = schedule["relationships"]["stop"]["data"]["id"]
        
        physical_stop = stop_lookup.get(p_id)
        
        if physical_stop:
            name = physical_stop["attributes"].get("name", "Unknown")
            
            # Safely check if parent_station exists
            parent = "None"
            parent_rel = physical_stop.get("relationships", {}).get("parent_station", {})
            if parent_rel and parent_rel.get("data"):
                parent = parent_rel["data"]["id"]
                
            # Print row with exact alignment
            print(f"{seq:<5} | {p_id:<15} | {parent:<15} | {name}")

if __name__ == "__main__":
    test_mbta_sequence()