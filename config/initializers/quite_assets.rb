def is_windows?
  RUBY_PLATFORM['mswin32'] || RUBY_PLATFORM['mingw'] || RUBY_PLATFORM['cygwin']
end

destination = is_windows?? 'NUL' : '/dev/null'

Rails.application.assets.logger = Logger.new(destination)
Rails::Rack::Logger.class_eval do
  def call_with_quiet_assets(env)
    previous_level = Rails.logger.level
    Rails.logger.level = Logger::ERROR if env['PATH_INFO'].index("/assets/") == 0
    call_without_quiet_assets(env).tap do
      Rails.logger.level = previous_level
    end
  end
  alias_method_chain :call, :quiet_assets
end