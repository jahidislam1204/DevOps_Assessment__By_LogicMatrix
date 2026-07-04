# This file is intentionally reserved for backend usage notes.
#
# The default configuration uses local state so `terraform init` works for
# first-time setup and code validation.
#
# To use remote S3 state:
# 1. Create an S3 bucket for remote state storage.
# 2. Copy backend.s3.example.hcl to a local backend config file.
# 3. Replace the bucket value with the real bucket name.
# 4. Run: terraform init -backend-config=<your-backend-file>.hcl
