Article List

An iOS app built with Swift and powered by the MVVMC (Model–View–ViewModel–Coordinator) architecture, showcasing modern Swift Concurrency (async/await), clean navigation flows, and scalable modular design.

Features
Fetches and displays dynamic data from a remote API
Search & filtering support for quick access to relevant content
Pull-to-refresh for real-time updates
Graceful error handling with user-friendly alerts and retry options
Image loading and caching using Swift concurrency (async/await)
Separation of concerns with MVVMC for clean, testable code
A Tab Bar Controller for easy navigation between modules (e.g., Articles, Countries, etc.)
Coordinator-driven navigation (no storyboard segues, fully programmatic flow)

Architecture
The app follows MVVMC:
Model → Defines data structures (e.g., Article, Country, User, etc.)
View → UIKit-based UI (e.g., ArticleTableViewCell, CountryTableViewCell)
ViewModel → Business logic, state management, and API interaction (e.g., ArticleViewModel, CountryViewModel)
Coordinator → Orchestrates navigation and dependency injection across modules
Controller → Handles lifecycle, binds ViewModels to Views, and delegates user actions

Additionally:
UITabBarController organizes major modules into a clear, intuitive interface.
Dependency Injection is used for better testability and loose coupling.

Updated with latest Concurrency with Async/Await
The project uses Swift’s modern concurrency system:
async/await for clear, sequential API calls
Task {} for bridging async work inside sync contexts (e.g., viewDidLoad)
Task.sleep(for:) to manage timing/delays for loaders and animations

Structured concurrency for predictable, cancelable background work
<img width="1220" height="996" alt="image" src="https://github.com/user-attachments/assets/169a1e49-2ba1-499d-9b82-6dc443a975d0" />
<img width="1366" height="980" alt="image" src="https://github.com/user-attachments/assets/c89caa3a-1cb1-441e-9f2f-2f4aed81c9c1" />
<img width="1276" height="880" alt="image" src="https://github.com/user-attachments/assets/239a82ef-9020-4b67-9761-af4354261985" />
