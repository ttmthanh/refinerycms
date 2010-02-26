# Set up middleware to serve theme files
config.middleware.use "ThemeServer"

# Add or remove theme paths to/from Refinery application
::Refinery::ApplicationController.module_eval do
  before_filter do |controller|
    controller.view_paths.reject! { |v| v.to_s =~ %r{^themes/} }
    if (theme = RefinerySetting[:theme]).present?
      # Set up view path again for the current theme.
      controller.view_paths.unshift Rails.root.join("themes", theme, "views").to_s

      RefinerySetting[:refinery_menu_cache_action_suffix] = "#{theme}_site_menu"
    else
      # Set the cache key for the site menu (thus expiring the fragment cache if theme changes).
      RefinerySetting[:refinery_menu_cache_action_suffix] = "site_menu"
    end
  end
end

if (theme = RefinerySetting[:theme]).present?
  # Set up controller paths, which can only be brought in with a server restart, sorry. (But for good reason)
  controller_path = Rails.root.join("themes", theme, "controllers").to_s

  ::ActiveSupport::Dependencies.load_paths.unshift controller_path
  config.controller_paths.unshift controller_path
end

# Include theme functions into application helper.
Refinery::ApplicationHelper.send :include, ThemesHelper
