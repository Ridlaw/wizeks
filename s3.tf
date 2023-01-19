resource "aws_s3_bucket" "wizmongos3" {

  bucket = "wizmongo12345"

}

resource "aws_s3_bucket_acl" "s3bucket_acl" {
  bucket = aws_s3_bucket.wizmongos3.id
  acl    = "public-read"
}

# resource "aws_s3_object" "mongobackup" {
#   bucket = "wizmongo12345"
#   key    = "mongobackup"
#   depends_on = [
#     aws_s3_bucket.wizmongos3,
#   ]
# }