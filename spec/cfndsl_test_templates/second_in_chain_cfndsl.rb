CloudFormation {

  S3_BucketPolicy('vanilla') {
    Bucket bucket
    PolicyDocument(
      {
        'Version' => '2012-10-17',
        'Id' => 'S3PolicyId1',
        'Statement' => [
          {
            'Sid' => 'IPAllow',
            'Effect' => 'Allow',
            'Principal' => '*',
            'Action' => 's3:*',
            'Resource' => "arn:aws:s3:::#{bucket}/*",
            'Condition' => {
              'IpAddress' => {'aws:SourceIp': '127.0.0.1/32'}
            }
          }
        ]
      }
    )
  }

  Output(:bucket,
         bucket)

  Output(:fred2,
         fred)
}