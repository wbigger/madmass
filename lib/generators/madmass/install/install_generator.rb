module Madmass
  module Generators

    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      desc "Installs gem files in the newly created rails application"

      argument :keys, :type => :string
      argument :values, :type => :string

      def initialize(names, args, options)
        super
        # FIXME Really can not do it differently??
        @options = HashWithIndifferentAccess[*keys.split(',').zip(values.split(',')).flatten]
      end
      
      def install_js_core
        copy_file "config.js", "app/assets/javascripts/madmass/config.js"
      end

      def setup_socky
        if(@options[:ws_client] == 'socky')
          template "socky_server.yml.erb", "socky_server.yml"
          template "socky_hosts.yml.erb", "config/socky_hosts.yml"
        end
      end

      def setup_stilts
        if(@options[:ws_adapter] == 'stilts')
          # none now
        end
      end

      def setup_devise
        begin
        # Setup Devise only if it is enabled
        return if(@options[:devise] != "true")
        inject_into_file "app/controllers/application_controller.rb",
            "\n  include Madmass::AuthenticationHelper",
            :after => "protect_from_forgery"

        return if(@options[:ws_client] == "none")
        inject_into_file "app/controllers/application_controller.rb",
            "\n  helper Madmass::ApplicationHelper",
            :after => "protect_from_forgery"

        rescue Exception => ex
          puts ex.message
          puts ex.backtrace.join("\n")
        end
      end

      def add_engine_route
        route("mount Madmass::Engine => '/madmass', :as => 'madmass_engine'")
      end

      def add_torquebox_confs
        template "torquebox.yml.erb", "config/torquebox.yml"
      end

    end

  end
end
