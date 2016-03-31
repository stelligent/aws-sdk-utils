require_relative 'cloudformation_tag_parser'
require 'aws-sdk'

class ChangesetUtil

  def immutable_resources_that_would_change(stack_name:,
                                            template_body:)

    potentially_unsafe_changes = changes_that_modify_or_remove stack_name: stack_name,
                                                               template_body: template_body

    logical_resource_ids = potentially_unsafe_changes.map { |change| change.resource_change.logical_resource_id }

    logical_resource_ids.each do |logical_resource_id|
      tags = CloudFormationTagParser.new.tags cloudformation_json: template_body,
                                              logical_resource_id: logical_resource_id
      if tags.find { |tag| tag['Key'] == 'immutable' and tag['Value'] == 'true' }
        return logical_resource_id
      end
    end
    nil
  end


  ##
  # hmmmm how to handle parameters?  if it uses the previous value...?
  #
  def changes_that_modify_or_remove(stack_name:,
                                    template_body:,
                                    parameters: [])

    change_set_name = "changeSet#{Time.now.to_i}"
    client_token = "clientToken#{Time.now.to_i}"

    create_change_set_response = cloudformation_client.create_change_set stack_name: stack_name,
                                                                         template_body: template_body,
                                                                         capabilities: %w(CAPABILITY_IAM),
                                                                         change_set_name: change_set_name,
                                                                         client_token: client_token,
                                                                         parameters: convert_parameters(parameters)

    change_set_id = create_change_set_response.id

    describe_change_set_response = describe_change_set change_set_id: change_set_id

    describe_change_set_response.changes.select { |change| %w(Modify Remove).include? change.resource_change.action }
  end

  private

  def describe_change_set(change_set_id:)
    done = false
    while not done
      describe_change_set_response = cloudformation_client.describe_change_set change_set_name: change_set_id
      done = %w(CREATE_COMPLETE FAILED).include?(describe_change_set_response.status)
      sleep 10 unless done
    end
    describe_change_set_response
  end

  def cloudformation_client
    Aws::CloudFormation::Client.new
  end

  def convert_parameters(parameters)
    result = []
    parameters.each do |key, value|
      result << {
        parameter_key: key,
        parameter_value: value,
        use_previous_value: false
      }
    end
    result
  end
end