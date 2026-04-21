# Add S3 Event-Driven Lambda

**Goal:** Process uploaded files via Lambda triggered by S3 PutObject.

## Task 1: Wire up infra

- Add S3 bucket `uploads-bucket` with event notification in `infra/lib/upload-stack.ts` (CDK)
- Add Lambda `processUploadFn` with S3 read permission
- Add VPC config so Lambda can reach internal database
- Update bucket policy to restrict uploads to authenticated users
