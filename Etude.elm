import Html exposing (Html, div, text, input, p, button)
import Html.Events exposing (onInput)
import Html.App as App

main =
  App.beginnerProgram { model = init, update = update, view = view }

-- MODEL

type alias Model =
  { currentAnswer : String
  , marks : Int
  }

init : Model
init =
  { currentAnswer = ""
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
  ChangeCurrentAnswer String

update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangeCurrentAnswer newAnswer ->
      let
        updatedCurrentAnswerModel =
          { model | currentAnswer = newAnswer }
      in
        { updatedCurrentAnswerModel | marks = pointValue updatedCurrentAnswerModel }

-- VIEW

getAnswer : Model -> String
getAnswer { currentAnswer } = currentAnswer

correctnessMessage : Model -> String
correctnessMessage model =
  if isCorrect model then
    "Correct"
  else
    "Incorrect"

view : Model -> Html Msg
view model =
  div []
    [ p [] [text "What's 1 + 1 ?"]
    , p [] [input [onInput ChangeCurrentAnswer] []]
    , p [] [text (" " ++ correctnessMessage model ++ ". ")]
    , p [] [text (" Points: " ++ toString (pointValue model))]]

