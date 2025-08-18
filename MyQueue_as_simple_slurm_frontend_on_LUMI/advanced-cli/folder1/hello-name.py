from json import load

with open('cfg.json', 'r') as fd:
    dct = load(fd)

print(f"Hello {dct['name']}")
