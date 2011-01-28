# This class implements the basic controller for table rows.
#
# == Supported Formatters 
#  
# * Formatter::CSV
# * Formatter::Text
# * Formatter::HTML
#
# == Formatter hooks called (in order)
#  
# * build_row
#
class Ruport::Controller::Row
  include Ruport::Controller

  stage :row
end
