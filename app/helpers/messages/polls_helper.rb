module Messages::PollsHelper
  def poll_choice_percentage(choice)
    if (total_answers = choice.poll.answers.count) > 0
      number_to_percentage(choice.answers.count * 100.0 / total_answers, precision: 0)
    end
  end
end
