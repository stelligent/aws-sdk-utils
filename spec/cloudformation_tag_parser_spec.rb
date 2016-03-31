require 'spec_helper'
require 'cloudformation_tag_parser'

describe CloudFormationTagParser do

  before(:each) do
    @cloudformation_tag_parser = CloudFormationTagParser.new
  end

  describe 'tags' do
    context 'resource not found' do
      it 'raises an error' do
        element_with_no_tags_cfn_json = <<-END
        {
          "Resources" : {
            "someInstance" : {
              "Type" : "AWS::EC2::Instance",
              "Properties" : {
                "ImageId" : "ami-0fb83963",
                "SubnetId" : {
                  "Ref" : "privateSubnet1"
                },
                "InstanceType" : "t2.micro"
              }
            }
          }
        }
        END
        expect {
          @cloudformation_tag_parser.tags(cloudformation_json: element_with_no_tags_cfn_json,
                                          logical_resource_id: 'somethingNotFound')
        }.to raise_error 'logical resource id somethingNotFound is not found'
      end
    end

    context 'resource has no tags' do
      it 'returns an empty array' do
        element_with_no_tags_cfn_json = <<-END
        {
          "Resources" : {
            "someInstance" : {
              "Type" : "AWS::EC2::Instance",
              "Properties" : {
                "ImageId" : "ami-0fb83963",
                "SubnetId" : {
                  "Ref" : "privateSubnet1"
                },
                "InstanceType" : "t2.micro"
              }
            }
          }
        }
        END
        actual_tags = @cloudformation_tag_parser.tags(cloudformation_json: element_with_no_tags_cfn_json,
                                                      logical_resource_id: 'someInstance')
        expect(actual_tags).to eq []
      end
    end

    context 'resource has tags' do

      it 'returns an array of Hash with key/value' do
        element_with_tags_cfn_json = <<-END
        {
          "Resources" : {
            "someInstance" : {
              "Type" : "AWS::EC2::Instance",
              "Properties" : {
                "ImageId" : "ami-0fb83963",
                "SubnetId" : {
                  "Ref" : "privateSubnet1"
                },
                "InstanceType" : "t2.micro",
                "Tags" : [
                  {
                    "Key" : "Name",
                    "Value" : "WhoKnew"
                  },
                  {
                    "Key" : "Sign",
                    "Value" : "EndofTimes"
                  }
                ]
              }
            }
          }
        }
        END
        actual_tags = @cloudformation_tag_parser.tags(cloudformation_json: element_with_tags_cfn_json,
                                                      logical_resource_id: 'someInstance')
        expect(actual_tags).to eq [
                                    {
                                      'Key' => 'Name',
                                      'Value' => 'WhoKnew'
                                    },
                                    {
                                      'Key' => 'Sign',
                                      'Value' => 'EndofTimes'
                                    }
                                  ]
      end
    end
  end
end
