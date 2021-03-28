#!/usr/bin/env bash
source settings.default
source settings.private
echo "Using Project ID ${PROJECT_ID} to create VMs in zone ${DEFAULT_ZONE}"
echo "waiting for confirmation. <enter> to continue, ^C to abort"
read

machine_image=$(gcloud compute images list --project cos-cloud --no-standard-images|grep cos-stable|cut -d " " -f1)

gcloud compute instances create validator-02 \
 --image=ubuntu-minimal-2004-focal-v20210325 --image-project=ubuntu-os-cloud \
    --zone ${DEFAULT_ZONE} \
    --machine-type ${VALIDATOR_MACHINE_TYPE} \
    --tags=validator &
    #--boot-disk-size=200G &

# TODO determine if this really needs an external IP
#      --no-address \
#
gcloud compute instances create feeder-01 \
    --zone ${DEFAULT_ZONE} \
    --image=ubuntu-minimal-2004-focal-v20210325 --image-project=ubuntu-os-cloud \

    --tags=oracle \
    --machine-type ${MACHINE_TYPE} &

# TODO determine if this really needs an external IP
gcloud compute instances create price-server-01 \
  --image=ubuntu-minimal-2004-focal-v20210325 --image-project=ubuntu-os-cloud \
    --zone ${DEFAULT_ZONE} \
    --tags=priceserver \
    --machine-type ${MACHINE_TYPE} &

gcloud compute disks create validator-02-disk \
  --size ${VALIDATOR_DISK_SIZE} \
  --type ${VALIDATOR_DISK_TYPE} &
  
wait

gcloud compute instances attach-disk validator-02 \
  --disk validator-02-disk
