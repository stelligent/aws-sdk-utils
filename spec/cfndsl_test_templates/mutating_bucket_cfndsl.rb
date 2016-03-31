CloudFormation {

  S3_Bucket('vanilla') {
    BucketName 'rockyroad'

    Tags [
      { Key: 'immutable', Value: 'true'}
    ]
  }
}