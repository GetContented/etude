import Html exposing (Html, div, text, input, p, button)
import Html.Events exposing (onInput, onClick)
import Html.App as App
import Random
import List.Extra as LE

main =
  App.program
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

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

init : (Model, Cmd Msg)
init =
  let
    exercises =
      generatedExercises
    exercisesLength =
      List.length exercises
  in
    ({ lastAttemptCorrect = Nothing
      , currentAttempt = ""
      , exercises = exercises
      }, shuffleExercises exercisesLength)

correctTally : Model -> Int
correctTally { exercises } =
  List.sum <| List.map .correctCount exercises

attemptTally : Model -> Int
attemptTally { exercises } =
  List.sum <| List.map .attemptCount exercises

generatedQAPairs : List QAPair
generatedQAPairs =
  let
    range =
      [1..3]
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

exerciseFromQAPair : QAPair -> Exercise
exerciseFromQAPair (question, answer) =
  { exerciseInit
  | question = question
  , answer = answer
  }

generatedExercises : List Exercise
generatedExercises =
  List.map exerciseFromQAPair generatedQAPairs

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

sortByCorrectnessRatioThenIndexes : List Exercise -> List Int -> List Exercise
sortByCorrectnessRatioThenIndexes exercises indexes =
  let
    sortedExercises = sortByCorrectnessRatio exercises
    grouper x y =
      let
        xRatio = correctnessRatio x
        yRatio = correctnessRatio y
      in
        xRatio == yRatio
    exerciseGroups = LE.groupWhile grouper sortedExercises
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
