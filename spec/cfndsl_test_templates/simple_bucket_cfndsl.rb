CloudFormation {

  S3_Bucket('vanilla') {
    BucketName 'vanillachocstrawberry'

    Tags [
      { Key: 'immutable', Value: 'true'}
    ]
  }
}