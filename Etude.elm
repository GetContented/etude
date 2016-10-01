import Html exposing (Html, div, text, input, p, button)
import Html.Events exposing (onInput, onClick)
import Html.App as App

main =
  App.beginnerProgram { model = init, update = update, view = view }

-- MODEL

type alias Model =
  { lastAnswerCorrect : Maybe Bool
  , currentAnswer : String
  , marks : Int
  , attempts : Int
  }

init : Model
init =
  { lastAnswerCorrect = Nothing
  , currentAnswer = ""
  , marks = 0
  , attempts = 0
  }

correctAnswer : String
correctAnswer = "2"

isCorrect : Model -> Bool
isCorrect model =
  getAnswer model == correctAnswer

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
      , marks = model.marks + pointValue model }

-- VIEW

getAnswer : Model -> String
getAnswer { currentAnswer } = currentAnswer

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

