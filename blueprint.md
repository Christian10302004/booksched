# Project Blueprint

## Overview

This document outlines the style, design, and features of the Flutter application. It serves as a single source of truth for the application's current state and future development plans.

## Style and Design

The application follows the Material Design 3 guidelines to ensure a modern and consistent user experience.

*   **Theming**: The app uses a color scheme generated from a seed color, with support for both light and dark modes.
*   **Typography**: The `google_fonts` package is used to provide a consistent and aesthetically pleasing set of text styles.
*   **Component Theming**: The app customizes the appearance of individual Material components (e.g., `AppBar`, `ElevatedButton`) to match the overall theme.
*   **Layout**: The app uses a clean and balanced layout with appropriate spacing and padding.

## Features

### User Authentication

*   **Registration**: Users can create a new account with their full name, email, and password.
*   **Login and Logout**: Users can log in and out of the application using their email and password.
*   **Logout Confirmation**: Both users and admins will see a confirmation dialog when they attempt to log out. This dialog includes a loading indicator and a cancel button.
*   **Role-based Access Control**: The app distinguishes between regular users and administrators, showing different UI and functionality based on the user's role.
*   **Auth Screen Navigation**: The login screen now has a link to the registration screen, and the registration screen has a link to the login screen.

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
*   **User Navigation**: Users can navigate between booking an appointment, viewing their appointments, and viewing their profile.
*   **Admin Navigation**: Administrators can navigate between adding a service and managing appointments.
*   **Back Button**: A back button has been added to several screens to allow users to easily navigate back to the previous screen. The admin home screen does not have a back button as it is a top-level screen.

## Current Plan

The current development effort was focused on adding a confirmation dialog with a loading indicator to the logout process for both users and administrators. This feature has been implemented in `admin_home_screen.dart` and `profile_screen.dart`.

All planned features for this update have been implemented.
