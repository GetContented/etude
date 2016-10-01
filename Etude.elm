import Html exposing (Html, div, text, input)
import Html.Events exposing (onInput)
import Html.App as App

main =
  App.beginnerProgram { model = init, update = update, view = view }

-- MODEL

type alias Model =
  { answer : String
  , marks : Int
  }

init : Model
init =
  { answer = ""
  , marks = 0
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

type Msg =
  ChangeAnswer String

update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangeAnswer newAnswer ->
      let
        updatedAnswerModel =
          { model | answer = newAnswer }
      in
        { updatedAnswerModel | marks = pointValue updatedAnswerModel }

-- VIEW

getAnswer : Model -> String
getAnswer { answer } = answer

correctnessMessage : Model -> String
correctnessMessage model =
  if isCorrect model then
    "Correct"
  else
    "Incorrect"

view : Model -> Html Msg
view model =
  div []
    [ text "What's 1 + 1 ?"
    , input [onInput ChangeAnswer] []
    , text (" " ++ correctnessMessage model ++ ". ")
    , text (" Points: " ++ toString (pointValue model))]

