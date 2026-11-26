require 'xcodeproj'

DEPLOYMENT = '15.0'
project_path = File.expand_path('Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)
name = 'RunnerUITests'

if project.targets.any? { |t| t.name == name }
  puts "#{name} already exists - nothing to do"
  exit 0
end

runner = project.targets.find { |t| t.name == 'Runner' }
abort('Runner target not found') if runner.nil?

ids = runner.build_configurations
            .map { |c| c.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] }
            .compact
            .reject { |v| v.include?('$') }
runner_id = ids.first || 'com.example.app'

target = project.new_target(:ui_test_bundle, name, :ios, DEPLOYMENT, nil, :objc)
target.add_dependency(runner)

group = project.main_group.new_group(name, name)
target.add_file_references([group.new_file('RunnerUITests.m')])

target.build_configurations.each do |config|
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{runner_id}.RunnerUITests"
  config.build_settings['TEST_TARGET_NAME'] = 'Runner'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT
end
project.save

scheme_dir = Xcodeproj::XCScheme.shared_data_dir(project_path)
scheme_path = scheme_dir + 'Runner.xcscheme'
if File.exist?(scheme_path)
  scheme = Xcodeproj::XCScheme.new(scheme_path)
  scheme.add_test_target(target)
  scheme.save!
else
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(runner)
  scheme.set_launch_target(runner)
  scheme.add_test_target(target)
  scheme.save_as(project_path, 'Runner', true)
end

puts "Added #{name} target"