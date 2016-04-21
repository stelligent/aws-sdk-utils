require 'spec_helper'


describe 'cfn_converge' do

  context 'vanilla json with one parameter' do

    it 'maps in parameter and converges stack' do
      result = system 'bin/cfn_converge --path-to-stack spec/cfn_test_templates/simple.json '\
                                       '--stack-name foo '\
                                       '--path-to-yaml spec/cfn_test_templates/simple-parameters.yml'

      expect(result).to eq true
    end
  end
end