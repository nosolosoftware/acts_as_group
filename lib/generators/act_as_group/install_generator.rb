require 'rails/generators'
require 'rails/generators/active_record'

module ActAsGroup
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration
    source_root File.expand_path('templates', __dir__)
    desc 'Installs ActAsGroup.'

    def install
      template 'initializer.rb', 'config/initializers/act_as_group.rb'
      readme 'README'
    end
  end
end
