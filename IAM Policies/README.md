# IAM Policies

This folder contains IAM policy documents used by the automation assets in this repository.

## Files

### `lambda-policy-for-scheduling-ec2-instances.json`

Policy intended for Lambda functions that start and stop EC2 instances on a schedule.

- Allows `ec2:Start*`
- Allows `ec2:Stop*`
- Applies to all resources via `"Resource": "*"`

## Intended Use

Attach this policy to the IAM role assumed by the Lambda functions in [Lambda Functions/](/Users/enoyola/Documents/GitHub/AWS/Lambda%20Functions/README.md) when implementing scheduled EC2 operations.

## Security Note

The current policy is broad because it allows start and stop actions on all EC2 resources. For production use, consider scoping permissions more tightly with:

- specific instance ARNs when practical
- tag-based access controls
- separate roles for different environments or workloads
