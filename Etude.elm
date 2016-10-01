import Html exposing (Html, div, text)
import Html.App as App

main =
  App.beginnerProgram { model = model, update = update, view = view }

-- MODEL

type Model = NoModel

model : Model
model = NoModel

-- UPDATE

type Msg = NoOp

update : Msg -> Model -> Model
update _ model = model

-- VIEW

view : Model -> Html Msg
view _ =
  div [] [text "Hello, world!"]
