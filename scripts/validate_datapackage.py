from datapackage import Package
from datapackage import exceptions
import os
from datapackage import validate, exceptions


ROOT = '/home/pgi/dev/toflit18_data/scripts/'
SKIP_RESOURCES = []

p = Package(os.path.join(ROOT, 'datapackage.json'), ROOT)
if not p.valid:
    for error in p.errors:
        print(error)


try:
    valid = validate(p.descriptor)
    print("valid?: %s"%valid)
except exceptions.ValidationError as exception:
   for error in exception.errors:
       # handle individual error
       print(error)



for resource in p.resources:
    print(resource.name)
    if not resource.valid:
        for error in resource.errors:
            print(error)
    try:
        print("%s relations"%resource.name)
        errors = resource.read()
        resource.check_relations()
        # relations are kept in the resource object => memory leak
        resource.drop_relations()
    except exceptions.DataPackageException as exception:
        if exception.multiple:
            for error in exception.errors:
                print(error)
        else:
            print(exception)
