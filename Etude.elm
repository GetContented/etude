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
type alias QuestionAndCorrectAnswer = (Question, CorrectAnswer)

type alias Model =
  { lastAnswerCorrect : Maybe Bool
  , currentAnswer : Answer
  , marks : Int
  , attempts : Int
  , questionsWithCorrectAnswers : List QuestionAndCorrectAnswer
  }

init : (Model, Cmd Msg)
init =
  let
    qaPairs =
      generatedQAPairs
    questionsLength =
      List.length generatedQAPairs
  in
    ({ lastAnswerCorrect = Nothing
      , currentAnswer = ""
      , marks = 0
      , attempts = 0
      , questionsWithCorrectAnswers = qaPairs
      }, shuffleQuestions questionsLength)

generatedQAPairs : List QuestionAndCorrectAnswer
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


getCorrectAnswer : Model -> Answer
getCorrectAnswer { questionsWithCorrectAnswers } =
  case questionsWithCorrectAnswers of
    [] ->
      ""
    (_, correctAnswer) :: _ ->
      correctAnswer

getAnswer : Model -> String
getAnswer { currentAnswer } = currentAnswer

isCorrect : Model -> Bool
isCorrect model =
  getAnswer model == getCorrectAnswer model

pointValue : Model -> Int
pointValue model =
  if isCorrect model then 1 else 0

-- UPDATE

type Msg = ChangeCurrentAnswer String
         | ShuffleQuestions
         | SubmitAnswer
         | UpdateQuestionsOrder (List Int)

shuffleQuestions : Int -> Cmd Msg
shuffleQuestions questionCount =
  Random.generate UpdateQuestionsOrder (Random.list questionCount (Random.int 0 questionCount))

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
    ChangeCurrentAnswer newAnswer ->
      ({ model | currentAnswer = newAnswer }, Cmd.none)
    SubmitAnswer ->
      ({ model
       | lastAnswerCorrect = Just (isCorrect model)
       , attempts = model.attempts + 1
       , marks = model.marks + pointValue model
       , questionsWithCorrectAnswers = moveHeadToEnd model.questionsWithCorrectAnswers
       }, Cmd.none)
    ShuffleQuestions ->
      let
        questionCount = List.length model.questionsWithCorrectAnswers
      in
        (model, shuffleQuestions questionCount)
    UpdateQuestionsOrder newIndexes ->
      let
        reorderedQuestions =
          reorderedListWithNewIndexes model.questionsWithCorrectAnswers newIndexes
      in
        ({ model | questionsWithCorrectAnswers = reorderedQuestions }, Cmd.none)


moveHeadToEnd : List QuestionAndCorrectAnswer -> List QuestionAndCorrectAnswer
moveHeadToEnd list =
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
    , p [] [ input [onInput ChangeCurrentAnswer] []
           , button [onClick SubmitAnswer] [text "Submit Answer"]
           ]
    , p [] [text (" " ++ correctnessMessage model ++ ". ")]
    , p [] [text (" Points: " ++ toString model.marks ++ " out of " ++ toString model.attempts)]]

correctnessMessage : Model -> String
correctnessMessage model =
  case model.lastAnswerCorrect of
    Nothing -> "No Answers yet"
    Just True -> "Correct"
    Just False -> "Incorrect"

getQuestion : Model -> Answer
getQuestion { questionsWithCorrectAnswers } =
  case questionsWithCorrectAnswers of
    [] ->
      ""
    (question, _) :: _ ->
      question
