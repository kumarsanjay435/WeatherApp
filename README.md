# Weather APP

![SimulatorScreenRecording-iPhone15Pro-2024-06-13at23 59 18-ezgif com-video-to-gif-converter (2)](https://github.com/kumarsanjay435/WeatherApp/assets/3499242/9ad5f84e-99d8-421b-bd56-cb63beeb5de9)


## Intro

A MVVM + Coordinator pattern used to develop this app. 

Swift Version : 5
Developed on iOS 17
Used APis in General : 
  --- Async/ Await while making network calls. Combine subscriber/ publisher for location manager updates and where ever necessary in binding.

### There are two screens **WeatherView** & **SearchLocationView**. 

#### Assumption : User has to provide the location services permission to see the current location temperature and also to navigate to the location search screen.

### Screen 1 -> **WeatherView** 
--- Location permission prompts to the user once after installing the app and based on response further flow unfolds :
1. Once location obtained a call to the open weather api made to show temperature
2. Otherwise an respective error messages are shown based on which part of the flow gave an error
3. Try again button added in case there is a need. Otherwise location updates are observed to make the flow unfolds from error state to location/weather loaded state 

### Screen 2 -> **SearchLocationView**
--- SearchBar component and a searched results with a deafult max limit of 8 repsones for a particular geocoding query/requests has been used.
1. Selecting an option pop back flow to the first screen with selected Location and weather/temperature is fecthed again to show custom location temperature.
2. Animation for search bar to expand and collapse with a close button in expanded state added.

## Services
### WeatherService & GeoCodingService : 
#### Models used to decode the response are kept close to Netwrok & Service layer and further mapped to ViewModels own state data to avoid having coupled Models.
#### This way changes can be made to the Newtwork and service side without changing anything to the Views & ViewModels.

### Location Manager
#### Separate manager class to handle location delegate and once location is obtained it publishes the response to subscriber in WeatherViewModel 

## Dark/Light Mode
  -- Background and Colors Adjusted to support Modes. Could be extended to a full fledged theme support.
  
## Temperature Units support
  -- Client side logic : User can tap on temperature to toggle it between celcius and Fareheit. 
  -- Although API layer is configurable and supports providing temperature unit in the requests to fetch temperature for a particular unit.
  -- It is not wise to call api again to show other temperature units rather a local logic is used to convert between celcius and Fareheit.


## Unit Tests:
  -- Tests for View Models
  -- Mocked Previews for views 

### Improvement Scope
1. Swift 6 support and warning resolution
2. Centeralised Theme can be added for the views
3. Integration tests & UI tests 
4. Move Common logic to SPM module
5. More Weather elements can used for the Weather screen and not just the temperature. 

