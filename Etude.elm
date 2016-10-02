import Html exposing (Html, div, text, input, p, button)
import Html.Events exposing (onInput, onClick)
import Html.App as App

main =
  App.beginnerProgram { model = init, update = update, view = view }

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

init : Model
init =
  { lastAnswerCorrect = Nothing
  , currentAnswer = ""
  , marks = 0
  , attempts = 0
  , questionsWithCorrectAnswers = [("1 + 1", "2")]
  }

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
         | SubmitAnswer

update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangeCurrentAnswer newAnswer ->
      { model | currentAnswer = newAnswer }
    SubmitAnswer ->
      { model
      | lastAnswerCorrect = Just (isCorrect model)
      , attempts = model.attempts + 1
      , marks = model.marks + pointValue model
      , questionsWithCorrectAnswers = moveHeadToEnd model.questionsWithCorrectAnswers
      }

moveHeadToEnd : List QuestionAndCorrectAnswer -> List QuestionAndCorrectAnswer
moveHeadToEnd list =
  case list of
    [] -> []
    head :: tail ->
      tail ++ [head]

-- VIEW

correctnessMessage : Model -> String
correctnessMessage model =
  case model.lastAnswerCorrect of
    Nothing -> "No Answers yet"
    Just True -> "Correct"
    Just False -> "Incorrect"

view : Model -> Html Msg
view model =
  div []
    [ p [] [text "What's 1 + 1 ?"]
    , p [] [ input [onInput ChangeCurrentAnswer] []
           , button [onClick SubmitAnswer] [text "Submit Answer"]
           ]
    , p [] [text (" " ++ correctnessMessage model ++ ". ")]
    , p [] [text (" Points: " ++ toString model.marks ++ " out of " ++ toString model.attempts)]]

