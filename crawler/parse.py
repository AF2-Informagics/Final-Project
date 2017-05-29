import json


with open("building.json") as json_data:
    d = json.load(json_data)
    print(json.dumps(d, indent=4))
    parsed = json.loads(d)
    print(json.dumps(parsed, indent=4, sort_keys=True))
