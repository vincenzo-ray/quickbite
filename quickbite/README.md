# QuickBite 🍲

**QuickBite** is a Flutter application designed to help users quickly find recipes based on the ingredients they have on hand. The app offers a simple and intuitive interface where users can enter ingredients, browse recipes that match their ingredients, view detailed recipe instructions, and filter recipes based on dietary preferences. QuickBite is perfect for college students, busy professionals, or anyone looking to reduce food waste and make meal preparation more convenient.

## Features
- **Ingredient-based Search**: Enter available ingredients, and QuickBite suggests recipes that can be made with them.
- **Recipe List**: View a list of suggested recipes with a summary of required and missing ingredients.
- **Detailed Recipe Information**: See nutritional information, cooking instructions, and images for each recipe.
- **Easy Navigation**: Navigate between search, results, and detailed recipe screens seamlessly.
- **Interactive UI Elements**: Includes informational dialogs and search bars for an improved user experience.

## Project Structure
The project is structured with a main directory (`lib/`) containing the app’s core files. Here’s an overview of each primary file and its purpose:

### 1. `lib/main.dart`
   - **Description**: The entry point of the QuickBite application. It initializes the app and sets up the root widget.
   - **Purpose**: Manages global application settings and launches the `HomeScreen` as the initial screen.

### 2. `lib/models/recipe.dart`
   - **Description**: Defines the `Recipe` model, which represents individual recipes with essential fields such as `id`, `title`, `imageUrl`, `usedIngredientCount`, and `missedIngredientCount`.
   - **Purpose**: Serves as the data structure for storing and accessing recipe information across the app.

### 3. `lib/screens/home_screen.dart`
   - **Description**: The main screen where users start by entering ingredients they have at home.
   - **Purpose**: Provides a user-friendly interface for inputting ingredients and beginning the recipe search process.

### 4. `lib/screens/recipe_list_screen.dart`
   - **Description**: Displays a list of recipes that match the entered ingredients. Each list item shows a recipe image, title, and count of used ingredients.
   - **Purpose**: Allows users to browse the search results and select a recipe for more details.

### 5. `lib/screens/recipe_detail_screen.dart`
   - **Description**: Shows detailed information about a selected recipe, including nutritional facts, cooking instructions, and an image.
   - **Purpose**: Provides an in-depth view of each recipe, helping users follow the instructions to prepare their meals.

### 6. `lib/screens/recipe_results_screen.dart`
   - **Description**: Manages the backend process of fetching recipes from the Spoonacular API based on the provided ingredients.
   - **Purpose**: Facilitates the API call to fetch recipe data and displays a loading indicator or error message as needed.

### 7. `lib/services/api_services.dart`
   - **Description**: Handles communication with the Spoonacular API for searching recipes by ingredients and fetching recipe details.
   - **Purpose**: Acts as a bridge between the app and the external API, enabling data fetching and ensuring the app displays up-to-date recipe information.

### 8. `lib/widgets/info_dialog.dart`
   - **Description**: A reusable widget that shows informational dialogs, helping users understand various app features.
   - **Purpose**: Enhances the user experience by providing additional guidance and app usage tips.

### 9. `lib/widgets/search_bar.dart`
   - **Description**: A custom search bar widget where users enter ingredients for searching recipes.
   - **Purpose**: Simplifies ingredient entry and creates a clean, intuitive search experience.

## How to Run the Project
To run QuickBite on your local machine:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/quickbitev2.git
   cd quickbitev2