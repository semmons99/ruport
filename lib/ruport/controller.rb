# controller.rb : General purpose control of formatted data for Ruby Reports
#
# Copyright December 2006, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
require 'ruport/controller/errors'

# This class implements the core controller for Ruport's formatting system.
# It is designed to implement the low level tools necessary to build report
# controllers for different kinds of tasks.  See Controller::Table for a
# tabular data controller.  
#
module Ruport
  module Controller
    
    module ClassMethods

      # Returns a hash that maps format names to their formatter classes, for use
      # with the formatter shortcut.  Supported formats are :html, :csv, :pdf, and
      # :text by default.
      #
      #
      # Sample override:
      #
      #   class MyController < Ruport::Controller
      # 
      #     def built_in_formats
      #       super.extend(:xml => MyXMLFormatter,
      #                    :json => MyJSONFormatter)
      #     end
      #   end 
      #
      # This would allow for:
      #
      #   class ChildController < MyController
      #
      #     formatter :xml do
      #       # ...
      #     end
      #
      #     formatter :json do
      #       # ...
      #     end
      #   end
      #     
      def built_in_formats
       { :html => Ruport::Formatter::HTML,
         :csv  => Ruport::Formatter::CSV,
         :pdf  => Ruport::Formatter::PDF,
         :text => Ruport::Formatter::Text }
      end


      # Generates an anonymous formatter class and ties it to the Controller.
      # This method looks up the built in formats in the hash returned by 
      # built_in_formats, but also explicitly specify a custom Formatter class to
      # subclass from.
      #
      # Sample usage:
      #
      #   class ControllerWithAnonymousFormatters < Ruport::Controller
      #   
      #     stage :report
      #   
      #     formatter :html do
      #       build :report do
      #         output << textile("h1. Hi there")
      #       end
      #     end
      #   
      #     formatter :csv do
      #       build :report do
      #         build_row([1,2,3])
      #       end
      #     end
      #   
      #     formatter :pdf do
      #       build :report do
      #         add_text "hello world"
      #       end
      #     end
      #   
      #     formatter :text do
      #       build :report do
      #         output << "Hello world"
      #       end
      #     end
      #   
      #     formatter :custom => CustomFormatter do
      #   
      #       build :report do
      #         output << "This is "
      #         custom_helper
      #       end
      #   
      #     end
      #   
      #   end
      #
      def formatter(*a,&b)
        case a[0]
        when Symbol
          klass = Class.new(built_in_formats[a[0]])
          klass.renders a[0], :for => self
        when Hash
          k,v = a[0].to_a[0]
          klass = Class.new(v)
          klass.renders k, :for => self
        end
        klass.class_eval(&b)
      end
      
      attr_accessor :first_stage,:final_stage,:required_options,:stages #:nodoc: 
      
      # Registers a hook to look for in the Formatter object when the render()
      # method is called.                           
      #
      # Usage:
      #
      #   class MyController < Ruport::Controller
      #      # other details omitted...
      #      finalize :apple
      #   end
      #
      #   class MyFormatter < Ruport::Formatter
      #      renders :example, :for => MyController
      # 
      #      # other details omitted... 
      #    
      #      def finalize_apple
      #         # this method will be called when MyController tries to render
      #         # the :example format
      #      end
      #   end  
      #
      #  If a formatter does not implement this hook, it is simply ignored.
      def finalize(stage)
        if final_stage
          raise StageAlreadyDefinedError, 'final stage already defined'      
        end
        self.final_stage = stage
      end
      
      # Registers a hook to look for in the Formatter object when the render()
      # method is called.                           
      #
      # Usage:
      #
      #   class MyController < Ruport::Controller
      #      # other details omitted...
      #      prepare :apple
      #   end
      #
      #   class MyFormatter < Ruport::Formatter
      #      renders :example, :for => MyController
      #
      #      def prepare_apple
      #         # this method will be called when MyController tries to render
      #         # the :example format
      #      end        
      #      
      #      # other details omitted...
      #   end  
      #
      #  If a formatter does not implement this hook, it is simply ignored.
      def prepare(stage)
        if first_stage
          raise StageAlreadyDefinedError, "prepare stage already defined"      
        end 
        self.first_stage = stage
      end
      
      # Registers hooks to look for in the Formatter object when the render()
      # method is called.                           
      #
      # Usage:
      #
      #   class MyController < Ruport::Controller
      #      # other details omitted...
      #      stage :apple,:banana
      #   end
      #
      #   class MyFormatter < Ruport::Formatter
      #      renders :example, :for => MyController
      #
      #      def build_apple
      #         # this method will be called when MyController tries to render
      #         # the :example format
      #      end 
      #   
      #      def build_banana
      #         # this method will be called when MyController tries to render
      #         # the :example format
      #      end    
      #      
      #      # other details omitted...
      #   end  
      #
      #  If a formatter does not implement these hooks, they are simply ignored.          
      def stage(*stage_list)
        self.stages ||= []
        stage_list.each { |stage|
          self.stages << stage.to_s 
        }
      end
       
      # Defines attribute writers for the Controller::Options object shared
      # between Controller and Formatter. Will throw an error if the user does
      # not provide values for these options upon rendering.
      #
      # usage:
      #   
      #   class MyController < Ruport::Controller
      #      required_option :employee_name, :address
      #      # other details omitted
      #   end
      def required_option(*opts) 
        self.required_options ||= []
        opts.each do |opt|
          self.required_options << opt 

          o = opt
          unless instance_methods(false).include?(o.to_s)
            define_method(o) { options.send(o.to_s) }
          end
          opt = "#{opt}="
          define_method(opt) {|t| options.send(opt, t) }
        end
      end

      # Lists the formatters that are currently registered on a controller,
      # as a hash keyed by format name.
      #
      # Example:
      # 
      #   >> Ruport::Controller::Table.formats
      #   => {:html=>Ruport::Formatter::HTML, 
      #   ?>  :csv=>Ruport::Formatter::CSV, 
      #   ?>  :text=>Ruport::Formatter::Text, 
      #   ?>  :pdf=>Ruport::Formatter::PDF}
      def formats
        @formats ||= {}
      end
      
      # Builds up a controller object, looks up the appropriate formatter,
      # sets the data and options, and then does the following process:
      #
      #   * If the controller contains a module Helpers, mix it in to the instance.
      #   * If a block is given, yield the Controller instance.
      #   * If a setup() method is defined on the Controller, call it.
      #   * Call the run() method.
      #   * If the :file option is set to a file name, appends output to the file.
      #   * Return the results of formatter.output
      #
      # Please see the examples/ directory for custom controller examples, because
      # this is not nearly as complicated as it sounds in most cases.
      def render(format, add_options=nil)
        rend = build(format, add_options) { |r|
            yield(r) if block_given?   
          r.setup if r.respond_to? :setup
        }  
        rend.run
        rend.formatter.save_output(rend.options.file) if rend.options.file
        return rend.formatter.output
      end

      # Allows you to set class-wide default options.
      # 
      # Example:
      #  
      #  options { |o| o.style = :justified }
      #
      def options
        @options ||= Ruport::Controller::Options.new
        yield(@options) if block_given?

        return @options
      end

      # Provides a shortcut to render() to allow
      # render(:csv) to become render_csv
      #
      def method_missing(id,*args,&block)
        id.to_s =~ /^render_(.*)/
        unless args[0].kind_of? Hash
          args = [ (args[1] || {}).merge(:data => args[0]) ]
        end
        $1 ? render($1.to_sym,*args,&block) : super
      end

      private
      
      # Creates a new instance of the controller and sets it to use the specified
      # formatter (by name).  If a block is given, the controller instance is
      # yielded.  
      #
      # Returns the controller instance.
      #
      def build(format, add_options=nil)
        rend = self.new

        rend.send(:use_formatter, format)
        rend.send(:options=, options.dup)
        if rend.class.const_defined? :Helpers
          rend.formatter.extend(rend.class.const_get(:Helpers))
        end
        if add_options.kind_of?(Hash)
          d = add_options.delete(:data)
          rend.data = d if d
          add_options.each {|k,v| rend.options.send("#{k}=",v) }
        end

        yield(rend) if block_given?
        return rend
      end
      
      # Allows you to register a format with the controller.
      #
      # Example:
      #
      #   class MyFormatter < Ruport::Formatter
      #     # formatter code ...
      #     SomeController.add_format self, :my_formatter
      #   end
      #
      def add_format(format,name=nil)
        formats[name] = format
      end
    
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
    
    # The name of format being used.
    attr_accessor :format  
    
    # The formatter object being used.
    attr_writer :formatter  
    
    # The +data+ that has been passed to the active formatter.
    def data
      formatter.data
    end

    # Sets +data+ attribute on the active formatter.
    def data=(val)
      formatter.data = val
    end

    # Controller::Options object which is shared with the current formatter.
    def options
      yield(formatter.options) if block_given?
      formatter.options
    end
    
    # Call the _run_ method.  You can override this method in your custom
    # controller if you need to define other actions.
    def run
      _run_
    end
    
    # If an IO object is given, Formatter#output will use it instead of 
    # the default String.  For Ruport's core controllers, we technically
    # can use any object that supports the << method, but it's meant
    # for IO objects such as File or STDOUT
    #
    def io=(obj)
      options.io=obj    
    end

    # Returns the active formatter.
    #
    # If a block is given, it is evaluated in the context of the formatter.
    def formatter(&block)
      @formatter.instance_eval(&block) if block   
      return @formatter
    end

    private  

    # Called automatically when the report is rendered. Uses the
    # data collected from the earlier methods.
    def _run_
      unless self.class.required_options.nil?
        self.class.required_options.each do |opt|
          if options.__send__(opt).nil?
            raise RequiredOptionNotSet, "Required option #{opt} not set"
          end
        end
      end

      if formatter.respond_to?(:apply_template) && options.template != false
        formatter.apply_template if options.template ||
          Ruport::Formatter::Template.default
      end

      prepare self.class.first_stage if self.class.first_stage
                
      if formatter.respond_to?(:layout)  && options.layout != false
        formatter.layout do execute_stages end
      else
        execute_stages
      end

      finalize self.class.final_stage if self.class.final_stage
      maybe :finalize
    end  
    
    def execute_stages
      unless self.class.stages.nil?
        self.class.stages.each do |stage|
          maybe("build_#{stage}")
        end
      end
    end

    def prepare(name)
      maybe "prepare_#{name}"
    end

    def finalize(name)
      maybe "finalize_#{name}"
    end      
    
    def maybe(something)
      formatter.send something if formatter.respond_to? something
    end    

    def options=(o)
      formatter.options = o
    end
    
    # Selects a formatter for use by format name
    def use_formatter(format)
      raise UnknownFormatError unless self.class.formats.include?(format) &&
        self.class.formats[format].respond_to?(:new)
      self.formatter = self.class.formats[format].new
      self.formatter.format = format
    end

  end
end

require "ruport/controller/options"
require "ruport/controller/hooks"
require "ruport/controller/row"
require "ruport/controller/table"
require "ruport/controller/group"
require "ruport/controller/grouping"         
