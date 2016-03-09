CloudFormation {
  Lambda_Function('rBasicLambdaFunction') {
    Handler 'myHandler'
    Role FnGetAtt('lambdaExecutionRole', 'Arn')
    Runtime 'nodejs'
    Timeout 240
    MemorySize 128
    Code {
      ZipFile FnJoin('', [
        'exports.myHandler = function(event, context) {',
        'console.log("value1 = " + event.key1);',
        'console.log("value2 = " + event.key2);',
        'context.succeed("some message");'
      ])
    }
  }

  IAM_Role('lambdaExecutionRole') {
    AssumeRolePolicyDocument(JSON.load <<-END
      {
        "Statement":[
          {
            "Action":[
              "sts:AssumeRole"
            ],
            "Effect":"Allow",
            "Principal":{
              "Service":[
                "lambda.amazonaws.com"
              ]
            }
          }
        ],
        "Version":"2012-10-17"
      }
    END
    )

    Policies([
      {
         'PolicyName' => 'ReceiveMessagesAndUpdateSecGroups',
         'PolicyDocument' => (JSON.load <<-END
          {
            "Statement":[
              {
                "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
                ],
                "Effect": "Allow",
                "Resource": "arn:aws:logs:*:*:*"
              }
            ],
            "Version":"2012-10-17"
          }
          END
         )
      }
   ])
  }

  Output(:arn,
         FnGetAtt('rBasicLambdaFunction', 'Arn'))

  Output(:functionname,
         Ref('rBasicLambdaFunction'))
}