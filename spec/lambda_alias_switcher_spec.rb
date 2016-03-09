require 'spec_helper'
require 'lambda_alias_switcher'

describe LambdaAliasSwitcher do
  before(:all) do
    @blue_green_lambda = LambdaAliasSwitcher.new
    @aws_account_number = ENV['AWS_ACCOUNT_NUMBER']
    @aws_region = ENV['AWS_REGION']
  end

  context 'no alias yet exists for lambda function' do
    before(:all) do
      @stack_name = stack(stack_name: 'basiclambdafortesting',
                          path_to_stack: 'spec/cfndsl_test_templates/basic_lambda_cfndsl.rb')
    end


    it 'creates a new alias and assigns it to LATEST of lambda function' do

      alias_arn = @blue_green_lambda.switch_alias(function_name: stack_outputs['functionname'],
                                                  alias_arg: 'PROD',
                                                  function_version: '$LATEST')

      expect(alias_arn).to eq "arn:aws:lambda:#{@aws_region}:#{@aws_account_number}:function:#{stack_outputs['functionname']}:PROD"

      get_alias_response = Aws::Lambda::Client.new.get_alias function_name: stack_outputs['functionname'],
                                                             name: 'PROD'

      expect(get_alias_response[:name]).to eq 'PROD'
      expect(get_alias_response[:alias_arn]).to eq alias_arn
    end

    after(:all) do
      cleanup(@stack_name)
    end
  end

  context 'alias  PROD exists for lambda function' do
    before(:all) do
      @stack_name = stack(stack_name: 'basiclambdafortesting',
                          path_to_stack: 'spec/cfndsl_test_templates/basic_lambda_cfndsl.rb')
    end


    it 'updates the alias' do
      alias_arn = @blue_green_lambda.switch_alias(function_name: stack_outputs['functionname'],
                                                  alias_arg: 'PROD',
                                                  function_version: '$LATEST')

      alias_arn = @blue_green_lambda.switch_alias(function_name: stack_outputs['functionname'],
                                                  alias_arg: 'PROD',
                                                  function_version: '$LATEST')

      list_aliases_response = Aws::Lambda::Client.new.list_aliases function_name: stack_outputs['functionname']

      puts list_aliases_response
      expect(list_aliases_response.aliases.size).to eq 1
    end

    after(:all) do
      cleanup(@stack_name)
    end
  end
end