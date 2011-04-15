require "spec/ruby"
require "spec/runner"

# output T/F as Green/Red
ENV['RSPEC_COLOR'] = 'true'

require File.join(File.dirname(__FILE__),  "focusing_adds_editing_class")
require File.join(File.dirname(__FILE__),  "focusing_makes_editable")
require File.join(File.dirname(__FILE__),  "entering_text_changes_value")
