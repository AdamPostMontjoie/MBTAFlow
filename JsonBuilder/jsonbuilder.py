import requests
import datetime
import json

#python.terminal.useEnvFile

# Query the API for every route too, for commuter rail purposes
TARGET_ROUTES = [
    # Subways
    "Red", "Orange", "Blue", "Green-B", "Green-C", "Green-D", "Green-E", "Mattapan",
    # Commuter Rail (Examples)
    "CR-Fitchburg", "CR-Lowell", "CR-Providence", "CR-Worcester", 
    # Ferries (Examples)
    "Boat-F1", "Boat-F4"
]

HEADERS = {"accept": "application/vnd.api+json"}

def build_sequences():
    final_sequences = []

    print(f"Starting Sequence Extraction for {len(TARGET_ROUTES)} routes...\n")

    for route_id in TARGET_ROUTES:
        print(f"=== Processing Route: {route_id} ===")
        
        # 1. Fetch Route Patterns
        patterns_url = f"https://api-v3.mbta.com/route_patterns?filter[route]={route_id}"
        patterns_response = requests.get(patterns_url, headers=HEADERS).json()
        
        patterns_data = patterns_response.get("data", [])
        if not patterns_data:
            print(f"  ⚠️ No patterns found for {route_id}. Skipping.")
            continue

        for pattern in patterns_data:
            pattern_id = pattern["id"]
            direction_id = pattern["attributes"]["direction_id"]
            
            print(f"  -> Pattern: {pattern_id} (Direction {direction_id})")

            # 2. Fetch the first real trip for this pattern
            # We omit the date filter to just grab the first available scheduled trip in the current rating
            trips_url = f"https://api-v3.mbta.com/trips?filter[route_pattern]={pattern_id}&page[limit]=1"
            trips_response = requests.get(trips_url, headers=HEADERS).json()
            time.sleep(0.2) # Rate limit safety

            trips_data = trips_response.get("data", [])
            if not trips_data:
                print(f"     ⚠️ No active trips found for pattern {pattern_id}. Skipping.")
                continue

            trip_id = trips_data[0]["id"]

            # 3. Fetch the schedule sequence for that trip
            schedules_url = f"https://api-v3.mbta.com/schedules?filter[trip]={trip_id}&sort=stop_sequence"
            schedules_response = requests.get(schedules_url, headers=HEADERS).json()
            time.sleep(0.2) # Rate limit safety

            schedules_data = schedules_response.get("data", [])
            if not schedules_data:
                print(f"     ⚠️ Schedule array empty for trip {trip_id}. Skipping.")
                continue

            # 4. Extract sequence items and platform IDs
            stops_added = 0
            for schedule in schedules_data:
                seq_num = schedule["attributes"]["stop_sequence"]
                platform_id = schedule["relationships"]["stop"]["data"]["id"]

                # Create the flat edge object for SwiftData
                sequence_edge = {
                    "routeId": route_id,
                    "patternId": pattern_id,
                    "directionId": direction_id,
                    "sequenceNumber": seq_num,
                    "platformId": platform_id
                }
                final_sequences.append(sequence_edge)
                stops_added += 1
            
            print(f"     ✅ Extracted {stops_added} sequence edges.")

    # 5. Write everything to sequences.json
    output_filename = "sequences.json"
    with open(output_filename, "w") as outfile:
        json.dump(final_sequences, outfile, indent=4)

    print(f"\n🎉 Finished! Wrote {len(final_sequences)} total sequence edges to {output_filename}")

if __name__ == "__main__":
    build_sequences()