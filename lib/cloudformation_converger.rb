require 'aws-sdk'
require 'yaml'

class CloudFormationConverger

  def converge(stack_name:,
               stack_path:,
               bindings: nil,
               strip_extras: false)

    cloudformation_client = Aws::CloudFormation::Client.new

    validate_template_response = cloudformation_client.validate_template(template_body: IO.read(stack_path))
    legal_parameters = validate_template_response.parameters.map { | parameter| parameter.parameter_key }

    parameters = []
    unless bindings.nil?
      parameters = convert_hash_to_parameters bindings, legal_parameters, strip_extras
    end

    resource = Aws::CloudFormation::Resource.new(client: cloudformation_client)
    if resource.stacks.find {|stack| stack.name == stack_name }
      stack = resource.stack(stack_name)
      begin
        stack.update(template_body: IO.read(stack_path),
                     capabilities: %w(CAPABILITY_IAM),
                     parameters: parameters)
      rescue Exception => error
        if error.to_s =~ /No updates are to be performed/
          STDERR.puts 'no updates necessary'
        else
          raise error
        end
      end

    else
      stack = resource.create_stack(stack_name: stack_name,
                                    template_body: IO.read(stack_path),
                                    capabilities: %w(CAPABILITY_IAM),
                                    parameters: parameters)
    end

    stack.wait_until(max_attempts:100, delay:15) do |stack|
      stack.stack_status =~ /COMPLETE/ or stack.stack_status =~ /FAILED/
    end

    if stack.stack_status =~ /FAILED/ or stack.stack_status =~ /ROLLBACK_COMPLETE/
      raise "#{stack_name} failed to converge: #{stack.stack_status}"
    end

    stack.outputs.inject({}) do |hash, output|
      hash[output.output_key] = output.output_value
      hash
    end
  end

  private

  def convert_hash_to_parameters(hash,
                                 legal_parameters,
                                 strip_extras)
    parameters = []
    hash.each do |k,v|
      if strip_extras
        if legal_parameters.include? k
          parameters << {
            parameter_key: k,
            parameter_value: v.to_s,
            use_previous_value: false
          }
        end
      else
        parameters << {
          parameter_key: k,
          parameter_value: v.to_s,
          use_previous_value: false
        }
      end
    end
    parameters
  end
end