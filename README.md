
# News Reader iOS App

## An iOS application to fetch, display, and manage news articles from a public API. The app supports offline caching, dynamic UI updates, bookmarks, pull to refresh, search, and dark/light mode.

## Features

- Fetch Articles

- Retrieves news articles from NewsAPI.org

- Displays article title, author, and thumbnail images.

- Offline Caching

- Articles are saved in Core Data for offline viewing.

- Bookmarks persist across app launches.

- Pull to Refresh

- Swipe down to refresh articles from the API.

- Handles offline state gracefully with cached data.

- Search Articles

- Search bar to filter articles by title or author.

- Bookmarks

- Tap the bookmark icon to save an article.

- View saved articles in the Bookmarks tab.

- Custom Tab Bar

- Bottom tab bar for Home and Bookmarks.

- Smooth selection animation and highlight.

- Dark/Light Mode

- Fully supports both modes using semantic colors and SF Symbols.


## Architecture

- MVVM (Model View ViewModel) for separation of concerns.

- Core Data for local caching and bookmarks.

- Clean and modular structure:

    - ViewControllers for UI

    - ViewModels for data management and logic

    - Services for API/network calls
    

## Libraries & Image Loading

### URLSession 

- All API calls and image loading are handled using URLSession.

- Images are fetched asynchronously and displayed in UIImageView without blocking the main thread.

- Offline caching of articles (and their image URLs) is handled via Core Data, but image caching is in-memory and not persisted.

Using URLSession keeps dependencies minimal while still providing async network calls and image loading.


## Setup Instructions

1. Clone the repository

- git clone <repository_url>
- cd Reader

2. Open Xcode project

open Reader.xcodeproj


3. Set API Key

Obtain an API key from NewsAPI.org

Replace the apiKey in NewsAPIService.swift:

private let apiKey = "YOUR_API_KEY_HERE"

4. Run the app on Simulator or Device.


## Usage

- Launch app → Home tab shows latest articles.

- Pull down to refresh articles.

- Tap search bar to filter articles.

- Tap bookmark icon to save an article.

- Switch to Bookmarks tab to view saved articles.

## Project Structure

```
NewsReader/
│
├─ Models/
│   └─ Article.swift
├─ ViewModels/
│   └─ ArticlesListViewModel.swift
├─ Views/
│   └─ ArticleCell.swift
├─ ViewControllers/
│   ├─ ArticlesViewController.swift
│   ├─ BookmarksViewController.swift
│   └─ MainViewController.swift
├─ Services/
│   └─ NewsAPIService.swift
├─ CoreData/
│   └─ CoreDataManager.swift
└─ CustomUI/
    └─ BMTabBarMenu.swift
```


## Screenshots
<img src="https://github.com/Debashish-hub/News-Reader/blob/main/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-09-16%20at%2022.30.30.png" alt="Alt Text" width="300" height="700"> <img src="https://github.com/Debashish-hub/News-Reader/blob/main/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-09-16%20at%2022.30.42.png" alt="Alt Text" width="300" height="700"> <img src="https://github.com/Debashish-hub/News-Reader/blob/main/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-09-16%20at%2022.33.51.png" alt="Alt Text" width="300" height="700"> <img src="https://github.com/Debashish-hub/News-Reader/blob/main/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-09-16%20at%2022.34.45.png" alt="Alt Text" width="300" height="700"> <img src="https://github.com/Debashish-hub/News-Reader/blob/main/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-09-16%20at%2022.34.51.png" alt="Alt Text" width="300" height="700"> <img src="https://github.com/Debashish-hub/News-Reader/blob/main/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-09-16%20at%2022.34.55.png" alt="Alt Text" width="300" height="700">

## Test Case

<img src="https://github.com/Debashish-hub/News-Reader/blob/main/testcases.png" alt="Alt Text" width="500" height="400">


## Notes / Future Improvements

- Add pagination to fetch more articles on scroll.

- Implement detailed article view with full content.

- Add notifications for trending news.

- Add badge counts on custom tab bar for new bookmarks.


## License

This project is open-source and available under the MIT License.
