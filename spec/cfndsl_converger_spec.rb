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
end
