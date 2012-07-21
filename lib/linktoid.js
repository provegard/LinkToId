// Copyright (c) 2012 Per Rovegard, http://rovegard.com
// The contents of this file are subject to the terms and conditions of the MIT 
// license, see http://per.mit-license.org.

window[chrome.i18n.getMessage("@@extension_id")] = (function($, module) {
	
	var extId = chrome.i18n.getMessage("@@extension_id");

	// Get the distance from the top of an element to the "page top."
	var getElementTop = function(e) {
    var top = 0;

		// Walk the offset parent hierarchy upwards until we hit the body element.
		// The sum of all offsetTop values is equal to the verticial distance from
		// the "page top."
    while (e != null && e.tagName != "BODY") {
			top += e.offsetTop;
			e = e.offsetParent;
    }
   
    return top;
	};

	// Determines if an event is "active," or "triggering." To make this extension
	// more useful, the condition should be configurable.
	var isActive = function(event) {
			return event.ctrlKey && event.altKey;
	};

	// Determines if an element is a block element.
	var isBlock = function(e) {
		var cs = window.getComputedStyle(e, "");
		return cs.display == "block";
	};

	// Removes the tooltip if it's found. Otherwise, does nothing.
	var removeTooltip = function() {
		var tooltip = findTooltip();
		if (tooltip != null) {
			tooltip.remove();
		}
	};

	// Determines if an element has a non-empty ID attribute.
	var hasId = function(e) {
		return (e.id || "").length > 0;
	};

	// Given a candidate element, walks the DOM hierarchy upwards until it finds
	// an element with a non-empty ID attribute. Returns the element found, or
	// null.
	var findTarget = function(candidate) {
		var target = candidate;
		var top = getElementTop(target);
		while (target != null && !hasId(target)) {
			target = target.parentNode;
		}
		return target != null && hasId(target) ? target : null;
	};
	
	// Determines if the supplied ID matches the fragment/hash of the supplied
	// location object.
	var idMatchesHash = function(id, location) {
		return "#" + id === location.hash;
	};
	
	// Used as a click handler. Updates the fragment/hash if the event is active
	// and a suitable target element can be found. Any showing tooltip is removed.
	var update = function(event, location) {
		if (isActive(event)) {
			var target = findTarget(event.target);

			// Update the hash (fragment) if we have a target, but only if
			// the current hash isn't already equal to the target ID.
			if (target != null && !idMatchesHash(target.id, location)) {
				// Prevent further processing of this event.
				event.preventDefault();
				event.stopPropagation();
				
				removeTooltip();
				location.hash = target.id;
			}
		}
	};
	
	// Finds the currently showing tooltip. Returns the jQuery object if found,
	// null otherwise.
	var findTooltip = function() {
		var tooltip = $(".tt-" + extId);
		return tooltip.length > 0 ? tooltip : null;
	};
	
	// Creates the text to be used for the tooltip.
	var createTooltipText = function(id, distance) {
		var htmlText = "Click to navigate to <span>#" + id + "</span>!";
		if (distance > 0) {
			htmlText += " It's " + distance + " pixels to the north, by the way.";
		}
		return htmlText;
	};
	
	// Used as a mouse move handler. Creates the tooltip if necessary, otherwise
	// simply moves it to the correct location. If the current fragment/hash is
	// equal to the ID of the target element, no tooltip is created.
	var enter = function(event, location) {
		if (isActive(event)) {
			var target = findTarget(event.target);

			// Add a class if we have a target!
			if (target != null && !idMatchesHash(target.id, location)) {
				var distance = event.pageY - getElementTop(target);
				var htmlText = createTooltipText(target.id, distance);

				var tooltip = findTooltip();
				if (tooltip == null) {
					var tooltip = $("<span/>")
						.attr("class", "tt-" + extId)
						.html(htmlText);
						
					// The tooltip is added as a child to BODY so that the position becomes
					// relative to the page rather than a specific element.
					$("body").append(tooltip);
				}
				
				// Position the tooltip adjacent to the mouse location.
				tooltip
					.css("top", event.pageY)
					.css("left", event.pageX + 10);
			}
		} else {
			removeTooltip();
		}
	};
	
	// Removes any showing tooltip.
	var leave = function(event) {
		removeTooltip();
	};
	
	// Removes any showing tooltip if the event isn't an active one.
	var cancel = function(event) {
		if (!isActive(event)) {
			removeTooltip();
		}
	};

	$(document).mousedown(function(event) {
		update(event, window.location);
	});
	
	$(document).keyup(cancel);
	$(document).mousemove(function(event) {
		enter(event, window.location);
	});
	$(document).mouseout(leave);

	// Exported for testing
	module.exports = {
		isBlock: isBlock,
		hasId: hasId,
		findTarget: findTarget,
		enter: enter,
		leave: leave,
		update: update,
		getElementTop: getElementTop,
		cancel: cancel
	};
	
	return module;

})(jQuery, window[chrome.i18n.getMessage("@@extension_id")] || {});
