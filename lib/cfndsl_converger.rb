require 'aws-sdk'
require 'cfndsl'
require 'tempfile'
require 'changeset_util'

class CfndslConverger

  def chain_converge(cfndsl_stacks:,
                     input_bindings: nil)

    previous_output_bindings = input_bindings
    cfndsl_stacks.each do |cfndsl_stack|
      previous_output_bindings = converge stack_name: cfndsl_stack[:stack_name],
                                          path_to_stack: cfndsl_stack[:path_to_stack],
                                          bindings: previous_output_bindings
    end
    previous_output_bindings
  end

  def converge(stack_name:,
               path_to_stack:,
               bindings: nil,
               fail_on_changes_to_immutable_resource: false)
    extras = []
    unless bindings.nil?
      temp_file = Tempfile.new('cfnstackfortesting')
      temp_file.write bindings.to_yaml
      temp_file.close

      extras << [:yaml,File.expand_path(temp_file)]
    end

    verbose = false
    model = CfnDsl::eval_file_with_extras(File.expand_path(path_to_stack),
                                          extras,
                                          verbose)

    if fail_on_changes_to_immutable_resource
      unsafe_logical_resource_id = ChangesetUtil.new.immutable_resources_that_would_change stack_name: stack_name,
                                                                                           template_body: model.to_json
      if unsafe_logical_resource_id.nil?
        outputs = converge_stack stack_name: stack_name,
                                 stack_body: model.to_json
      else
        raise "update would modify or delete immutable resource #{unsafe_logical_resource_id}"
      end
    else
      outputs = converge_stack stack_name: stack_name,
                               stack_body: model.to_json
    end
    outputs
  end

  ##
  # Delete the specified Cloudformation stack by name
  #
  def cleanup(cloudformation_stack_name)
    resource = Aws::CloudFormation::Resource.new
    stack_to_delete = resource.stack(cloudformation_stack_name)

    stack_to_delete.delete
    begin
      stack_to_delete.wait_until(max_attempts:100, delay:15) do |stack|
        stack.stack_status.match /DELETE_COMPLETE/
      end
    rescue
      #squash any errors - when stack is gone, the waiter might freak
    end
  end

  private

  def converge_stack(stack_name:,
                     stack_body:)

    cloudformation_client = Aws::CloudFormation::Client.new
    resource = Aws::CloudFormation::Resource.new(client: cloudformation_client)
    if resource.stacks.find {|stack| stack.name == stack_name }
      stack = resource.stack(stack_name)
      begin
        stack.update(template_body: stack_body,
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
                                    template_body: stack_body,
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