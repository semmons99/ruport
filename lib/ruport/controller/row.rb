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
module Ruport
  module Controller
    class Row
      include Controller

      stage :row
    end
  end
end
