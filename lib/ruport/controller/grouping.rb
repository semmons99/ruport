# Ruport : Extensible Reporting System                                
#
# controller/grouping.rb : Group data controller for Ruby Reports
#
# Written by Michael Milner, 2007.
# Copyright (C) 2007, All Rights Reserved
#
# This is free software distributed under the same terms as Ruby 1.8
# See LICENSE and COPYING for details.
#

# This class implements the basic controller for data groupings in Ruport
# (a collection of Groups).
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
# * <tt>show_group_headers</tt> #=> true    
# * <tt>style</tt> #=> :inline  
#
# == Formatter hooks called (in order)
#
# * build_grouping_header
# * build_grouping_body
# * build_grouping_footer
# * finalize_grouping
#
class Ruport::Controller::Grouping
  include Ruport::Controller

  options do |o| 
    o.show_group_headers = true 
    o.style = :inline
  end

  stage :grouping_header, :grouping_body, :grouping_footer
  
  finalize :grouping
end
