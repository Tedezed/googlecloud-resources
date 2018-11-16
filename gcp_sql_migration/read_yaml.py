import yaml, sys

file_yaml = sys.argv[1]

stream = open(file_yaml, "r")
docs = yaml.load_all(stream)
for doc in docs:
    list_authorizedNetworks = ""
    for a in doc["settings"]["ipConfiguration"]["authorizedNetworks"]:
        list_authorizedNetworks += "%s," % a["value"]
    list_authorizedNetworks = list_authorizedNetworks[0:-1]
    #print doc["settings"]["maintenanceWindow"]["hour"]
    print "--storage-type %s\
    --pricing-plan %s\
    --replication %s\
    --tier %s\
    --maintenance-window-day SUN\
    --maintenance-window-hour %s\
    --backup\
    --backup-start-time 00:30\
    --storage-auto-increase\
    --storage-size %s\
    --authorized-networks %s" % (\
        doc["settings"]["dataDiskType"][+3:],\
        doc["settings"]["pricingPlan"],\
        doc["settings"]["replicationType"].lower(),\
        doc["settings"]["tier"],\
        doc["settings"]["maintenanceWindow"]["hour"],\
        doc["settings"]["dataDiskSizeGb"],\
        list_authorizedNetworks)

