module Spec
  module Rails
    module Matchers
      class HaveFilter
        def initialize(filter_name)
          @filter_name = filter_name.to_sym
          @filter_type = :before?
          @actions = :any_action
        end

        def matches?(target)
          filter = target.class.filter_chain.select { |f| f.send(@filter_type) and f.method == @filter_name }.first

          if @actions == :any_action
            filter
          else
            filter and Array(@actions).find do |action| 
              if only = filter.options[:only]
                Array(only).include?(action)
              else
                !Array(filter.options[:except]).include?(action)
              end
            end
          end
        end

        def failure_message
          "#{@target} expected to have a #{@filter_type}_filter '#{@filter_name}' but none was found."
        end

        def negative_failure_message  
          "#{@target} expected to not have a #{@filter_type}_filter '#{@filter_name}' but it was found."
        end

        def before(actions)
          @filter_type = :before?
          @actions = actions
          self
        end

        def after(actions)
          @filter_type = :after?
          @actions = actions
          self
        end

        def around(actions)
          @filter_type = :around?
          @actions = actions
          self
        end
      end

      def have_filter(method_name)
        HaveFilter.new(method_name)
      end

      def have_before_filter(method_name)
        HaveFilter.new(method_name).before(:any_action)
      end

      def have_after_filter(method_name)
        HaveFilter.new(method_name).after(:any_action)
      end

      def have_around_filter(method_name)
        HaveFilter.new(method_name).around(:any_action)
      end
    end
  end
end
