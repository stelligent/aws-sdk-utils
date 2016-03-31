# Overview
You can chuck any "low level" code that calls AWS SDK into this gem that might be useful in more than one gem/module.

# Command-Line Utilities Included

## cfndsl_converge
This command-line util is a wrapper over the cfndsl API.

Given a cfndsl definition, it will create the stack if it does not exist, or call UpdateStack
if the stack already does exist i.e. "converge".

Additionally, this util has an option to force a failure if a call to UpdateStack would cause
any changes to resources marked as "immutable".

### Immutability
The way this feature works is that the AWS API to create a "change set" is called before calling UpdateStack.

If any resources are returned in the changeset and that resource has a tag `immutable=true` then the
convergence will fail.  Currently, the resource is parsed right out of the JSON of the Clouformation template
to see if it is tagged.

Usage:
     
     cfndsl_converge --path-to-stack resource_cfndsl.rb \
                     --stack-name stack1234 \
                     --path-to-yaml anyparameters.yml \
                     --fail-on-changes-to-immutable-resource true    
                            
* The `path-to-yaml` is optional (if there are no open bindings in the cfndsl) 
* the default value for `fail-on-changes-to-immutable-resource` is false to maintain backward compatiblity
  
## yaml_get
This command-line util can be mildly useful in writing bash scripts where values stored in YAML need to be
consulted by logic in the bash script.  With the YAML input/output to cfndsl, this can come in handy as long
as you don't need to do anything elaborate with the YAML - i.e. it only reads the keys off the "top-level".

Usage:
     
     yaml_get <path to YAML file> <key>
    