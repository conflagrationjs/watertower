require 'rubygems'
require 'riot'
require 'pathname'
require 'ruby-debug'

$LOAD_PATH << (Pathname(__FILE__).parent.parent + "lib").expand_path.to_s

# HOT MONKEY PATCHING LOVE
class Riot::Context
  alias_method :old_should, :should
  def should(description, options = {}, &block)
    if options[:before]
      new_block = lambda do 
        Array(options[:before]).each do |before|
          instance_eval(&before)
        end
        instance_eval(&block)
      end
      old_should(description, &new_block)
    else
      old_should(description, &block)
    end
  end
  
end

at_exit do
  Riot.report
end