require 'open-uri'
require 'json'

class LongestwordController < ApplicationController
  def game
    @letter_grid = []
    counter = 0
    @start_time = Time.now
    while counter < 15
      @letter_grid << [*('A'..'Z')].sample
      counter += 1
    end
  end

  def score
    @attempt = params[:query]
    @start_time = Time.parse(params[:time])
    @letter_grid = JSON.parse(params[:grid])
    @end_time = Time.now
    # raise
    @result = run_game(@attempt, @letter_grid, @start_time, @end_time)
  end

  private

  def is_letter_in_grid? (grid, attempt)
    attempt.upcase.split("").each do |letter|
      if attempt.upcase.split("").count(letter) > grid.count(letter)
        return false
      end
    end
    return true
  end

  def english_word? (attempt)
    file_path = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
    open(file_path) do |stream|
      if JSON.parse(stream.read)["term0"]
        return true
      else
        return false
      end
    end
  end

  def as_translation (attempt)
    file_path = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
    open(file_path) do |stream|
      if english_word?(attempt) == true
        return true
      else
        return false
      end
    end
  end

  def run_game(attempt, grid, start_time, end_time)
# Runs the game and return detailed hash of result
    result = {}
    result[:time] = (end_time - start_time)
    file_path = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"

    open(file_path) do |stream|
      if (is_letter_in_grid?(grid, attempt) && english_word?(attempt)) == true
        result[:translation] = JSON.parse(stream.read)["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
        result[:score] = 10
        result[:message] = "Well done dude"
      elsif is_letter_in_grid?(grid, attempt) == false
        result[:message] = "DON'T USE OTHER LETTER FUCKING IDIOT !"
        result[:score] = 0

      elsif english_word?(attempt) == false
        result[:message] =  "this word is not an english word ! Dum ass your score is NIL !"
        result[:score] = 0

      end
    end
    return result
  end

end
