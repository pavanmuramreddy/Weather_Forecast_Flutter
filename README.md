# Flutter Weather Forecast App 🌦️

A simple and clean weather forecast application built with Flutter. It displays the current weather and a 7-day forecast for any city, featuring a responsive UI that works on different screen sizes.

## Features

-   **Current Weather:** Get real-time temperature, weather description, humidity, and wind speed.
-   **7-Day Forecast:** View the weather forecast for the next seven days.
-   **City Search:** Search for any city in the world to get its weather information.
-   **Responsive UI:** The layout adapts smoothly to both mobile and web screen sizes.
-   **Pull to Refresh:** Easily update the weather data by pulling down on the screen.

## Screenshots

<img width="1023" height="636" alt="image" src="https://github.com/user-attachments/assets/a0e94215-c4c0-4af1-b369-86ab138f257d" />


| Current Weather      | 7-Day Forecast      |
| -------------------- | ------------------- |
| ![Current Weather](https://placehold.co/300x600/e0f7fa/00695c?text=Current+Weather) | ![7-Day Forecast](https://placehold.co/300x600/e0f2f1/004d40?text=7-Day+Forecast) |

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0.0 or higher)
-   A code editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)

### Installation

1.  **Clone the repository:**
    ```sh
    git clone [https://github.com/YOUR_USERNAME/flutter_weather_app.git](https://github.com/YOUR_USERNAME/flutter_weather_app.git)
    ```

2.  **Navigate to the project directory:**
    ```sh
    cd flutter_weather_app
    ```

3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

4.  **Set up your API Key:**
    -   Get a free API key from [OpenWeatherMap](https://openweathermap.org/api).
    -   Open the file `lib/main.dart`.
    -   Find the following line:
        ```dart
        const String API_KEY = 'YOUR_OPENWEATHERMAP_API_KEY';
        ```
    -   Replace `'YOUR_OPENWEATHERMAP_API_KEY'` with the key you obtained.

5.  **Run the app:**
    ```sh
    flutter run
    ```

## Tech Stack & Packages

-   **Framework:** [Flutter](https://flutter.dev/)
-   **Language:** [Dart](https://dart.dev/)
-   **Packages:**
    -   `http`: For making API requests to the OpenWeatherMap service.
    -   `intl`: For formatting dates in the forecast.

