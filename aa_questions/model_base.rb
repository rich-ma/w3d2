require_relative 'questionsdatabase'
require 'active_support/inflector'


class ModelBase
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT *
    FROM #{self.table}
    WHERE
      id = ?
    SQL
    raise "you suck try again" if data.empty?
    self.new(data.first)
  end

  def self.table
    table_name = self.to_s.downcase
    if table_name[-1] == "y"
      table_name = table_name[0..-2] + "ies"
    else
      table_name += "s"
    end
  end
  
  def save
    
  end
  
  def where(options)
    options.keys
    data = QuestionsDatabase.instance.execute(<<-SQL,#{} )
    
    SQL
    
    data.blah
  end
end
:id = > " "
Object#instance_variables @{fdfdsf.to_s}

require_relative 'user'
