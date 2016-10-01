import Html exposing (Html, div, text, input)
import Html.Events exposing (onInput)
import Html.App as App

main =
  App.beginnerProgram { model = init, update = update, view = view }

-- MODEL

type alias Model =
  { answer : Maybe String }

init : Model
init =
  { answer = Just "" }

-- UPDATE

type Msg =
  ChangeAnswer String

update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangeAnswer newAnswer ->
      { model | answer = Just newAnswer }

-- VIEW

getAnswer : Model -> String
getAnswer { answer } =
  Maybe.withDefault "" answer


view : Model -> Html Msg
view model =
  div []
    [ text "What's 1 + 1 ?"
    , input [onInput ChangeAnswer] []
    , text (getAnswer model)]

