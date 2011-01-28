# This module provides hooks into Ruport's formatting system.
# It is used to implement the as() method for all of Ruport's data
# structures, as well as the renders_with and renders_as_* helpers.
#
# You can actually use this with any data structure, it will look for a
# renderable_data(format) method to pass to the <tt>controller</tt> you 
# specify, but if that is not defined, it will pass <tt>self</tt>.
#
# Examples:
#
#   # Render Arrays with Ruport's Row Controller
#   class Array
#     include Ruport::Controller::Hooks
#     renders_as_row
#   end
#
#   # >> [1,2,3].as(:csv) 
#   # => "1,2,3\n" 
#
#   # Render Hashes with Ruport's Row Controller
#   class Hash
#      include Ruport::Controller::Hooks
#      renders_as_row
#      attr_accessor :column_order
#      def renderable_data(format)
#        column_order.map { |c| self[c] }
#      end
#   end
#
#   # >> a = { :a => 1, :b => 2, :c => 3 }
#   # >> a.column_order = [:b,:a,:c]
#   # >> a.as(:csv)
#   # => "2,1,3\n"
module Ruport
  module Controller
    module Hooks 
      module ClassMethods 
        
        # Tells the class which controller as() will forward to.
        #
        # Usage:
        #
        #   class MyStructure
        #     include Controller::Hooks
        #     renders_with CustomController
        #   end
        #   
        # You can also specify default rendering options, which will be used
        # if they are not overriden by the options passed to as().
        #
        #   class MyStructure
        #     include Controller::Hooks
        #     renders_with CustomController, :font_size => 14
        #   end
        def renders_with(controller,opts={})
          @controller = controller
          @rendering_options=opts
        end  
        
        # The default rendering options for a class, stored as a hash.
        def rendering_options
          @rendering_options
        end
         
        # Shortcut for renders_with(Ruport::Controller::Table), you
        # may wish to override this if you build a custom table controller.
        def renders_as_table(options={})
          renders_with Ruport::Controller::Table,options
        end
        
        # Shortcut for renders_with(Ruport::Controller::Row), you
        # may wish to override this if you build a custom row controller. 
        def renders_as_row(options={})
          renders_with Ruport::Controller::Row, options
        end
        
        # Shortcut for renders_with(Ruport::Controller::Group), you
        # may wish to override this if you build a custom group controller.  
        def renders_as_group(options={})
          renders_with Ruport::Controller::Group,options
        end 
        
        # Shortcut for renders_with(Ruport::Controller::Grouping), you
        # may wish to override this if you build a custom grouping controller.
        def renders_as_grouping(options={})
          renders_with Ruport::Controller::Grouping,options
        end
        
        # The class of the controller object for the base class.
        #
        # Example:
        # 
        #   >> Ruport::Data::Table.controller
        #   => Ruport::Controller::Table
        def controller
          @controller
        end
      end

      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end      
      
      # Uses the Controller specified by renders_with to generate formatted
      # output.  Passes the return value of the <tt>renderable_data(format)</tt>
      # method if the method is defined, otherwise passes <tt>self</tt> as :data
      #
      # The remaining options are converted to a Controller::Options object and
      # are accessible in both the controller and formatter.
      #
      #  Example:
      #
      #    table.as(:csv, :show_table_headers => false)
      def as(format,options={})
        unless self.class.controller
          raise Ruport::Controller::ControllerNotSetError
        end
        unless self.class.controller.formats.include?(format)
          raise Ruport::Controller::UnknownFormatError
        end
        self.class.controller.render(format,
          self.class.rendering_options.merge(options)) do |rend|
            rend.data =
              respond_to?(:renderable_data) ? renderable_data(format) : self
            yield(rend) if block_given?  
        end
      end      
      
      def save_as(file,options={})
        file =~ /.*\.(.*)/    
        format = $1
        as(format.to_sym, options.merge(:file => file))        
      end
    end
  end
end
