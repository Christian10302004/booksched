# Project Blueprint

## Overview

This document outlines the style, design, and features of the Flutter application. It serves as a single source of truth for the application's current state and future development plans.

## Style and Design

The application follows the Material Design 3 guidelines to ensure a modern and consistent user experience.

*   **Theming**: The app uses a color scheme generated from a seed color, with support for both light and dark modes.
*   **Typography**: The `google_fonts` package is used to provide a consistent and aesthetically pleasing set of text styles.
*   **Component Theming**: The app customizes the appearance of individual Material components (e.g., `AppBar`, `ElevatedButton`) to match the overall theme.
*   **Layout**: The app uses a clean and balanced layout with appropriate spacing and padding. The landing, login, and registration screens feature a subtle gradient background, a prominent logo, a welcoming headline and sub-headline, and full-width buttons. The user home screen has been redesigned with a modern, card-based layout.

## Features

### User Authentication

*   **Splash Screen**: A splash screen is displayed for 3 seconds when the app starts.
*   **Landing Screen**: A visually appealing landing screen is the initial authentication screen. It features the app logo, a welcoming message, and options to either log in or register.
*   **Registration**: Users can create a new account with their full name, email, and password. The registration screen is designed to be consistent with the landing and login screens and includes a link for users to navigate to the login screen if they already have an account.
*   **Login and Logout**: Users can log in and out of the application using their email and password. The login screen is designed to be consistent with the landing screen and includes a link for users to navigate to the registration screen if they don't have an account.
*   **Logout Confirmation**: Both users and admins will see a confirmation dialog when they attempt to log out. This dialog includes a loading indicator and a cancel button.
*   **Role-based Access Control**: The app distinguishes between regular users and administrators, showing different UI and functionality based on the user's role.

### User Home Screen

*   **Redesigned UI**: The user home screen has been completely redesigned for a more modern and user-friendly experience.
*   **Welcome Header**: A personalized welcome message is displayed in a visually appealing header.
*   **Quick Actions**: Users have quick access to key actions like booking an appointment and viewing their appointments.
*   **Upcoming Appointments**: A card displays a summary of upcoming appointments (placeholder data).
*   **Bottom Navigation Bar**: A new bottom navigation bar allows for easy navigation between the home screen, booking, appointments, and profile.

### User Profile

*   **View Profile**: Users can view their name and email on a dedicated profile screen.
*   **Upload Profile Picture**: Users can upload and update their profile picture.

### Service Management (Admin)

*   **Add Services**: Administrators can add new services with a name, description, and price.
*   **View Services**: Administrators can view a list of all available services.

### Appointment Booking (User)

*   **Book Appointments**: Users can book appointments for available services.
*   **View Appointments**: Users can view a list of their own appointments, including the status (pending, approved, or rejected).
*   **Edit Appointments**: Users can edit the date and time of their pending appointments.

### Appointment Management (Admin)

*   **View All Appointments**: Administrators can view a list of all appointments from all users.
*   **Approve or Reject Appointments**: Administrators can approve or reject pending appointments.

### Reporting (Admin)

*   **Financial Reports**: Administrators can view a summary of total income from approved appointments and a history of all transactions.

### Dashboard (Admin)

*   **Appointment Status Chart**: A pie chart on the admin dashboard visualizes the distribution of appointment statuses (e.g., pending, approved, rejected).

### Navigation

*   **Role-based Navigation**: The app provides a different set of navigation options for users and administrators.
*   **User Navigation**: A new bottom navigation bar has been added for a more intuitive user experience, allowing easy access to the home screen, booking, appointments, and profile.
*   **Admin Navigation**: Administrators can navigate between adding a service and managing appointments.
*   **Back Button**: A back button has been added to several screens to allow users to easily navigate back to the previous screen. The admin home screen does not have a back button as it is a top-level screen.

## Current Plan

The user home screen has been completely redesigned with a more modern and visually appealing UI. It now features a welcoming header, quick action buttons, a card for upcoming appointments, and a new bottom navigation bar for a more intuitive user experience.

All planned features for this update have been implemented.