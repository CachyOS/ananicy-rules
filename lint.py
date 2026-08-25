import fileinput
import json
from pathlib import Path
import fastjsonschema

def iterate_files(files, validator):
    with fileinput.input(files=files, encoding="utf-8") as f:
        for ln, line in enumerate(f):
            result = validate_line(line, validator)
            if result is not True:
                print("Error in file {filename} on line {ln}"
                    .format(ln=ln, filename=f.filename()))
                print("Line: %s" % line)
                print("Error: %s" % result)


def validate_line(line, validator):
    if line.startswith('#') or line.strip() == "":
        return True
    try:
        record = json.loads(line)
        validator(record)
    except json.JSONDecodeError as e:
        return f'Invalid JSON: {e.msg}'
    except fastjsonschema.JsonSchemaException as e:
        return e.message
    return True

with open('ananicy-cgroups.schema.json', 'r') as cgroups_schema_file:
    cgroups_schema = json.load(cgroups_schema_file)
    cgroups_validator = fastjsonschema.compile(cgroups_schema)
    exts = [".cgroups"]
    files = list([p for p in Path('.').rglob('*') if p.suffix in exts])
    iterate_files(files, cgroups_validator)

with open('ananicy.schema.json', 'r') as rule_schema_file:
    rule_schema = json.load(rule_schema_file)
    rule_validator = fastjsonschema.compile(rule_schema)
    exts = [".rules", ".types"]
    files = list([p for p in Path('.').rglob('*') if p.suffix in exts])
    iterate_files(files, rule_validator)

