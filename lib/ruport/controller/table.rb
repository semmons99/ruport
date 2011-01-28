# controller/table.rb : Tabular data controller for Ruby Reports
#
# Written by Gregory Brown, December 2006.  Copyright 2006, All Rights Reserved
# This is Free Software, please see LICENSE and COPYING for details.

# This class implements the basic tabular data controller for Ruport.
#
# == Supported Formatters 
#  
# * Formatter::CSV
# * Formatter::Text
# * Formatter::HTML
# * Formatter::PDF
#
# == Default layout options 
#  
# * <tt>show_table_headers</tt> #=> true
#
# == Formatter hooks called (in order)
#  
# * prepare_table
# * build_table_header
# * build_table_body
# * build_table_footer
# * finalize_table
#
class Ruport::Controller::Table
  include Ruport::Controller

  options { |o| o.show_table_headers = true }

  prepare :table
  
  stage :table_header, :table_body, :table_footer

  finalize :table
end
