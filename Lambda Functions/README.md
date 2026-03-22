# Lambda Functions

This folder contains AWS Lambda scripts used for lightweight operational automation.

## Files

### `start-ec2-instances.py`

Starts a fixed list of EC2 instances in the configured AWS region.

- Uses `boto3` to call `ec2.start_instances`.
- Currently targets the `us-east-1` region.
- Expects the `instances` list in the script to be replaced with real EC2 instance IDs.

### `stop-ec2-instances.py`

Stops a fixed list of EC2 instances in the configured AWS region.

- Uses `boto3` to call `ec2.stop_instances`.
- Currently targets the `us-east-1` region.
- Expects the `instances` list in the script to be replaced with real EC2 instance IDs.

## Typical Usage

These functions are intended for scheduled EC2 lifecycle automation, for example:

- Start non-production instances at the beginning of the workday.
- Stop non-production instances after hours to reduce cost.

They are commonly paired with:

- an EventBridge schedule that invokes each Lambda on a defined timetable
- an IAM role that allows the Lambda function to start and stop EC2 instances
- the policy stored in [IAM Policies/lambda-policy-for-scheduling-ec2-instances.json](/Users/enoyola/Documents/GitHub/AWS/IAM%20Policies/lambda-policy-for-scheduling-ec2-instances.json)

## Before Deployment

- Replace placeholder instance IDs with real values.
- Confirm the AWS region is correct for the target instances.
- Attach an execution role with the required EC2 permissions.
- Package and deploy the function with `boto3` available in the Lambda runtime.

## Operational Note

The current implementation uses hard-coded configuration. If these functions are expanded, environment variables are usually a better choice for region, target instance IDs, and scheduling-related behavior.
