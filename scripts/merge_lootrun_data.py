import json
import os

# Data has two objects:
# "silentExpanse"
# "corkus"

# Data:
'''
{
  "silentExpanse": [
    {
      "location": {
        "x": 602,
        "y": 0,
        "z": -407
      },
      "taskType": "slay"
    },
    ...
    ]
}
'''

version = "version204Release2"

# x, y, z
class Location: 
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z
    
    # This is used to compare two locations
    def __eq__(self, other):
        return self.x == other.x and self.y == other.y and self.z == other.z
    
    def __hash__(self):
        return hash((self.x, self.y, self.z))

# Dedupe the data
# The data has a lot of duplicate entries, so we need to remove them
def dedupe(data):
    deduped = {}

    for location in data:
        deduped[location] = {}

        for entry in data[location]:
            current_location = Location(entry['location']['x'], entry['location']['y'], entry['location']['z'])

            current_location_offset_px = Location(entry['location']['x'] + 1, entry['location']['y'], entry['location']['z'])
            current_location_offset_nx = Location(entry['location']['x'] - 1, entry['location']['y'], entry['location']['z'])
            current_location_offset_pz = Location(entry['location']['x'], entry['location']['y'], entry['location']['z'] + 1)
            current_location_offset_nz = Location(entry['location']['x'], entry['location']['y'], entry['location']['z'] - 1)

            if current_location not in deduped[location] and current_location_offset_px not in deduped[location] and current_location_offset_nx not in deduped[location] and current_location_offset_pz not in deduped[location] and current_location_offset_nz not in deduped[location]:
                deduped[location][current_location] = entry

    return deduped

# Read the lootrun data from all files in the lootruns/raw directory
data = {}

folder = os.getcwd() + "/lootruns/raw"
for filename in os.listdir(folder):
   with open(os.path.join(folder, filename), 'r') as f: 
       file_data = json.load(f)
       for task in file_data[version]:
            if task["region"] not in data:
                data[task["region"]] = []
            data[task["region"]].append(task)

# De-duplicate data
deduped = dedupe(data)

remapped = {}

# Remap the data
# Remove "region" field
# Move "lootrunTaskType" to "taskType"
# Add empty "name" field
for location in deduped:
    remapped[location] = {}

    for entry in deduped[location]:
        remapped[location][entry] = {
            "location": {
                "x": entry.x,
                "y": entry.y,
                "z": entry.z
            },
            "taskType": deduped[location][entry]["lootrunTaskType"],
            "name": ""
        }

# Sort the data
output_data = {}

for location in remapped:
    output_data[location] = []

    for entry in sorted(remapped[location].keys(), key=lambda x: (x.x, x.y, x.z)):
        output_data[location].append(remapped[location][entry])

# Write the data to the file
with open('lootruns/out.json', 'w') as f:
    json.dump(output_data, f, indent=2, sort_keys=True)
    f.write('\n')
