require_relative 'questionsdatabase'
require_relative 'model_base'

class Reply < ModelBase
  attr_accessor :id, :body, :author_id, :question_id, :parent_reply_id
  def initialize(options)
    @id = options['id']
    @body = options['body']
    @author_id = options['author_id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
  end
  
  def save
    if @id
      QuestionsDatabase.instance.execute(<<-SQL, @body, @author_id, @question_id, @parent_reply_id, @id)
        UPDATE 
          replies
        SET
         body = ?, author_id = ?, question_id = ?, parent_reply_id = ?
        WHERE
          id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, @body, @author_id, @question_id, @parent_reply_id)
        INSERT INTO 
          replies (body, author_id, question_id, parent_reply_id)
        VALUES
         (?, ?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
    SQL
    raise "NO" if data.empty?
    Reply.new(data.first)
  end
  
  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    SELECT
      *
    FROM
      replies
    WHERE
      author_id = ?
    SQL
    raise "NO" if data.empty?
    Reply.new(data.first)
  end
  
  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      replies
    WHERE
      question_id = ?
    SQL
    raise "NO" if data.empty?
    Reply.new(data.first)
  end
  
  def author
    User.find_by_id(self.author_id)
  end
  
  def question
    Question.find_by_id(self.question_id)  
  end
  
  def parent_reply
    Reply.find_by_id(self.parent_reply_id)
  end
  
  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT *
      FROM replies
      WHERE parent_reply_id = ?
    SQL
    raise "SCREW YOU" if data.empty?
    data.map do |child|
      Reply.new(child)
    end
  end
  
end