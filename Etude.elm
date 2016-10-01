import Html exposing (Html, div, text, input)
import Html.Events exposing (onInput)
import Html.App as App

main =
  App.beginnerProgram { model = model, update = update, view = view }

-- MODEL

type alias Model =
  { answer : Maybe String }

model : Model
model =
  { answer = Just "" }

-- UPDATE

type Msg = NoOp

update : Msg -> Model -> Model
update _ model = model

-- VIEW

view : Model -> Html Msg
view _ =
  div []
    [ text "What's 1 + 1 ?"
    , input [onInput (always NoOp)] []
    ]

