module RedmineGroupVisibility
	module  IssuePatch
		def self.included(base)
      base.extend(ClassMethods)
			base.send(:include, InstanceMethods)
			base.class_eval do
				unloadable				
        alias_method_chain :visible?, :group_visibility
        class << self
          alias_method_chain :visible_condition, :group_visibility
        end
			end
		end

    module ClassMethods
      # Returns a SQL conditions string used to find all issues visible by the specified user
      def visible_condition_with_group_visibility(user, options={})
        result = visible_condition_without_group_visibility(user, options)
        Project.allowed_to_condition(user, :view_issues, options) do |role, user|
          if user.id && user.logged?
            if role.issues_visibility == 'group'
              user_ids = ([user.id] + user.groups.map(&:id).compact + user.groups.map(&:users).flatten.map(&:id)).uniq
              result = "(#{table_name}.author_id in (#{user_ids.join(',')}) OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}))"
            end
          end
        end
        result
      end      
    end
    
		module InstanceMethods    
      # Returns true if usr or current user is allowed to view the issue
      def visible_with_group_visibility?(usr=nil)
        result = visible_without_group_visibility?(usr)
        (usr || User.current).allowed_to?(:view_issues, self.project) do |role, user|
          if user.logged?
            if role.issues_visibility == 'group'
              result = user.groups.map(&:users).flatten.uniq.inject(false) { |p, u| p ||= (self.author == u || u.is_or_belongs_to?(assigned_to)) }
            end
          end
        end
        result
      end        
		end
	end
end
