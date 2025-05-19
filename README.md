# visits_tracker

This challenge is part of the technical evaluation for a Flutter engineering role. It allows a sales representative to view, add, and manage customer visits, track activities during visits, and visualize key statistics, with an offline consideration.


## Screenshots

![visit list](https://github.com/user-attachments/assets/a03ccb21-931b-472b-8f94-b9a5faf1aa35)
![visit detail](https://github.com/user-attachments/assets/2e9ce6b4-babe-4f27-ab2f-119393ccf1e2)
![successful sync](https://github.com/user-attachments/assets/9e772bd9-0c7c-4787-8f60-98f541b5a7dd)
![stats](https://github.com/user-attachments/assets/805e6b39-093d-47b6-add7-f50933bea5f3)
![search filter](https://github.com/user-attachments/assets/a334ca2c-9524-4057-8dcf-183dbd4493ca)
![saved offline](https://github.com/user-attachments/assets/6e250669-3afc-413d-9b67-08f5d5bb713d)
![offline in list](https://github.com/user-attachments/assets/e74c3363-2eb0-416f-982c-8e49e66fbd0d)
![add visit](https://github.com/user-attachments/assets/f7db616a-eb08-43e9-adcc-8c3cb50b7d14)

## Features

- View a list of customer visits (online & offline)
- Add a new visit using a clean, validated form
- Store visits offline and sync later
- Sync button for unsynced visits
- Search visits by customer ID, status, or location
- View visit details including activities performed during visit
- View statistics (by date, customer, location)
- Line chart of visits per customer over time
- Bottom navigation bar with centered FAB for adding visits

## Setup

1. **Clone the repository:**
2. **Install Dependencies:**
   flutter pub get
3. **Run App:**
   flutter run

## Architecture, Approach, and Scalability

The folder structure supports seperation of concerns

![image](https://github.com/user-attachments/assets/0e14f81b-09ac-4072-aab9-f833b444e47a)

- **State Management**: `Riverpod` for scalable, testable state control
- **Navigation**: `GoRouter` with `ShellRoute` to support bottom navigation and modular routing
- **Offline Support**: `SharedPreferences` to store visits locally and syncing later
- **Charting**: `fl_chart` for rendering statistical visit data
- **Scalability**: Folder structure with separation of concerns: models, services, UI, and logic layers

## User Experience Enhancements

1. Used different colors for different statuses to easily identify and differenciate states
2. Bottom Navigation bar for easy movement
3. Simple, intuitive UI

## Notes on offline support, testing, or CI if implemented

1. Visits can be added offline and stored locally

2. Offline visits have a sync icon which onPressed, with internet, get synced, replacing the icon with a cloud icon

3. After syncing, offline visits are posted to the API and removed from local storage

   **Testing and CI:**
   No tests were written due to time constraints but can be improved with Unit Tests for logic and models, and Widget tests for UI rendering

## Assumptions, trade-offs, or limitations

1. Manual sync instead of auto sync every n seconds
2. No user app authentication
