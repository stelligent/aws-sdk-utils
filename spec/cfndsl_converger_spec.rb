require 'spec_helper'
require 'cfndsl_converger'

describe CfndslConverger do
  
  describe '#chain_converge' do
    before(:all) do
      @converger = CfndslConverger.new
    end

    it 'converges the two stacks, wiring output to input' do
      output_binding = @converger.chain_converge(cfndsl_stacks: [
                                                   {
                                                     stack_name: 'first',
                                                     path_to_stack: 'spec/cfndsl_test_templates/first_in_chain_cfndsl.rb'
                                                   },
                                                   {
                                                     stack_name: 'second',
                                                     path_to_stack: 'spec/cfndsl_test_templates/second_in_chain_cfndsl.rb'
                                                   }
                                                 ],
                                                 input_bindings: { 'fred' => 'wilma'})
      expect(output_binding['bucket']).to match /vanilla\d+/
      expect(output_binding['fred2']).to eq 'wilma'
    end

    after(:all) do
      @converger.cleanup 'second'
      @converger.cleanup 'first'
    end
  end

  describe 'converge' do
    before(:all) do
      @converger = CfndslConverger.new
      @stack_name = stack(stack_name: 'testingchangsets',
                          path_to_stack: 'spec/cfndsl_test_templates/simple_bucket_cfndsl.rb')
    end

    context 'converging immutable resource' do
      it 'raises an error' do
        expect {
          @converger.converge(stack_name: @stack_name,
                              path_to_stack: 'spec/cfndsl_test_templates/mutating_bucket_cfndsl.rb',
                              fail_on_changes_to_immutable_resource: true)
        }.to raise_error 'update would modify or delete immutable resource vanilla'
      end
    end

    after(:all) do
      cleanup @stack_name
    end
  end
end
