# Flutter News App

A news application built with Flutter, following Clean Architecture and a feature-first approach,
utilizing Cubit for state management. The application provides user authentication alongside smooth
news browsing by fetching real-time data from REST APIs with local storage support for offline use.

## Core Features

- Clean Architecture implementation with a feature-first structure to separate layers and organize
  modules independently.
- User authentication (Sign up, Sign in, and session management).
- Utilization of Cubit for state management and reactive UI updates.
- REST API integration to fetch the latest articles, categories, and sources dynamically.
- Integration of SQFlite for local storage and caching data for offline usage.

## Tech Stack and Packages

- Framework: Flutter (Dart)
- Architecture: Clean Architecture (Feature-first)
- State Management: flutter_bloc / cubit
- Local Database: sqflite
- Networking: REST APIs
- Dependency Injection: get_it / injectable

## Project Structure

lib/

├── core/               
├── features/           
│ ├── authentication/   
│ ├── categories/        
│ ├── news/             
│ └── sources/          
│
└── main.dart           
