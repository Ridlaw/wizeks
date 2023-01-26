# Create an S3 bucket
resource "aws_s3_bucket" "wizmongos3" {
  bucket = "wizmongo12345"
}

# Create ACL for public read on bucket
resource "aws_s3_bucket_acl" "s3bucket_acl" {
  bucket = aws_s3_bucket.wizmongos3.id
  acl    = "public-read"
}
