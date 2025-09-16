# MovieVault-App
MovieVault is an iOS app built with SwiftUI + MVVM architecture that fetches and displays movies (trending, now playing, search, details) from an external API (TMDB). It also includes Core Data to save favourite/saved movies.

- [ ] Coding Approach
* Architecture: MVVM (Models + ViewModels + SwiftUI Views).
* Networking: Centralised TMDBClient + Router for clean endpoint handling.
* Data Persistence: Core Data used for saving favourite movies.
* UI: SwiftUI with @StateObject + @ObservedObject for reactive updates.
* Error Handling: Errors stored in errorMessage (ViewModel) → displayed in UI.
* Async Loading: ImageLoader + @Published isLoading states in ViewModels.

- [ ] How Code is Written (Style & Practices)
* Uses Swift concurrency (async/await) for API calls.
* Separates concerns (Networking, Persistence, Repository, ViewModels, Views).
* Uses dependency injection for repositories into ViewModels.
* Clean SwiftUI code with state-driven updates.
* Reusable models & generic paged response handling.
* Proper error handling with optional messages.

- [ ] Workflow (Approach Summary)
* App starts → MainTabView loads.
* Home tab → Fetches trending & now playing movies (via HomeViewModel).
* Search tab → Calls API search endpoint (SearchViewModel).
* Saved tab → Loads Core Data favourites (SavedViewModel).
* Detail screen → Shows movie info with image + option to save/remove.
* Repository layer → Connects ViewModels to API/Core Data.
