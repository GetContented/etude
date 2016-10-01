import Html exposing (Html, div, text, input)
import Html.Events exposing (onInput)
import Html.App as App

main =
  App.beginnerProgram { model = init, update = update, view = view }

-- MODEL

type alias Model =
  { answer : String }

init : Model
init =
  { answer = "" }

correctAnswer : String
correctAnswer = "2"

-- UPDATE

type Msg =
  ChangeAnswer String

update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangeAnswer newAnswer ->
      { model | answer = newAnswer }

-- VIEW

getAnswer : Model -> String
getAnswer { answer } = answer

correctnessMessage : Model -> String
correctnessMessage model =
  if getAnswer model == correctAnswer then
    "Correct"
  else
    "Incorrect"

view : Model -> Html Msg
view model =
  div []
    [ text "What's 1 + 1 ?"
    , input [onInput ChangeAnswer] []
    , text (correctnessMessage model)]

