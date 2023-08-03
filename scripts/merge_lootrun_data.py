import json

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

# Read the lootrun data from the file
data = {}

with open('lootruns/raw.json', 'r') as f:
    data = json.load(f)

# De-duplicate data
deduped = dedupe(data)

# Remap the data
output_data = {}

for location in deduped:
    output_data[location] = []

    for entry in sorted(deduped[location].keys(), key=lambda x: (x.x, x.y, x.z)):
        output_data[location].append(deduped[location][entry])

# Write the data to the file
with open('lootruns/out.json', 'w') as f:
    json.dump(output_data, f, indent=2, sort_keys=True)
    f.write('\n')
    