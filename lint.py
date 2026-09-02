import fileinput
import json
from pathlib import Path
import fastjsonschema
import sys

types = set()
names = dict()
errors = list()

def iterate_files(files, validator):
    with fileinput.input(files=files, encoding="utf-8") as f:
        for ln, line in enumerate(f):
            try:
                validate_line(line, validator, f.filename())
            except ValueError as e:
                errors.append({
                    'filename': f.filename(),
                    'ln': ln,
                    'line': line.rstrip(),
                    'message': e
                })

def validate_line(line, validator, filename):
    if line.startswith('#') or line.strip() == "":
        return True
    try:
        record = json.loads(line)
        validator(record)
        if filename.suffix == '.types':
            types.add(record['type'])
        elif filename.suffix == '.rules':
            if 'type' in record and record['type'] not in types:
                raise ValueError(f'Invalid type: {record['type']}')
            if 'name' in record and record['name'] in names:
                raise ValueError(f'Duplicate name: {record['name']}, present also in {names[record['name']]}')
            names[record['name']] = filename
    except json.JSONDecodeError as e:
        raise ValueError(f'Invalid JSON: {e.msg}')
    except fastjsonschema.JsonSchemaException as e:
        raise ValueError(e.message)
    return True

def validate_with_schema(schema_file, glob):
    with Path(schema_file).resolve().open('r', encoding="utf-8") as f:
        schema = json.load(f)
        if glob == "*.rules":
            schema['required'] = ["name"]
            schema["properties"]["name"] = {
                "type": "string",
                "description": "Name of the process"
            }
        validator = fastjsonschema.compile(schema)
        files = list(Path('.').rglob(glob))
        iterate_files(files, validator)

validate_with_schema('ananicy-cgroups.schema.json', '*.cgroups')
validate_with_schema('ananicy.schema.json', '*.types')
validate_with_schema('ananicy.schema.json', '*.rules')

if len(errors) > 0:
    for error in errors:
        print(f"""Error in file {error['filename']} on line {error['ln']}
Line: {error['line']}
{error['message']}
""")
    sys.exit(1)