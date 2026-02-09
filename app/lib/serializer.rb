class Serializer
  def self.to_json(object)
    to_hash(object).to_json
  end

  def self.to_hash(object)
    case object
    when Task then task(object)
    when Array then array(object)
    when ActiveRecord::AssociationRelation then array(object)
    when ActiveRecord::Associations::CollectionProxy then array(object)
    else raise "Serializer does not support #{object.class}"
    end
  end

  def self.array(array)
    array.map { |object| to_hash(object) }
  end

  def self.task(task)
    {
      id: task.id,
      title: task.title,
      position: task.position,
      file_url: task.file_url,
      file_name: task.file_name
    }
  end
end
