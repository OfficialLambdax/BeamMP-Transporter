angular.module('beamng.apps')
.directive('transporter', ['CanvasShortcuts', function (CanvasShortcuts) {
	return {
		template: '<div id="ctfApp" style="max-height:100%; width:100%; margin:15px; background:transparent;" layout="row" layout-align="center left" layout-wrap>' +
					'<div id="flagArrow" style="position:absolute; marginTop:-140; marginLeft:-140">' +
						'<img src="/ui/modules/apps/Transporter/posArrow.png" alt="pos arrow">' + 
					'</div>' + 
					'<div id="flagIcon" style="position:absolute; marginTop:-140; marginLeft:-140">' +
						'<img src="/ui/modules/apps/Transporter/flagIcon.png" alt="flag icon">' + 
					'</div>' + 
					'<div id="flagHeightArrow" style="position:absolute; marginTop:-140; marginLeft:-140">' +
						'<img src="/ui/modules/apps/Transporter/heightArrow.png" alt="height arrow">' + 
					'</div>' + 
					'<div id="goalArrow" style="position:absolute; marginTop:-140; marginLeft:-140">' +
						'<img src="/ui/modules/apps/Transporter/posArrow.png" alt="pos arrow">' + 
					'</div>' + 
					'<div id="goalIcon" style="position:absolute; marginTop:-140; marginLeft:-140">' +
						'<img src="/ui/modules/apps/Transporter/goalIcon.png" alt="goal icon">' + 
					'</div>' + 
					'<div id="goalHeightArrow" style="position:absolute; marginTop:-140; marginLeft:-140">' +
						'<img src="/ui/modules/apps/Transporter/heightArrow.png" alt="height arrow">' + 
					'</div>' + 
					'<div id="MSGYouScored" style="position:absolute; marginTop:-70; marginLeft:-440">' +
						'<img src="/ui/modules/apps/Transporter/MSGYouScored.png" alt="message">' + 
					'</div>' + 
					'<div id="MSGLostTheFlag" style="position:absolute; marginTop:-70; marginLeft:-440">' +
						'<img src="/ui/modules/apps/Transporter/MSGLostTheFlag.png" alt="message">' + 
					'</div>' + 
					'<div id="MSGGotTheFlag" style="position:absolute; marginTop:-70; marginLeft:-440">' +
						'<img src="/ui/modules/apps/Transporter/MSGGotTheFlag.png" alt="message">' + 
					'</div>' + 
					'<div id="MSGFlagReset" style="position:absolute; marginTop:-70; marginLeft:-440">' +
						'<img src="/ui/modules/apps/Transporter/MSGFlagReset.png" alt="message">' + 
					'</div>' + 
				  '</div>',
				
		replace: true,
		restrict: 'EA',
		link: function (scope, element, attrs) {
		var streamsList = ['Transporter'];
		StreamsManager.add(streamsList);
	scope.$on('$destroy', function () {
		StreamsManager.remove(streamsList);
	});

	element.ready(function () {
		const flagArrow = document.getElementById("flagArrow");
		const flagIcon = document.getElementById("flagIcon");
		const flagHeightArrow = document.getElementById("flagHeightArrow");
		const goalArrow = document.getElementById("goalArrow");
		const goalIcon = document.getElementById("goalIcon");
		const goalHeightArrow = document.getElementById("goalHeightArrow");
		const MSGYouScored = document.getElementById("MSGYouScored"); //TODO: the messages should be done in html and javascript directly, taking a string from the stream... 
		const MSGLostTheFlag = document.getElementById("MSGLostTheFlag");
		const MSGGotTheFlag = document.getElementById("MSGGotTheFlag");
		const MSGFlagReset = document.getElementById("MSGFlagReset");
		flagArrow.style.marginTop = -140 + 'px'; 
		flagArrow.style.marginLeft = -140 + 'px';
		flagIcon.style.marginTop = -140 + 'px'; 
		flagIcon.style.marginLeft = -140 + 'px';
		flagHeightArrow.style.marginTop = -140 + 'px'; 
		flagHeightArrow.style.marginLeft = -140 + 'px';
		goalArrow.style.marginTop = -140 + 'px'; 
		goalArrow.style.marginLeft = -140 + 'px';
		goalIcon.style.marginTop = -140 + 'px'; 
		goalIcon.style.marginLeft = -140 + 'px';
		goalHeightArrow.style.marginTop = -140 + 'px'; 
		goalHeightArrow.style.marginLeft = -140 + 'px';
		MSGYouScored.style.marginTop = -70 + 'px';
		MSGYouScored.style.marginLeft = -440 + 'px';
		MSGLostTheFlag.style.marginTop = -70 + 'px';
		MSGLostTheFlag.style.marginLeft = -440 + 'px';
		MSGGotTheFlag.style.marginTop = -70 + 'px';
		MSGGotTheFlag.style.marginLeft = -440 + 'px';
		MSGFlagReset.style.marginTop = -70 + 'px';
		MSGFlagReset.style.marginLeft = -440 + 'px';
	});
	// var c = element[0], ctx = c.getContext('2d')
	scope.$on('streamsUpdate', function (event, streams) {
		// var w = c.width/2
		// var h = c.height/2


		// //ORIENTATE VIEW
		var Transporter = streams.Transporter

		// const ctfApp = document.getElementById("ctfApp");
		const flagArrow = document.getElementById("flagArrow");
		const flagIcon = document.getElementById("flagIcon");
		const flagHeightArrow = document.getElementById("flagHeightArrow");
		const goalArrow = document.getElementById("goalArrow");
		const goalIcon = document.getElementById("goalIcon");
		const goalHeightArrow = document.getElementById("goalHeightArrow");
		const MSGYouScored = document.getElementById("MSGYouScored"); //TODO: the messages should be done in html and javascript directly, taking a string from the stream... 
		const MSGLostTheFlag = document.getElementById("MSGLostTheFlag");
		const MSGGotTheFlag = document.getElementById("MSGGotTheFlag");
		const MSGFlagReset = document.getElementById("MSGFlagReset");
		const screenWidth = window.screen.availWidth;
		const screenHeight = window.screen.availHeight - 84; //84 pixels for bottom and top ui, TODO: gotta check if this works on other resolutions to
		// console.log(screenWidth);
		// console.log(screenHeight);
		// Rotate element by 90 degrees clockwise
		if (Transporter) {
			if (Transporter.goalX > screenWidth - 160) {Transporter.goalX = screenWidth - 160} //20 pixels extra for some reason, it looks like the pictures are drawn bigger than their resolution
			if (Transporter.goalY > screenHeight - 160) {Transporter.goalY = screenHeight - 160}
			if (Transporter.flagX > screenWidth - 160) {Transporter.flagX = screenWidth - 160}
			if (Transporter.flagY > screenHeight - 160) {Transporter.flagY = screenHeight - 160}
			if (Transporter.goalX  < 0) {Transporter.goalX = 0}
			if (Transporter.goalY  < 0) {Transporter.goalY = 0}
			if (Transporter.flagX  < 0) {Transporter.flagX = 0}
			if (Transporter.flagY  < 0) {Transporter.flagY = 0}
			if (Transporter.gameRunning) {
				if (Transporter.showMSGYouScored == true) {
					MSGYouScored.style.marginTop = (screenHeight / 2) - (70 / 2) + 'px';
					MSGYouScored.style.marginLeft = (screenWidth / 2) - (420 / 2) + 'px';
				} else {
					MSGYouScored.style.marginTop = -70 + 'px';
					MSGYouScored.style.marginLeft = -440 + 'px';
				}
				if (Transporter.showMSGLostTheFlag == true) {
					MSGLostTheFlag.style.marginTop = (screenHeight / 2) - (70 / 2) + 'px';
					MSGLostTheFlag.style.marginLeft = (screenWidth / 2) - (420 / 2) + 'px';
				} else {
					MSGLostTheFlag.style.marginTop = -70 + 'px';
					MSGLostTheFlag.style.marginLeft = -440 + 'px';
				}
				if (Transporter.showMSGGotTheFlag == true) {
					MSGGotTheFlag.style.marginTop = (screenHeight / 2) - (70 / 2) + 'px';
					MSGGotTheFlag.style.marginLeft = (screenWidth / 2) - (420 / 2) + 'px';
				} else {
					MSGGotTheFlag.style.marginTop = -70 + 'px';
					MSGGotTheFlag.style.marginLeft = -440 + 'px';
				}
				if (Transporter.showMSGFlagReset == true) {
					MSGFlagReset.style.marginTop = (screenHeight / 2) - (70 / 2) + 'px';
					MSGFlagReset.style.marginLeft = (screenWidth / 2) - (420 / 2) + 'px';
				} else {
					MSGFlagReset.style.marginTop = -70 + 'px';
					MSGFlagReset.style.marginLeft = -440 + 'px';
				}
				if (Transporter.showFlagArrow == true) {
					flagArrow.style.transform = "rotate(" + Transporter.flagAngle + "deg)";
					flagArrow.style.transformOrigin = "center";
					flagArrow.style.marginTop = Transporter.flagY + 'px'; 
					flagArrow.style.marginLeft = Transporter.flagX + 'px';
				} else {
					flagArrow.style.marginTop = -140 + 'px'; 
					flagArrow.style.marginLeft = -140 + 'px';
				}

				if (Transporter.showFlagIcon == true) {
					flagIcon.style.marginTop = Transporter.flagY + 'px'; 
					flagIcon.style.marginLeft = Transporter.flagX + 'px';
				} else {
					flagIcon.style.marginTop = -140 + 'px'; 
					flagIcon.style.marginLeft = -140 + 'px';
				}

				if (Transporter.showFlagHeightArrow == true) {
					flagHeightArrow.style.marginTop = Transporter.flagY + 'px'; 
					flagHeightArrow.style.marginLeft = Transporter.flagX + 'px';
					if (Transporter.flagAbovePlayer) {
						flagHeightArrow.style.transform = "rotate(" + 0 + "deg)";
						flagHeightArrow.style.transformOrigin = "center";
					} else {
						flagHeightArrow.style.transform = "rotate(" + 180 + "deg)";
						flagHeightArrow.style.transformOrigin = "center";
					}
				} else {
					flagHeightArrow.style.marginTop = -140 + 'px'; 
					flagHeightArrow.style.marginLeft = -140 + 'px';
				}

				if (Transporter.showGoalArrow == true) {
					goalArrow.style.transform = "rotate(" + Transporter.goalAngle + "deg)";
					goalArrow.style.transformOrigin = "center";
					goalArrow.style.marginTop = Transporter.goalY + 'px'; 
					goalArrow.style.marginLeft = Transporter.goalX + 'px';
				} else {
					goalArrow.style.marginTop = -140 + 'px'; 
					goalArrow.style.marginLeft = -140 + 'px';
				}

				if (Transporter.showGoalIcon == true) {
					goalIcon.style.marginTop = Transporter.goalY + 'px'; 
					goalIcon.style.marginLeft = Transporter.goalX + 'px';
				} else {
					goalIcon.style.marginTop = -140 + 'px'; 
					goalIcon.style.marginLeft = -140 + 'px';
				}
				
				if (Transporter.showGoalHeightArrow == true) {
					goalHeightArrow.style.marginTop = Transporter.goalY + 'px'; 
					goalHeightArrow.style.marginLeft = Transporter.goalX + 'px';
					if (Transporter.goalAbovePlayer) {
						goalHeightArrow.style.transform = "rotate(" + 0 + "deg)";
						goalHeightArrow.style.transformOrigin = "center";
					} else {
						goalHeightArrow.style.transform = "rotate(" + 180 + "deg)";
						goalHeightArrow.style.transformOrigin = "center";
					}
				} else {
					goalHeightArrow.style.marginTop = -140 + 'px'; 
					goalHeightArrow.style.marginLeft = -140 + 'px';
				}
			} else { //game not running so yeet the divs of the screen
				flagArrow.style.marginTop = -140 + 'px'; 
				flagArrow.style.marginLeft = -140 + 'px';
				flagIcon.style.marginTop = -140 + 'px'; 
				flagIcon.style.marginLeft = -140 + 'px';
				flagHeightArrow.style.marginTop = -140 + 'px'; 
				flagHeightArrow.style.marginLeft = -140 + 'px';
				goalArrow.style.marginTop = -140 + 'px'; 
				goalArrow.style.marginLeft = -140 + 'px';
				goalIcon.style.marginTop = -140 + 'px'; 
				goalIcon.style.marginLeft = -140 + 'px';
				goalHeightArrow.style.marginTop = -140 + 'px'; 
				goalHeightArrow.style.marginLeft = -140 + 'px';
				MSGYouScored.style.marginTop = -70 + 'px';
				MSGYouScored.style.marginLeft = -440 + 'px';
				MSGLostTheFlag.style.marginTop = -70 + 'px';
				MSGLostTheFlag.style.marginLeft = -440 + 'px';
				MSGGotTheFlag.style.marginTop = -70 + 'px';
				MSGGotTheFlag.style.marginLeft = -440 + 'px';
				MSGFlagReset.style.marginTop = -70 + 'px';
				MSGFlagReset.style.marginLeft = -440 + 'px';
			}
		} else { //empty stream got sent so yeet the divs of the screen
			flagArrow.style.marginTop = -140 + 'px'; 
			flagArrow.style.marginLeft = -140 + 'px';
			flagIcon.style.marginTop = -140 + 'px'; 
			flagIcon.style.marginLeft = -140 + 'px';
			flagHeightArrow.style.marginTop = -140 + 'px'; 
			flagHeightArrow.style.marginLeft = -140 + 'px';
			goalArrow.style.marginTop = -140 + 'px'; 
			goalArrow.style.marginLeft = -140 + 'px';
			goalIcon.style.marginTop = -140 + 'px'; 
			goalIcon.style.marginLeft = -140 + 'px';
			goalHeightArrow.style.marginTop = -140 + 'px'; 
			goalHeightArrow.style.marginLeft = -140 + 'px';
			MSGYouScored.style.marginTop = -70 + 'px';
			MSGYouScored.style.marginLeft = -440 + 'px';
			MSGLostTheFlag.style.marginTop = -70 + 'px';
			MSGLostTheFlag.style.marginLeft = -440 + 'px';
			MSGGotTheFlag.style.marginTop = -70 + 'px';
			MSGGotTheFlag.style.marginLeft = -440 + 'px';
			MSGFlagReset.style.marginTop = -70 + 'px';
			MSGFlagReset.style.marginLeft = -440 + 'px';
		}		
	});
	
	scope.$on('VehicleChange', function (event, data) {
	});

	scope.$on('app:resized', function (event, data) {
		// c.width = data.width;
		// c.height = data.height;
	});
	}
  };
}]);