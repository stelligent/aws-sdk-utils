require 'json'

class CloudFormationTagParser

  def tags(cloudformation_json:,
           logical_resource_id:)

    cloudformation = JSON.load(cloudformation_json)
    if cloudformation['Resources'].nil?
      raise 'malformed json, must have Resources key at least'
    end

    resource = cloudformation['Resources'][logical_resource_id]
    if resource.nil?
      raise "logical resource id #{logical_resource_id} is not found"
    end

    # Properties isn't there is a blow error, but jsut ignore that... need a better all-round parser for cfn in the first place
    tags = resource['Properties']['Tags']
    tags.nil? ? [] : tags
  end
end