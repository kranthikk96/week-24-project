resource "aws_cloudformation_stack" "network" {
  name = "networking-stack"

 parameters = {
    VPCCidr = "10.0.0.0/16"
  }
 Parameters = {
  KeyName :
    Description : Name of an existing EC2 KeyPair to enable SSH access to the instance
    Type: AWS::EC2::KeyPair::KeyName
    ConstraintDescription: must be the name of an existing EC2 KeyPair.
  InstanceType:
    Description: WebServer EC2 instance type
    Type: String
    Default: t2.micro
    AllowedValues : [t2.nano, t2.micro, t2.small, t2.medium, t2.large, t2.xlarge, t2.2xlarge,
      t3.nano, t3.micro, t3.small, t3.medium, t3.large, t3.xlarge, t3.2xlarge,
      m4.large, m4.xlarge, m4.2xlarge, m4.4xlarge, m4.10xlarge,
      m5.large, m5.xlarge, m5.2xlarge, m5.4xlarge,
      c5.large, c5.xlarge, c5.2xlarge, c5.4xlarge, c5.9xlarge,
      g3.8xlarge,
      r5.large, r5.xlarge, r5.2xlarge, r5.4xlarge, r3.12xlarge,
      i3.xlarge, i3.2xlarge, i3.4xlarge, i3.8xlarge,
      d2.xlarge, d2.2xlarge, d2.4xlarge, d2.8xlarge]
    ConstraintDescription: must be a valid EC2 instance type.
   }

  template_body = <<STACK
{
  "Parameters" : {
    "VPCCidr" : {
      "Type" : "String",
      "Default" : "10.0.0.0/16",
      "Description" : "Enter the CIDR block for the VPC. Default is 10.0.0.0/16."
    }
  },
  "Resources" : {
    "myVpc": {
      "Type" : "AWS::EC2::VPC",
      "Properties" : {
        "CidrBlock" : { "Ref" : "VPCCidr" },
        "Tags" : [
          { "Key" : "Name", "Value" : "Primary_CF_VPC" }
        ]
    }
  }
}
STACK
}
 Resources:
  EC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref 'InstanceType'
      SecurityGroups: [!Ref 'InstanceSecurityGroup']
      KeyName: !Ref 'KeyName'
      ImageId: !Ref 'LatestAmiId'
  InstanceSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Enable SSH access via port 22
      SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 22
        ToPort: 22
        CidrIp: !Ref 'SSHLocation'
Outputs:
  InstanceId:
    Description: InstanceId of the newly created EC2 instance
    Value: !Ref 'EC2Instance'
  AZ:
    Description: Availability Zone of the newly created EC2 instance
    Value: !GetAtt [EC2Instance, AvailabilityZone]
  PublicDNS:
    Description: Public DNSName of the newly created EC2 instance
    Value: !GetAtt [EC2Instance, PublicDnsName]
  PublicIP:
    Description: Public IP address of the newly created EC2 instance
    Value: !GetAtt [EC2Instance, PublicIp] 
       
      }
