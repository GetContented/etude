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

view : Model -> Html Msg
view model =
  div []
    [ text "What's 1 + 1 ?"
    , input [onInput ChangeAnswer] []
    , text (getAnswer model)]

