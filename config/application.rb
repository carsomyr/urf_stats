# -*- coding: utf-8 -*-
#
# Copyright 2015 Roy Liu
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

require "pathname"
require Pathname.new("../boot").expand_path(__FILE__)
require "rails/all"

if defined?(Bundler)
  Bundler.require(:default, :assets, Rails.env)
end

class Application < Rails::Application
  # Loads the given YAML configuration file.
  #
  # @param filename [String] the filename.
  #
  # @return [ActiveSupport::OrderedOptions] the configuration values.
  def load_yaml(filename)
    file = Pathname.new(filename).expand_path(::Rails.root)
    yaml_content = YAML.load(file.open { |f| f.read })

    raise ArgumentError, "The top-level YAML object must be a Hash" \
      if !yaml_content.is_a?(Hash) && !yaml_content.nil?

    method_name = file.sub_ext("").basename

    if config.respond_to?(:"#{method_name}")
      oo = config.send(:"#{method_name}")
    else
      oo = ActiveSupport::OrderedOptions.new
      config.send(:"#{method_name}=", oo)
    end

    (yaml_content || {}).each_pair { |k, v| oo[k] = v }

    oo
  end

  # Settings in `config/environments.rb` take precedence over those specified here. Application configuration should go
  # into files in `config/initializers`: All `.rb` files in that directory are automatically loaded.

  # Set the default encoding used in templates for Ruby 1.9.
  config.encoding = "utf-8"

  # Set sensitive parameters which will be filtered from the log file.
  config.filter_parameters += [:password]

  # Enable escaping HTML in JSON.
  config.active_support.escape_html_entities_in_json = true

  # Set the assets version: Change this if you want to expire them.
  config.assets.version = "1.0"

  # Add Haml as a template engine.
  config.generators { |g| g.template_engine :haml }

  # Disable automatic inclusion of helpers by controllers.
  config.action_controller.include_all_helpers = false

  # Validate locales.
  config.i18n.enforce_available_locales = true

  # Load our custom YAML settings.
  ["config/action_mailer.yml",
   "config/airbrake.yml",
   "config/google_analytics.yml"].each do |filename|
    load_yaml(filename)
  end

  # Hardcode the time zone.
  config.time_zone = "Eastern Time (US & Canada)"
end
