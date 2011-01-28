# This class implements the basic controller for a single group of data.
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
# * build_group_header
# * build_group_body
# * build_group_footer
#
class Ruport::Controller::Group
  include Ruport::Controller

  options { |o| o.show_table_headers = true }

  stage :group_header, :group_body, :group_footer
end
