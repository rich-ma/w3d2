require_relative 'questionsdatabase'

class QuestionFollow
  attr_accessor :id, :user_id, :question_id
  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      question_follows
    WHERE
      id = ?
    SQL
    raise if data.empty?
    QuestionFollow.new(data.first)
  end
  
  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.*
    FROM
      question_follows
    JOIN users
    ON users.id = question_follows.user_id
    WHERE
      question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end
    
  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM
      question_follows
    JOIN questions
    ON questions.id = question_follows.question_id
    WHERE
      user_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end
  
  def self.most_followed_questions(num)
    data = QuestionsDatabase.instance.execute(<<-SQL, num)
    SELECT
      questions.*, COUNT(*)
    FROM
      question_follows
    JOIN questions
    ON questions.id = question_follows.question_id
    GROUP BY question_follows.question_id
    ORDER BY COUNT(*) DESC
    LIMIT ?
    SQL
    data.map { |datum| Question.new(datum) }
  end
    
end