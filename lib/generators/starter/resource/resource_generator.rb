require 'rails/generators/active_record'
require_relative './migration'
module Starter
  class ResourceGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    include Rails::Generators::ResourceHelpers
    include Rails::Generators::Migration
    extend ActiveRecord::Generators::Migration

    argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
    remove_class_option :old_style_hash

    def generate_controller
      template 'controller.rb', "app/controllers/#{plural_name.underscore}_controller.rb"
    end

    def generate_model
      template 'model.rb', "app/models/#{singular_name.underscore}.rb"
    end

    def generate_migration
      migration_template "migration.rb", "db/migrate/create_#{table_name}.rb"
    end

    def create_root_view_folder
      empty_directory File.join("app/views", controller_file_path)
    end

    def copy_view_files
      available_views.each do |view|
        filename = filename_with_extensions(view)
        template filename, File.join("app/views", controller_file_path, filename)
      end
    end


    def generate_routes

      route ["# Routes for the #{singular_name.capitalize} resource:",
        "  # CREATE",
        "  get '/#{plural_name}/new', controller: '#{plural_name}', action: 'new'",
        "  post '/#{plural_name}', controller: '#{plural_name}', action: 'create'",
        "",
        "  # READ",
        "  get '/#{plural_name}', controller: '#{plural_name}', action: 'index'",
        "  get '/#{plural_name}/:id', controller: '#{plural_name}', action: 'show'",
        "",
        "  # UPDATE",
        "  get '/#{plural_name}/:id/edit', controller: '#{plural_name}', action: 'edit'",
        "  put '/#{plural_name}/:id', controller: '#{plural_name}', action: 'update'",
        "",
        "  # DELETE",
        "  delete '/#{plural_name}/:id', controller: '#{plural_name}', action: 'destroy'",
        "  ##{'-' * 30}"
      ].join("\n"), "RESTful routes"
    end

protected

  # Override of Rails::Generators::Actions
  def route(routing_code, title)
    log :route, title
    sentinel = /\.routes\.draw do(?:\s*\|map\|)?\s*$/

    in_root do
      inject_into_file 'config/routes.rb', "\n  #{routing_code}\n", { :after => sentinel, :verbose => false }
    end
  end

  def attributes_with_index
    attributes.select { |a| a.has_index? || (a.reference? && options[:indexes]) }
  end

  def available_views
    %w(index new edit show)
  end

  def filename_with_extensions(name)
    [name, :html, :erb].compact.join(".")
  end

  end
end