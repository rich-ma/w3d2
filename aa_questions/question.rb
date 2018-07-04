require_relative 'questionsdatabase'
require_relative 'model_base'

class Question < ModelBase
  attr_accessor :id, :title, :body, :author_id
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
  
  def save
    if @id
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id, @id)
        UPDATE 
          questions
        SET
         title = ?, body = ?, author_id = ?
        WHERE
          id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
        INSERT INTO 
          questions (title, body, author_id)
        VALUES
         (?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      questions
    WHERE
      id = ?
    SQL
    raise "NO" if data.empty?
    Question.new(data.first)
  end
  
  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    SELECT
      *
    FROM
      questions
    WHERE
      author_id = ?
    SQL
    raise "NO" if data.empty?
    data.map {|datum| Question.new(datum)}
  end
  
  def author
    User.find_by_id(self.author_id)
  end
  
  def replies
    Reply.find_by_question_id(self.id)
  end  
  
  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
  
  def likers
    QuestionLike.likers_for_question_id(self.id)
  end
  
  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end
  
  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
  
  #question
end