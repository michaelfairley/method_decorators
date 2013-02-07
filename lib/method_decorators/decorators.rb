Dir.glob(File.dirname(__FILE__) + '/decorators/*.rb') do |file|
  require "method_decorators/decorators/#{File.basename(file, '.rb')}"
end
