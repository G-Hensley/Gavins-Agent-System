# Cloud Security (AWS Focus)

## IAM — Least Privilege
- Every role/user gets minimum permissions needed — no wildcards (`*`) on actions or resources
- Use policy conditions to restrict by IP, time, MFA, or tag
- Review IAM Access Analyzer findings regularly
- Never use root account for operations — create IAM users/roles

## Secrets Management
- Store secrets in AWS Secrets Manager or SSM Parameter Store (SecureString)
- Never hardcode secrets in code, environment variables baked into images, or config files in repos
- Rotate secrets on a schedule — automate with Secrets Manager rotation
- Use IAM roles for service-to-service auth, not static credentials

## Lambda Security
- Set minimum IAM permissions per function — not shared roles across all Lambdas
- Set appropriate timeout and memory limits to prevent runaway costs
- Use environment variable encryption (KMS)
- Validate all event input — Lambda events are not trusted input

## S3 Bucket Security
- Block public access by default (account-level setting)
- Use bucket policies with explicit deny for sensitive buckets
- Enable server-side encryption (SSE-S3 or SSE-KMS)
- Enable access logging for audit trails
- Use presigned URLs for temporary access, not public ACLs

## VPC and Network
- Put databases and internal services in private subnets
- Use security groups as allowlists — deny by default
- Enable VPC Flow Logs for network monitoring
- Use VPC endpoints for AWS service access (avoid public internet)

## Cognito / Auth
- Enable MFA for user pools
- Use SRP protocol for password authentication (not plaintext)
- Set strong password policies
- Configure token expiration appropriately (short-lived access, longer refresh)
