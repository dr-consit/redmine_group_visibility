module RedmineGroupVisibility
	module	RolePatch
	
		def self.included(base)
			base.class_eval do
				Role::ISSUES_VISIBILITY_OPTIONS.<<	['group', :label_issues_visibility_group]
				# The filters are part of validators are raw, they can be skipped with the following way.
				rule_inclusion_validation = base._validators[:issues_visibility].find{ |validator| validator.is_a? ActiveModel::Validations::InclusionValidator }
				base._validators[:issues_visibility].delete(rule_inclusion_validation)
				filter = base._validate_callbacks.find{ |c| c.raw_filter == rule_inclusion_validation }.filter
				skip_callback :validate, filter
				validates_inclusion_of :issues_visibility,
					:in => Role::ISSUES_VISIBILITY_OPTIONS.collect(&:first),
					:if => lambda {|role| role.respond_to?(:issues_visibility) && role.issues_visibility_changed?}
			end
		end
		
		module NewConsts
			def knud
			end
		end
	end
end