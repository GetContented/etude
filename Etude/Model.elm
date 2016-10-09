module Etude.Model exposing (Model, Answer, Question, init, allExercises, Exercise)

import List

-- MODEL

type alias Question = String
type alias Answer = String
type alias CorrectAnswer = Answer
type alias QAPair = (Question, Answer)

type alias Exercise =
  { question : Question
  , answer : Answer
  , correctCount : Int
  , attemptCount : Int
  }

type alias Model =
  { lastAttemptCorrect : Maybe Bool
  , currentAttempt : Answer
  , exercises : List Exercise
  }

init : Model
init =
  { lastAttemptCorrect = Nothing
  , currentAttempt = ""
  , exercises = allExercises
  }

allExercises : List Exercise
allExercises =
  List.map exerciseFromQAPair generatedQAPairs

exerciseFromQAPair : QAPair -> Exercise
exerciseFromQAPair (question, answer) =
  { exerciseInit
  | question = question
  , answer = answer
  }

generatedQAPairs : List QAPair
generatedQAPairs =
  let
    range =
      [1..20]
    permutationPairs =
      List.concatMap (\num -> List.map ((,) num) range) range
  in
    List.map
      (\(num1, num2) ->
        (toString num1 ++ " + " ++ toString num2, toString (num1 + num2)))
      permutationPairs

exerciseInit : Exercise
exerciseInit =
  { question = ""
  , answer = ""
  , correctCount = 0
  , attemptCount = 0
  }
