# Booking System Development Notes

## ✅ FIXES

- Refactor `CustomerAutoFillComponent` as a subclass of `LineEdit`
- Fix date updates - when date is changed, booking is not immediately updated.

---

## 🧩 TODO

- Change color of the booking in the calendar when prepayment is done
- Selecting booking in the database should select the item in the Calendar
- Selected items should have a different color in the calendar.
- Online synchronize.
- Automatic cost calculation based on room parameters.
- Hiding personal data after 1 min of inactivity.


### 📋 Booking Features
- Auto-fill customer data from previous bookings
- Implement waiting list feature:
  - Customers waiting for cancellations
  - Add additional calendar row at the top showing waiting list (bookings with only a date and no room selected)
- Implement booking cancellation functionality
- Allow jumping to a specific entered date in the calendar

### 🖼️ UI/UX Improvements
- Save layout of split containers and restore on app start

### 🏨 Room Management
- Add ability to change room parameters
- Add/remove rooms dynamically
- Add room price calculation

### 📊 Reporting
- Include a monthly occupancy chart

### 🚀 Optimization
- Load only the latest records from the database (avoid loading everything)
- Avoid recalculating overbookings on every booking update

### 🧑‍🏫 Tutorial
- Add an interactive tutorial explaining features, tips, and tricks
- Should run on the first launch of the app

---

## 💡 MAYBE

- Refactor bookings in the calendar view into their own objects, instead of simply coloring calendar fields
