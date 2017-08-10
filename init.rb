require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'issue'
  require_dependency 'role'
  Role.send(:include, RedmineGroupVisibility::RolePatch)
  Issue.send(:include, RedmineGroupVisibility::IssuePatch)
end

Redmine::Plugin.register :redmine_group_visibility do
  requires_redmine :version_or_higher => '3.0.1'

  name 'Redmine group visibility'
  author 'David Robinson'
  description "Provides ability make issues visible for author groups"
  version '0.1.0'
end
