#!/usr/bin/env bash

#aws ec2 create-key-pair --key-name swan_key_pair --query 'KeyMaterial' --output text >> key.pem

aws ec2 run-instances \
    --image-id  ami-0d016af584f4febe3 \
    --instance-type t2.micro \
    --key-name swan_key_pair \
    --security-group-ids sg-0997b787af5506e68 \
    --subnet-id subnet-0a497d482f9e8dee7

#aws ec2 terminate-instances --instance-ids i-0fd9a19c1834b9bca
#

aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' \
    --output table

