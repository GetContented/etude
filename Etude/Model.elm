module Etude.Model exposing
  (Model, Answer, Question, init, allExercises, Exercise, pointValue, updateCurrentExercise,
   isCorrect, correctTally, attemptTally, applyToCurrentExerciseWithDefault)

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

correctTally : Model -> Int
correctTally { exercises } =
  List.sum <| List.map .correctCount exercises

attemptTally : Model -> Int
attemptTally { exercises } =
  List.sum <| List.map .attemptCount exercises

getCorrectAnswer : Model -> Answer
getCorrectAnswer model =
  applyToCurrentExerciseWithDefault model "" .answer

applyToCurrentExerciseWithDefault : Model -> a -> (Exercise -> a) -> a
applyToCurrentExerciseWithDefault model default f =
  let
    maybeCurrentExercise =
      getMaybeCurrentExercise model
    maybeResult = Maybe.map f maybeCurrentExercise
  in
    Maybe.withDefault default maybeResult

updateCurrentExercise : Model -> (Exercise -> Exercise) -> Model
updateCurrentExercise model updater =
  case getMaybeCurrentExercise model of
    Nothing ->
      model
    Just exercise ->
      let
        updatedExercise = updater exercise
        exercisesTail = List.drop 1 model.exercises
      in
        { model | exercises = updatedExercise :: exercisesTail }


getMaybeCurrentExercise : Model -> Maybe Exercise
getMaybeCurrentExercise { exercises } =
  case exercises of
    [] ->
      Nothing
    exercise :: _ ->
      Just exercise

getAttempt : Model -> String
getAttempt { currentAttempt } = currentAttempt

isCorrect : Model -> Bool
isCorrect model =
  getAttempt model == getCorrectAnswer model

pointValue : Model -> Int
pointValue model =
  if isCorrect model then 1 else 0
