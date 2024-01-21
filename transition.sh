#!/bin/bash

# Function to loop through each region and convert IMDSv1 to IMDSv2.
loopregions(){
    length=$(aws ec2 describe-instances --region $1 --filters "Name=metadata-options.http-tokens,Values=optional" --query 'length(Reservations[].Instances[].InstanceId)')

    if [ $length -gt 0 ];
    then
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "Region is : $1"
        echo " "
        
        # IMDS optional instance list
        lists=$(aws ec2 describe-instances --region $1 --query 'Reservations[*].Instances[?MetadataOptions.HttpTokens== `optional`].[InstanceId]' --output text)
        
        # Loop through each instance in the list
        for list in $lists; do
            convertimds $1 $list
        done
        
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
        echo " ";
    else
        continue
    fi
}


# Function to covert IMDSv1 to IMDSv2
convertimds(){
    echo "------------------------------------------"
    echo "Instance is : $2"
    echo " "

    imds=$(aws ec2 modify-instance-metadata-options --instance-id $2 --http-tokens required --region $1 --http-endpoint enabled)
    echo -e "IMDSv2 for Instance $2 has been enabled in the region $1, snippet below -\n$imds"

    echo "------------------------------------------";
    echo " ";
}

# Main script starts here 

echo "Script running..."
# Set your AWS region
regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)

# Loop through each regions
for region in $regions; do
    loopregions $region
done

echo "Completed."