import Html exposing (Html, div, text, input, p, button)
import Html.Events exposing (onInput, onClick)
import Html.App as App
import Random

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
  , marks : Int
  , attempts : Int
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
      , marks = 0
      , attempts = 0
      , exercises = exercises
      }, shuffleExercises exercisesLength)

generatedQAPairs : List QAPair
generatedQAPairs =
  let
    range =
      [1..30]
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

reorderedListWithNewIndexes : List a -> List Int -> List a
reorderedListWithNewIndexes items indexes =
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
        , exercises = rotateList model.exercises
        }
      in
        (updatedModel, Cmd.none)
    ShuffleExercises ->
      let
        questionCount = List.length model.exercises
      in
        (model, shuffleExercises questionCount)
    UpdateExercisesOrder newIndexes ->
      let
        reorderedExercises =
          reorderedListWithNewIndexes model.exercises newIndexes
      in
        ({ model | exercises = reorderedExercises }, Cmd.none)


rotateList : List a -> List a
rotateList list =
  case list of
    [] -> []
    head :: tail ->
      tail ++ [head]


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
    , p [] [text (" Points: " ++ toString model.marks ++ " out of " ++ toString model.attempts)]]

correctnessMessage : Model -> String
correctnessMessage model =
  case model.lastAttemptCorrect of
    Nothing -> "No Attempts yet"
    Just True -> "Correct"
    Just False -> "Incorrect"

getQuestion : Model -> Answer
getQuestion model =
  applyToCurrentExerciseWithDefault model "" .question
