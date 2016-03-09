require 'aws-sdk'

class LambdaAliasSwitcher

  def switch_alias(function_name:,
                   alias_arg:,
                   function_version: '$LATEST')
    fail 'function name is nil' if function_name.nil?
    fail 'alias arg is nil' if alias_arg.nil?

    client = Aws::Lambda::Client.new

    list_aliases_response = client.list_aliases function_name: function_name

    found_alias = list_aliases_response.aliases.find do |alias_iter|
      alias_iter.name == alias_arg
    end

    if found_alias.nil?

      create_alias_response = client.create_alias function_name: function_name,
                                                  name: alias_arg,
                                                  function_version: function_version

      create_alias_response.alias_arn
    else
      update_alias_response = client.update_alias function_name: function_name,
                                                  name: alias_arg,
                                                  function_version: function_version
      update_alias_response.alias_arn
    end
  end
end