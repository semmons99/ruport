module Ruport
  module Formatter
    # Provides shortcuts so that you can use Ruport's default rendering
    # capabilities within your custom formatters
    #
    module RenderingTools
      # Uses Ruport::Controller::Row to render the Row object with the
      # given options.
      #
      # Sets the <tt>:io</tt> attribute by default to the existing
      # formatter's <tt>output</tt> object.
      def render_row(row,options={},&block)
        render_helper(Ruport::Controller::Row,row,options,&block)
      end

      # Uses Ruport::Controller::Table to render the Table object with the
      # given options.
      #
      # Sets the :io attribute by default to the existing formatter's
      # output object.
      def render_table(table,options={},&block)
        render_helper(Ruport::Controller::Table,table,options,&block)
      end

      # Uses Ruport::Controller::Group to render the Group object with the
      # given options.
      #
      # Sets the :io attribute by default to the existing formatter's
      # output object.
      def render_group(group,options={},&block)
        render_helper(Ruport::Controller::Group,group,options,&block)
      end

      # Uses Ruport::Controller::Grouping to render the Grouping object with the
      # given options.
      #
      # Sets the :io attribute by default to the existing formatter's
      # output object.
      def render_grouping(grouping,options={},&block)
        render_helper(Ruport::Controller::Grouping,grouping,options,&block)
      end

      # Iterates through the data in the grouping and renders each group
      # followed by a newline.
      #
      def render_inline_grouping(options={},&block)
        data.each do |_,group|
          render_group(group, options, &block)
          output << "\n"
        end
      end

      private

      def render_helper(rend_klass, source_data,options={},&block)
        options = {:data => source_data,
                   :io => output,
                   :layout => false }.merge(options)

        options[:io] = "" if self.class.kind_of?(Ruport::Formatter::PDF)
        rend_klass.render(format,options) do |rend|
          block[rend] if block
        end
      end

    end
  end
end
