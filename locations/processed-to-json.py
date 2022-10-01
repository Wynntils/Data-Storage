import json

file_location = "./out/services.csv"

service_map = {}

file = open(file_location, "r")

lines = file.readlines()
file.close()

# pop first line
lines.reverse()
lines.pop()
lines.reverse()

for line in lines:
    # remove new line
    line = line[:-1]

    parts = line.split(",")
    location = {'x': int(parts[1]), 'y': int(parts[2]), 'z': int(parts[3])}
    if location['x'] > 2000 or location["x"] < -2500 or location["z"] < -200 or location["z"] > 7000:
        # exclude as it is not part of main map area
        continue
    if parts[0] not in service_map:
        service_map[parts[0]] = [location]
    else:
        service_map[parts[0]].append(location)


json_map = []

for service in service_map:
    json_map.append({"type":service, "locations": service_map[service]})


json_string = json.dumps(json_map, indent=2)

out_file = open("parsed-json-services.json", "w")

out_file.write(json_string)
