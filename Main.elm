module Main exposing (main)

import Html exposing (Html, div, text, input, p, button)
import Html.Events exposing (onInput, onClick)
import Random
import List.Extra as LE
import Etude.Model as Model exposing
  (Model, allExercises, Answer, Exercise, pointValue, updateCurrentExercise,
   isCorrect, correctTally, attemptTally, applyToCurrentExerciseWithDefault)


main =
  Html.program
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

init : (Model, Cmd Msg)
init =
  let
    exercisesLength =
      List.length allExercises
  in
    (Model.init, shuffleExercises exercisesLength)

-- UPDATE

type Msg = ChangeCurrentAttempt String
         | ShuffleExercises
         | SubmitAttempt
         | UpdateExercisesOrder (List Int)

shuffleExercises : Int -> Cmd Msg
shuffleExercises questionCount =
  Random.generate UpdateExercisesOrder (Random.list questionCount (Random.int 0 questionCount))

reorderListByIndexes : List a -> List Int -> List a
reorderListByIndexes items indexes =
  let
    zippedItems =
      List.map2 (,) indexes items
    reorderedZip =
      List.sortBy (\(index, _) -> index) zippedItems
  in
    List.map (\(_, item) -> item) reorderedZip


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ChangeCurrentAttempt newAttempt ->
      ({ model | currentAttempt = newAttempt }, Cmd.none)
    SubmitAttempt ->
      let
        updateExercise exercise =
          { exercise
          | attemptCount = exercise.attemptCount + 1
          , correctCount = exercise.correctCount + pointValue model
          }
        modelWithUpdatedExercise = updateCurrentExercise model updateExercise
        updatedModel =
          { modelWithUpdatedExercise
          | lastAttemptCorrect = Just (isCorrect model)
          , exercises = rotateList modelWithUpdatedExercise.exercises
          }
        exerciseCount = List.length updatedModel.exercises
      in
        (updatedModel, shuffleExercises exerciseCount)
    ShuffleExercises ->
      let
        exerciseCount = List.length model.exercises
      in
        (model, shuffleExercises exerciseCount)
    UpdateExercisesOrder newIndexes ->
      let
        reorderedExercises =
          sortByCorrectnessRatioThenIndexes model.exercises newIndexes
      in
        ({ model | exercises = reorderedExercises }, Cmd.none)


rotateList : List a -> List a
rotateList list =
  case list of
    [] -> []
    head :: tail ->
      tail ++ [head]

correctnessRatio : Exercise -> Float
correctnessRatio exercise =
  if exercise.attemptCount == 0 then
    0
  else
    toFloat exercise.correctCount / toFloat exercise.attemptCount

sortByCorrectnessRatio : List Exercise -> List Exercise
sortByCorrectnessRatio exercises =
  List.sortBy correctnessRatio exercises

groupExercisesByCorrectnessRatio : List Exercise -> List (List Exercise)
groupExercisesByCorrectnessRatio exercises =
  let
    sortedExercises = sortByCorrectnessRatio exercises
    grouper x y =
      let
        xRatio = correctnessRatio x
        yRatio = correctnessRatio y
      in
        xRatio == yRatio
  in
    LE.groupWhile grouper sortedExercises

sortByCorrectnessRatioThenIndexes : List Exercise -> List Int -> List Exercise
sortByCorrectnessRatioThenIndexes exercises indexes =
  let
    exerciseGroups =
      groupExercisesByCorrectnessRatio exercises
    indexesAndExerciseGroups =
      List.foldr
        (\exerciseGroup (resultList, indexesRemaining) ->
          ((exerciseGroup, List.take (List.length exerciseGroup) indexesRemaining) :: resultList
          , List.drop (List.length exerciseGroup) indexesRemaining))
        ([], indexes)
        exerciseGroups
    exerciseGroupIndexesPairs =
      (\(x, _) -> x) indexesAndExerciseGroups
    reorderedExerciseGroups =
      List.map
        (\(exerciseGroup, indexes) ->
          reorderListByIndexes exerciseGroup indexes)
        exerciseGroupIndexesPairs
  in
    List.concat reorderedExerciseGroups


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ p [] [text ("Question: " ++ getQuestion model ++ "?")]
    , p [] [ input [onInput ChangeCurrentAttempt] []
           , button [onClick SubmitAttempt] [text "Submit Answer"]
           ]
    , p [] [text (" " ++ correctnessMessage model ++ ". ")]
    , p [] [text (" Points: " ++ toString (correctTally model) ++ " out of " ++ toString (attemptTally model))]]

correctnessMessage : Model -> String
correctnessMessage model =
  case model.lastAttemptCorrect of
    Nothing -> "No Attempts yet"
    Just True -> "Correct"
    Just False -> "Incorrect"

getQuestion : Model -> Answer
getQuestion model =
  applyToCurrentExerciseWithDefault model "" .question
