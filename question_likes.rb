require_relative 'question_db_connection'

class QuestionLike
    attr_accessor :id, :user_id, :question_id
    def initialize(options)
        @id = options['id']
        @user_id  = options['user_id']
        @question_id  = options['question_id']
    end

    def self.likers_for_question_id(question_id)
        likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT
            users.*
        FROM
            users
        JOIN
            question_likes ON users.id = user_id
        WHERE
            question_id = ?
        SQL
        return nil if likers.empty?
        likers.map { |liker| User.new(liker) }
    end

    def self.num_likes_for_question_id(question_id)
        likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT
            COUNT(*) AS 'Number Of Likes'
        FROM
            questions
        JOIN
            question_likes ON questions.id = question_likes.question_id
        WHERE
            question_id = ?
        SQL
    end

    def self.liked_questions_for_user_id(user_id)
        liked_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
        SELECT
            questions.*
        FROM
            questions
        JOIN
            question_likes ON questions.id = question_likes.question_id
        WHERE
            question_likes.user_id = ?
        SQL
        return nil if liked_questions.empty?
        liked_questions.map { |question| Question.new(question) }
    end

    def self.most_liked_questions(n)
        questions = QuestionsDatabase.instance.execute(<<-SQL, n)
        SELECT
            questions.*
        FROM
            questions
        JOIN
            question_likes ON questions.id = question_likes.question_id
        GROUP BY
            questions.id
        ORDER BY
            COUNT(*) DESC
        LIMIT
            ?
        SQL
        return nil if questions.empty?
        questions.map { |question| Question.new(question) }
    end
end