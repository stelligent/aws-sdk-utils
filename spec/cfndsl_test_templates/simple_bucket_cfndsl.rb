CloudFormation {

  S3_Bucket('vanilla') {
    BucketName 'vanillachocstrawberry123456789877'

    Tags [
      { Key: 'immutable', Value: 'true'}
    ]
  }
}