using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

//Global variables
var numColor = Gfx.COLOR_DK_RED;
var hairColor = Gfx.COLOR_YELLOW;
var shirtColor = Gfx.COLOR_RED;

class simpleFaceApp extends App.AppBase {

	function initialize() {
		AppBase.initialize({});
    }

	// onStart() is called on application start up
	function onStart(state) {
	}

	// onStop() is called when your application is exiting
	function onStop(state) {
	}

	function getInitialView() {
		return [new simpleFaceView()];
	}
}