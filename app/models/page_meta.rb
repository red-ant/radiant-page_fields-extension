class PageMeta < ActiveRecord::Base
  include Annotatable
  annotate :description
  description 'Meta field'
  class_inheritable_accessor :content_column
  self.content_column = :content
  set_inheritance_column :page_meta_type
  validates_presence_of :name

  class << self
    ##
    # @param [Hash] attributes Normal ActiveRecord attrs hash
    # @option attributes [String] :page_meta_type
    #   Pass :page_meta_type => 'PageMetaDescendant' to return an object of the
    #   given subclass.
    # @example
    #   meta = PageMeta.new(:page_meta_type => 'BooleanPageMeta')
    #   meta.class #=> BooleanPageMeta
    def new(attributes={})
      attributes.stringify_keys!
      if klass_name = attributes.delete('page_meta_type') and (klass = klass_name.constantize) < PageMeta
        klass.new(attributes)
      else
        super
      end
    end

    def inherited(subclass)
      subclass.description = subclass.name.to_name('Page Meta')
    end

    ##
    # Determines how a PageMeta subclass will store content and present itself
    # in the UI.
    #
    # @param [:boolean,:integer,:datetime] type The column which this subclass
    # should use for storage.
    def content(type)
      self.content_column = "#{type}_content"
      alias_attribute :content, self.content_column
    end
    alias_method :content=, :content


    ##
    # Workaround for ActiveRecord bug,
    # see https://rails.lighthouseapp.com/projects/8994/tickets/1339
    # For development & testing you may also need to change config/environment.rb from:
    #     config.time_zone = 'UTC'
    # to:
    #     config.active_record.default_timezone = :utc
    def scoped_methods
      Thread.current[:"#{self}_scoped_methods"] ||= (self.default_scoping || []).dup
    end
  end

end
