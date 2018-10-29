module Main exposing (Model, Msg(..), TrackingType(..), init, main, modelValidator, radio, update, view, viewErrors, viewInput, viewTrackingTypePicker)

import Base64
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Validate exposing (Validator, ifBlank, ifNotInt, ifFalse, validate)


main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }



-- MODEL


type TrackingType
    = AppTracking
    | DeviceTracking


type alias Model =
    { username : String
    , password : String
    , users : String
    , trackingType : TrackingType
    , measurementDays : String
    , errors : List String
    , link : String
    }


init : Model
init =
    Model "" "" "" AppTracking "" [] ""


-- UPDATE


type Msg
    = NoOp
    | Username String
    | Password String
    | Users String
    | TrackingType TrackingType
    | MeasurementDays String
    | CreateLink


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        Username newUsername ->
            { model | username = newUsername }

        Password newPassword ->
            { model | password = newPassword }

        Users newUsers ->
            { model | users = newUsers }

        TrackingType newTrackingType ->
            { model | trackingType = newTrackingType }

        MeasurementDays newMeasurementDays ->
            { model | measurementDays = newMeasurementDays }

        CreateLink ->
            case validate modelValidator model of
                Err errors ->
                    { model | errors = errors }

                Ok _ ->
                    { model | link = mkSetupLink model, errors = [] }



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ h1 [] [ text "Opret Setuplink" ]
        , div []
            [ viewInput "text" "Brugernavn" model.username Username
            , viewInput "text" "Kodeord" model.password Password
            , viewInput "number" "Antal måledage" model.measurementDays MeasurementDays
            , viewInput "text" "Brugere (separeret med komma)" model.users Users
            , viewTrackingTypePicker model
            , button [ onClick CreateLink ] [ text "Opret Link" ]
            ]
        , viewErrors model.errors
        , viewLink model.link
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewTrackingTypePicker : Model -> Html Msg
viewTrackingTypePicker model =
    fieldset [ class "radio-group" ]
        [ h3 [] [ text "Tracking type:" ]
        , radio "App" (model.trackingType == AppTracking) (TrackingType AppTracking)
        , radio "Tid" (model.trackingType == DeviceTracking) (TrackingType DeviceTracking)
        ]

radio : String -> Bool -> Msg -> Html Msg
radio name isChecked msg =
    label [ class "container" ]
        [ text name
        , input [ class "checkbox", type_ "radio", onClick msg, checked isChecked ] []
        , span [ class "checkmark" ] []
        ]

viewErrors : List String -> Html Msg
viewErrors errors =
    ul [ class "errors" ] <| List.map (\e -> li [] [ text e ]) errors


viewLink : String -> Html Msg
viewLink link =
    case String.isEmpty link of
        True -> p [] []
        False -> code [class "generated-link"] [text link]




-- HELPERS
-- Validation


modelValidator : Validator String Model
modelValidator =
    Validate.all
        [ ifBlank .username "Indtast et brugernavn."
        , ifBlank .password "Indtast et kodeord."
        , ifNotInt .measurementDays (\_ -> "Indtast et antal måledage.")
        , ifBlank .users "Indtast en liste af brugere (separaret med komma)."
        ]

-- Link generation
mkSetupLink : Model -> String
mkSetupLink model =
    let 
        jsonData = "{ \"username\": \"" ++ model.username  ++ "\"" ++
                   ", \"password\": \"" ++ model.password  ++ "\"" ++
                   ", \"users\": \"[" ++ model.users  ++ "]\"" ++
                   ", \"tracking_type\": \"" ++ (trackingTypeToString model.trackingType) ++ "\"" ++
                   ", \"measurement_days\": \"" ++ model.measurementDays  ++ "\" }"
        encodedData = Base64.encode(jsonData)
    in 
        "sdutracker://?data=" ++ encodedData

trackingTypeToString : TrackingType -> String
trackingTypeToString tType = 
    case tType of
        DeviceTracking -> "0"
        AppTracking -> "1"