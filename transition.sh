#!/bin/bash

echo "Script running..."
# List all the enabled AWS regions
regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)

# Loop through each region
for region in $regions; do

    # Find the number of instance(s) having IMDSv1
    length=$(aws ec2 describe-instances --region $region --filters "Name=metadata-options.http-tokens,Values=optional" --query 'length(Reservations[].Instances[].InstanceId)')

    if [ $length -gt 0 ];
    then
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "Region is : $region"
        echo " "
        
        # Get the list of instances having IMDSv1
        lists=$(aws ec2 describe-instances --region $region --query 'Reservations[*].Instances[?MetadataOptions.HttpTokens== `optional`].[InstanceId]' --output text)
        
        # Loop through each instance in the list
        for list in $lists; do
            echo "------------------------------------------"
            echo "Instance is : $list"
            echo " "

            # Enable IMDSv2
            imds=$(aws ec2 modify-instance-metadata-options --instance-id $list --http-tokens required --region $region --http-endpoint enabled)
            echo -e "IMDSv2 for Instance $list has been enabled in the region $region, snippet below -\n$imds"

            echo "------------------------------------------";
            echo " ";
        
        done
        
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
        echo " ";
    else
        continue
    fi

done

echo "Completed."