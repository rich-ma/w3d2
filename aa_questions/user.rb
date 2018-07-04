require_relative 'questionsdatabase'
require_relative 'model_base'

class User < ModelBase
  attr_accessor :id, :fname, :lname
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
  
  def save
    if @id
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
        UPDATE 
          users
        SET
         fname = ?, lname = ?
        WHERE
          id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
        INSERT INTO 
          users (fname, lname)
        VALUES
         (?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map {|datum| User.new(datum)}
  end

  # def self.find_by_id(id)
  #   data = QuestionsDatabase.instance.execute(<<-SQL, id)
  #   SELECT
  #     *
  #   FROM
  #     users
  #   WHERE
  #     id = ?
  #   SQL
  #   raise "you suck try again" if data.empty?
  #   User.new(data.first)
  # end
  
  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      fname = ? AND lname = ?
    SQL
    raise "NO" if data.empty?
    User.new(data.first)
  end
  
  def authored_questions
    Question.find_by_author_id(self.id)
  end
  
  def authored_replies
    Reply.find_by_author_id(self.id)
  end
  
  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end
  
  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end
  
  def average_karma
    sum = 0
    questions = self.authored_questions
    questions.each do |question|
      p question
      sum += question.num_likes
    end
    sum/questions.length.to_f
  end
  
  #User
end