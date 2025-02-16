"""
This script aims to change all the gp2 disks inside an account, into gp3 disks. 
If current IOPS are higher than the default GP3 disk IOPS, these will be retained. 

This script assumes that all the accounts that will be accessed have had their 
respective profiles created for the aws cli. 
"""
import boto3
import csv
import subprocess

#Import the names of the accounts from a CSV into awsProfiles variable in the format of a string. 
with open("Path to CSV of config profile names.", "r") as file:
    reader = csv.reader(file, delimiter= ',')
    awsProfiles= []
    for row in reader:
        awsProfiles.append(', '.join(row))

#For each profile in CSV
for profile in awsProfiles:
    print(profile)

    #Create a session with AWS using the profile name corresponding to the name in c:\users\%User%\.aws\Config
    session = boto3.Session(profile_name=profile)

    #ec2 resource object for getting volume info, I found it easier than using client below. 
    ec2 = session.resource('ec2')
    
    #ec2 client object for making changes to a volume
    ec2client = session.client('ec2')

    
    try:
        #Get a list of all volumes with sso session,
        volumes = ec2.volumes.all()

        #Checks if a volume list has been returned, if not, go to except. 
        for volume in volumes:
            print(volume.id)

    #If an error is received when trying to get a list, retry signing into AWS SSO and get the list.
    except:
        subprocess.run(['aws', 'sso', 'login', '--sso-session', 'my-sso'])
        volumes = ec2.volumes.all()

    #for each disk in array
    for volume in volumes:
        print(volume.id)

        #Get info on current volume for calculations
        response = ec2client.describe_volumes(VolumeIds=[volume.id])
        currentVolume = response['Volumes'][0]
        currentVolumeType = currentVolume['VolumeType']
        currentIOPS = currentVolume['Iops']

        #if disk is gp2, run this code block
        if currentVolumeType =='gp2':

            #if disk IOPS is higher than 6000 IOPS, run this code block
            if currentIOPS > 6000:

                #set disk to gp3 with current gp2 values
                ec2client.modify_volume(VolumeId=volume.id, VolumeType='gp3', Iops=[currentIOPS], Throughput=500)
                print("Keeping gp2 values, setting gp3")

            #else set disk to gp3 with 6000 IOPS and 500MB/s throughput
            else:
                try: 
                    #set disk to gp3 with 6000 IOPS and 500MiB/s throughput
                    ec2client.modify_volume(VolumeId=volume.id, VolumeType='gp3', Iops=6000, Throughput=500)
                    print("Setting gp3 with default values")

                except:
                    #set disk to gp3 with maximum gp3 values for a small disk
                    ec2client.modify_volume(VolumeId=volume.id, VolumeType='gp3')
                    print("Setting gp3 with aws set values (disk might be too small for default)")

        #Disk is not GP2, do nothing. 
        else:
            print("Volume is not GP2, doing nothing")