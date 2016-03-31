require 'spec_helper'
require 'changeset_util'
require 'cfndsl'

describe ChangesetUtil do

  describe '#immutable_resources_that_would_change', :immutable do
    before(:each) do
      @changeset_util = ChangesetUtil.new
    end

    context 'bucket name change of immutable bucket' do

      it 'return logical resource id of bucket' do
        mock_change = double('change')
        mock_resource_change = double('resource_change')
        expect(mock_change).to receive(:resource_change)
                           .and_return(mock_resource_change)
        expect(mock_resource_change).to receive(:logical_resource_id)
                                    .and_return('vanilla')
        expect(@changeset_util).to receive(:changes_that_modify_or_remove)
                               .with(any_args)
                               .and_return([mock_change])


        template_body = <<-END
         {"AWSTemplateFormatVersion":"2010-09-09","Resources":{"vanilla":{"Properties":{"BucketName":"vanillachocstrawberry","Tags":[{"Key":"immutable","Value":"true"}]},"Type":"AWS::S3::Bucket"}}}
        END

        actual_logical_resource_ids = @changeset_util.immutable_resources_that_would_change(stack_name: 'fakestack',
                                                                                            template_body: template_body)

        expect(actual_logical_resource_ids).to eq 'vanilla'
      end
    end
  end

  describe '#changes_that_modify_or_remove' do
    before(:each) do
      @changeset_util = ChangesetUtil.new

      @stack_name = stack(stack_name: 'testingchangsets',
                          path_to_stack: 'spec/cfndsl_test_templates/simple_bucket_cfndsl.rb')
    end

    context 'no such changes' do
      it 'returns empty array' do

        verbose = false
        extras = []
        model = CfnDsl::eval_file_with_extras(File.expand_path('spec/cfndsl_test_templates/simple_bucket_cfndsl.rb'),
                                              extras,
                                              verbose)

        actual_changes_that_modify_or_remove = @changeset_util.changes_that_modify_or_remove(stack_name: @stack_name,
                                                                                             template_body: model.to_json)

        expect(actual_changes_that_modify_or_remove).to eq []
      end
    end

    context 'bucket name change' do
      it 'returns array with change for the bucket' do

        verbose = false
        extras = []
        model = CfnDsl::eval_file_with_extras(File.expand_path('spec/cfndsl_test_templates/mutating_bucket_cfndsl.rb'),
                                              extras,
                                              verbose)

        actual_changes_that_modify_or_remove = @changeset_util.changes_that_modify_or_remove(stack_name: @stack_name,
                                                                                             template_body: model.to_json)


        expect(actual_changes_that_modify_or_remove.size).to eq 1

        actual_change = actual_changes_that_modify_or_remove.first.to_h
        expect(actual_change[:resource_change][:logical_resource_id]).to eq 'vanilla'
        expect(actual_change[:resource_change][:action]).to eq 'Modify'
      end
    end

    after(:each) do
      cleanup(@stack_name)
    end
  end
end
