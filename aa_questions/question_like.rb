require_relative 'questionsdatabase'

class QuestionLike
  attr_accessor :id, :user_id, :question_id
  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      question_likes
    WHERE
      id = ?
    SQL
    raise "NO" if data.empty?
    QuestionLike.new(data.first)
  end
  
  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT users.*
    FROM users
    JOIN question_likes ON users.id = question_likes.user_id
    WHERE question_likes.question_id = ?
    SQL
    data.map {|datum| User.new(datum)}
  end
  
  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT COUNT(*)
    FROM users
    JOIN question_likes ON users.id = question_likes.user_id
    WHERE question_likes.question_id = ?
    GROUP BY question_likes.question_id 
    SQL
    return 0 if data.empty?
    data[0].to_a[0][1]
  end
  
  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT questions.*
    FROM questions
    JOIN question_likes ON questions.id = question_likes.question_id
    WHERE question_likes.user_id = ?
    SQL
    data.map {|datum| Question.new(datum)}
  end
  
  def self.most_liked_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.*
      FROM questions
      JOIN question_likes ON questions.id = question_likes.question_id
      GROUP BY question_likes.question_id
      ORDER BY COUNT(*) DESC
      LIMIT ?
    SQL
    data.map {|datum| Question.new(datum)}
  end
  
end