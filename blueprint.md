# Project Blueprint: Appointment Booking App

## Overview

This is a Flutter application for booking and managing appointments. It includes role-based access for users and administrators.

## Features & Design

### Implemented Features:

*   **Authentication:**
    *   User registration and login with Firebase Auth.
    *   Unified login screen for both users and admins.
    *   Role-based access control (RBAC) with 'user' and 'admin' roles stored in Firestore.
    *   New users are automatically assigned the 'user' role.
*   **Navigation:**
    *   Declarative routing using `go_router`.
    *   Role-based redirection:
        *   Users are redirected to `/home`.
        *   Admins are redirected to `/admin`.
    *   Protected admin route (`/admin`) that only authenticated admins can access.
*   **UI/UX:**
    *   Landing screen with options to log in or register.
    *   Basic home screens for both users and admins.

### Current Plan: Implement Admin Features

This plan outlines the steps to build out the admin dashboard, starting with appointment management.

**Step 1: Enhance Admin Dashboard UI**
*   Add navigation options on the admin home screen for:
    *   Manage Appointments
    *   Manage Services
    *   View Reports

**Step 2: Implement Appointment Management**
*   Create a new screen to display a list of all appointments from the `appointments` Firestore collection.
*   Add functionality for admins to:
    *   View appointment details.
    *   Approve pending appointments.
    *   Delete appointments.
*   Update the router to include a route to the new appointment management screen.

**Step 3: Implement Services Management (Future)**
*   Create a screen for admins to add, edit, and delete services offered.

**Step 4: Implement Reports (Future)**
*   Create a screen to display reports and analytics on appointments and bookings.
