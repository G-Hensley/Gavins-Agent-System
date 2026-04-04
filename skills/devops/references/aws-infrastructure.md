# AWS Infrastructure

## Lambda
- One function per responsibility (not monolithic handlers)
- Set memory based on workload (more memory = more CPU)
- Set timeout appropriately (not max 15 min for a 5-second function)
- Use layers for shared dependencies
- Environment variables for config, Secrets Manager for secrets

## DynamoDB
- Design for access patterns first (single-table design)
- Use on-demand billing for unpredictable workloads, provisioned for steady
- Enable point-in-time recovery for production tables
- Use DAX for read-heavy caching needs

## S3
- Block public access by default (account-level)
- Enable versioning for important buckets
- Lifecycle policies for cost management (transition to Glacier, expire old versions)
- Server-side encryption (SSE-S3 or SSE-KMS)

## IAM
- Least privilege: specific actions on specific resources
- Use roles (not users) for services
- Use policy conditions where possible (IP, MFA, tags)
- Review with IAM Access Analyzer

## EventBridge
- Use for decoupled event-driven architecture
- Define event schemas for type safety
- Use DLQ for failed event processing
- Pattern matching rules for routing

## CDK Patterns
```typescript
const api = new apigw.RestApi(this, 'Api');
const handler = new lambda.Function(this, 'Handler', {
  runtime: lambda.Runtime.PYTHON_3_11,
  handler: 'src.handler.main',
  timeout: Duration.seconds(30),
  memorySize: 256,
});
api.root.addResource('users').addMethod('GET', new apigw.LambdaIntegration(handler));
```
