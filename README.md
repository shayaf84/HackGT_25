# Heartifacts - Hack GT'25 Project

## Architecture Overview

### Core Entities & Roles

#### **Manager** - Controller Class
- **Purpose**: Central coordinator that orchestrates all data flow
- **Responsibilities**:
  - Fetches sleep data from Sleep class
  - Sends processed data to CuratorAI
  - Manages state with @Published properties
  - Coordinates between Sleep and CuratorAI
  - Handles UI updates through reactive bindings

#### **ContentView** - Single UI Class
- **Purpose**: The only UI component in the app
- **Responsibilities**:
  - Displays sleep data (REM, Deep, Core, Total, Awakenings, Sleep Score)
  - Shows AI curator messages
  - Handles user interactions
  - Uses Manager for all data access

#### **Sleep** - Data Model & Processor
- **Purpose**: Handles all sleep data processing and HealthKit integration
- **Responsibilities**:
  - Requests HealthKit authorization
  - Fetches raw sleep data from HealthKit
  - Processes sleep samples (REM, Deep, Core, Awakenings)
  - Calculates sleep score
  - Returns structured SleepData to Manager

#### **CuratorAI** - AI Service
- **Purpose**: Generates encouraging messages based on sleep data
- **Responsibilities**:
  - Receives processed sleep data from Manager
  - Generates AI messages using OpenAI API
  - Returns encouraging messages to Manager
  - **Does NOT** fetch data directly

## Data Flow Architecture

```
ContentView (UI) → Manager (Controller) → Sleep (data) + CuratorAI (message)
```

### Detailed Flow:
1. **ContentView** requests data from **Manager**
2. **Manager** calls **Sleep** class to fetch and process HealthKit data
3. **Sleep** class returns processed `SleepData` to **Manager**
4. **Manager** sends sleep data to **CuratorAI** for message generation
5. **CuratorAI** returns AI message to **Manager**
6. **Manager** combines sleep data + AI message
7. **ContentView** displays both sleep data and AI message

## Key Design Principles

### **Single Responsibility**
- Each class has one clear purpose
- Manager coordinates, Sleep processes data, CuratorAI generates messages, ContentView displays

### **Clean Separation of Concerns**
- **Sleep**: Only handles HealthKit data processing
- **CuratorAI**: Only generates AI messages (no data fetching)
- **Manager**: Only coordinates between components
- **ContentView**: Only handles UI display

### **Single UI Class**
- Only ContentView exists for UI
- No multiple view classes
- All UI logic centralized in one place

### **Reactive Architecture**
- Manager uses @Published properties for reactive UI updates
- ContentView automatically updates when Manager state changes
- Clean data binding between UI and data layer

## Implementation Notes

- **Manager** conforms to `ObservableObject` for reactive UI updates
- **Sleep** class handles all HealthKit integration and data processing
- **CuratorAI** is stateless and only generates messages
- **ContentView** uses `@StateObject` to observe Manager changes
- All data flows through Manager - no direct communication between other classes

## File Structure
```
Heartifacts/
├── ContentView.swift      # Single UI class
├── Manager.swift          # Controller/coordinator
├── Sleep.swift           # Data model & HealthKit processor
├── CuratorAI.swift       # AI message generator
└── HeartifactsApp.swift  # App entry point
```

---
*This architecture ensures clean separation of concerns, single responsibility principle, and maintainable code structure.*
