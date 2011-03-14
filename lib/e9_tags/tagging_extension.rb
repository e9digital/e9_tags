module E9Tags
  module TaggingExtension
    extend ActiveSupport::Concern
  
    included do
      alias :content :taggable

      delegate :name, :to => :tag

      scope :hidden, lambda {
        where(arel_table[:contexts].matches('%__H__').not)
      }

      scope :excluding_tags, lambda {|*tags|
        joins(:tag).where(Tag.arel_table[:name].in(tags.flatten).not)
      }
       
      scope :including_tags, lambda {|*tags|
        joins(:tag).where(Tag.arel_table[:name].in(tags.flatten))
      }

      def as_json(options = {})
        tag.try(:name)
      end

      # monkeypatch association method to also store the subclass
      def taggable_with_subclass(taggable)
        self.sub_taggable_type = taggable.class.to_s
        taggable_without_subclass(taggable)
      end
      alias :taggable_without_subclass :taggable=
      alias :taggable= :taggable_with_subclass
    end

    module ClassMethods
      def contexts(options = {})
        scope = arel_table.project(:context)

        if !options[:show_all]
          condition = arel_table[:context].matches('%__H__')
          condition = condition.not unless options[:show_hidden]
          scope = scope.where(condition)
        end

        scope.map {|row| row.tuple.first }.uniq
      end
    end
  end
end
