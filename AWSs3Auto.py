#!/usr/bin/env python3
#Usage: AWSs3Auto.py <BucketName>
import boto3
from botocore.exceptions import ClientError
from sys import argv
#########################################################################
def AwsLogin(Profile='default',Region='eu-central-1'):
    try:
        AWSLogin = boto3.Session(profile_name=Profile, region_name=Region)
        return AWSLogin
    except:
        return False
#########################################################################
def CreateBucket(Name,AWSLogin,Region='eu-central-1'):
    try:
        s3Obj = AWSLogin.client('s3')
        s3Obj.create_bucket(Bucket=Name,CreateBucketConfiguration={'LocationConstraint': Region})
    except ClientError as e:
          return False
    return True
#########################################################################
def CheckBucket(Name,AWSLogin,Region='eu-central-1'):
    X = False
    s3Obj = AWSLogin.client('s3',region_name=Region)
    Response = s3Obj.list_buckets()['Buckets']
    for Items in Response:
        if Name == Items['Name']:
            X = True
    return X
#########################################################################
def Upload2s3(AWSLogin,Filepath,BucketName,Region='eu-central-1'):
    s3Obj = AWSLogin.client('s3',region_name=Region)
    try:
        X = s3Obj.upload_file(Filepath,BucketName,'RedTeam.html')
        return True
    except:
        print('Error | Upload Failed | Bucket {} / File path: {}'.format(BucketName,Filepath))
        return False
#########################################################################
def StaticWebOnS3(AWSLogin,BucketName,Region='eu-central-1',FileName='RedTeam.html'):
    WebsiteConfiguration = {'IndexDocument': {'Suffix': FileName},}
    try:
        s3Obj = AWSLogin.client('s3',region_name=Region)
        s3Obj.put_bucket_website(Bucket=BucketName,WebsiteConfiguration=WebsiteConfiguration)
        s3Obj.put_object_acl(ACL="public-read", Bucket=BucketName,Key=FileName)
        return True
    except:
        print('Error | Static Content creation failed')
#########################################################################
if __name__ == "__main__":
    AWSObj = AwsLogin()
    if AWSObj == False:
        print('Error | Login Failed')
    BucketName = argv[1].lower()
    cr = CreateBucket(BucketName,AWSObj)
    ch = CheckBucket(BucketName,AWSObj)
    if cr and ch:
        print("S3 Bocket:{} created successfully".format(BucketName))
        UploadState = Upload2s3(AWSObj, 'RedTeam.html',BucketName)
        if UploadState:
            print("File uploaded successfully | Bucket: {} / File: RedTeam.html".format(BucketName))
            if StaticWebOnS3(AWSObj,BucketName):
                print('Static content created successfully')
    else:
        print("Error | S3 Bucket creation failed! Name: {}".format(BucketName))
# RedTeam.html