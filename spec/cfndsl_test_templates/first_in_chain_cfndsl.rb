CloudFormation {

  S3_Bucket('vanilla') {
    BucketName "vanilla#{Time.now.to_i}"
  }

  Output(:bucket,
         Ref('vanilla'))

  Output(:fred,
         fred)
}