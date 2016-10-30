using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.ActivityMonitor as Act;
using Toybox.Time.Gregorian as Calendar;

class NicholeFaceView extends Ui.WatchFace {

	var showOther = false;

	var hhTime,
		mmTime,
		ssTime,
		battery,
		percentString,
		dayNum,
		dateMonth,
		stepCount;

	var	simpleFont,
		simpleBoldFont,
		deviceSettings,
		steps,
		stepGoal,
		stepBarDraw,
		stepCountDraw;

	function initialize() {
		WatchFace.initialize();

		//get device infor for formatting
		deviceSettings = Sys.getDeviceSettings();

		//pull data from Garmin Connect/storage
		var app = App.getApp();

		if (app.getProperty("num_prop")) {
			$.numColor = app.getProperty("num_prop");
		}

		if (app.getProperty("hair_prop")) {
			$.hairColor = app.getProperty("hair_prop");
		}

		if (app.getProperty("shirt_prop")) {
			$.shirtColor = app.getProperty("shirt_prop");
		}
    }

	function onLayout(dc) {
		setLayout(Rez.Layouts.nichole(dc));

		//fonts
		simpleFont = Ui.loadResource(Rez.Fonts.simple);
		simpleBoldFont = Ui.loadResource(Rez.Fonts.simpleBold);

		//text labels
		stepCount = View.findDrawableById("stepLabel");	//step goal number
		hhTime = View.findDrawableById("hhLabel");		//hour
		mmTime = View.findDrawableById("mmLabel");		//minute
		ssTime = View.findDrawableById("ssLabel");		//seconds
		dayNum = View.findDrawableById("dayLabel");	//date string
		dateMonth = View.findDrawableById("dateLabel");	//date string
		battery = View.findDrawableById("batLabel");	//battery % string
		percentString = View.findDrawableById("percentLabel"); //battery % sign
    }

    function onUpdate(dc) {
		dc.clear();
		var string;

		var clockTime = Sys.getClockTime();

		if (showOther) { //low power mode

			ssTime.setText(Lang.format("$1$",[clockTime.sec])); 			// seconds

			//draw day | month | date
			var now = Time.now();
			var info = Calendar.info(now, Time.FORMAT_LONG);
			var day = Lang.format("$1$", [info.day_of_week]);
			var month = Lang.format("$1$", [info.month]);
			var date = Lang.format("$1$", [info.day]);
			string = date + " " + month;
			dateMonth.setText(string);
			string = day;
			dayNum.setText(string);

			// battery % value
			var sysStats = Sys.getSystemStats();
			string = Lang.format("$1$",[sysStats.battery.format("%01.0i")]);
			battery.setText(string);
			percentString.setText("%");

			//draw steps
			var activityInfo = Act.getInfo();
			stepGoal = activityInfo.stepGoal;
			steps = activityInfo.steps;
			stepCount.setText(steps.toString());
		}
		else {
			dayNum.setText("");		//clear day
			dateMonth.setText("");		//clear month & date
			battery.setText("");		//clear battery % value
			percentString.setText("");	//clear battery '%'
			stepCount.setText("");		//clear step goal number
			ssTime.setText("");			//clear seconds
		}

		//draw hours
		if (deviceSettings.is24Hour == false) {
			string = clockTime.hour % 12;
			string = (string == 0) ? 12 : string; //if it's 0, change to 12
			string = Lang.format("$1$",[string.format("%01d")]);
			//am|pm
		}
		else {
			string = Lang.format("$1$",[clockTime.hour.format("%01d")]);
		}
		hhTime.setText(string);
		hhTime.setFont(simpleBoldFont);

		//draw minutes
		string = clockTime.min;
		string = Lang.format("$1$",[string.format("%02d")]);
		mmTime.setText(string);
		mmTime.setFont(simpleFont);
		mmTime.setColor($.numColor);

		View.onUpdate(dc); //draw everything in the layout

		if (showOther) { //draw dynamic things on top of the layout
			//draw step goal & filler
			stepBarDraw = new Rez.Drawables.stepBar();
			stepBarDraw.draw(dc);
			dc.setColor($.numColor, Gfx.COLOR_TRANSPARENT);

			if (deviceSettings.screenShape == Sys.SCREEN_SHAPE_ROUND) {
					if (steps < stepGoal) {
						steps = 70 * steps / stepGoal; //total width calc for %
					}
					else {
						steps = 70;
					}
					dc.fillRectangle(106, 142, steps, 3);
			}
			else if (deviceSettings.screenShape == Sys.SCREEN_SHAPE_SEMI_ROUND) {
				if (deviceSettings.screenWidth > 148) {
					if (steps < stepGoal) {
						steps = 75 * steps / stepGoal; //total width calc for %
					}
					else {
						steps = 75;
					}
					dc.fillRectangle(106, 126, steps, 3);
				}
			}
			else {
				if (deviceSettings.screenWidth > 148) {
					if (steps < stepGoal) {
						steps = 75 * steps / stepGoal; //total width calc for %
					}
					else {
						steps = 75;
					}
					dc.fillRectangle(100, 71, steps, 3);
				}
				else {
					if (steps < stepGoal) {
						steps = 40 * steps / stepGoal; //total width calc for %
					}
					else {
						steps = 40;
					}
					dc.fillRectangle(105, 149, steps, 3);
				}
			}
		}
	}

	function onExitSleep() {
		showOther = true;
	}

	function onEnterSleep() {
		showOther = false;
		Ui.requestUpdate();
	}
}