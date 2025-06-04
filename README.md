# hotel

NAMES:
	>Bookini<
	CheckMate
	ReserVibe
	VibInn

FIX:
	CustomerAutoFillComponent - remake as LineEdit extension class
	translations - months, tooltips on buttons
	database item without text is smaller in Y size than with text
	

TODO:
	Auto-fill customer data from previous bookings
	Waiting list - customers who are waiting for cancellation of other bookings
		Additional calendar row at the beginning showing waiting list - bookings with only date w/o room selected
	
	implement cancelling bookings
	jump to entered date in the calendar
	save layout of split containers and load on start
	room management
		add possibility to change room params and add/remove rooms
	occupancy reports
		add occupancy overview per day in the calendar (new row)
		add chart for month
	optimize
		don't load all database records, only the latest
		don't recalculate overbookings on each bookings update
	tutorial explaining functions and tips and tricks
		should run at the first start of the app

MAYBE:
	Make bookings in the calendar view its own object instead of coloring calendar fields
