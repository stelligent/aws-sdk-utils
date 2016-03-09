require 'aws-sdk'

class CloudFormationConverger

  def converge(stack_name:,
               stack_path:,
               parameters:nil)

    cloudformation_client = Aws::CloudFormation::Client.new
    resource = Aws::CloudFormation::Resource.new(client: cloudformation_client)
    if resource.stacks.find {|stack| stack.name == stack_name }
      stack = resource.stack(stack_name)
      begin
        stack.update(template_body: IO.read(stack_path),
                     capabilities: %w(CAPABILITY_IAM))
      rescue Exception => error
        if error.to_s =~ /No updates are to be performed/
          puts 'no updates necessary'
        else
          raise error
        end
      end

    else
      stack = resource.create_stack(stack_name: stack_name,
                                    template_body: IO.read(stack_path),
                                    capabilities: %w(CAPABILITY_IAM))
    end

    stack.wait_until(max_attempts:100, delay:15) do |stack|
      stack.stack_status =~ /COMPLETE/ or stack.stack_status =~ /FAILED/
    end

    if stack.stack_status =~ /FAILED/
      raise "#{stack_name} failed to converge: #{stack.stack_status}"
    end

    stack.outputs.inject({}) do |hash, output|
      hash[output.output_key] = output.output_value
      hash
    end
  end
end