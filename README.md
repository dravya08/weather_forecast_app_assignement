# Weather Forecast App

This is a Flutter application that provides current weather details and a 5-day forecast for different locations. 

## Features

- Display current temperature, weather condition, and wind speed.
- Search for weather conditions in different locations.
- Toggle between Celsius and Fahrenheit.
- Toggle between Dark and Light themes.
- Smooth screen transitions and UI animations.

## Getting Started

Follow these steps to set up and run the app:

### Prerequisites

- Flutter SDK installed on your machine.
- An API key from OpenWeatherMap. [Get API Key](https://openweathermap.org/appid)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your_username/weather_forecast_app.git


2.Navigate to the project directory:
cd weather_forecast_app

3.Create a .env file in the root directory and add your OpenWeatherMap API key:
API_KEY=your_api_key_here

4.Install dependencies:
flutter pub get

5. Run the app:
flutter run


Assumptions and Decisions
The app uses GetX for state management, providing a clean and efficient way to handle state across the application.
Data is fetched from the OpenWeatherMap API, and the API key is kept secure using environment variables.
The UI is designed with a focus on user experience, including animations for smooth transitions between screens.
