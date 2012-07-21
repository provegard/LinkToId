// Copyright (c) 2012 Per Rovegard, http://rovegard.com
// The contents of this file are subject to the terms and conditions of the MIT 
// license, see http://per.mit-license.org.

describe("The LinkToId extension", function() {
	
	var extId = chrome.i18n.getMessage("@@extension_id");
	var LinkToId = window[extId].exports;
	var findTooltip = function() {
		return $(".tt-" + extId);
	};
	
	afterEach(function() {
		// Global cleanup, so that individual tests don't need to
		// bother cleaning up after themselves.
		findTooltip().remove();
	});
	
	describe("The getElementTop function", function() {

		it("calculates the top coordinate for an element", function() {
			var div = $("#level1")[0];
			// margin-top is 20, so > 19 works
			expect(LinkToId.getElementTop(div)).toBeGreaterThan(19);
  	});

		it("calculates the top coordinate for a nested element", function() {
			var div = $("#level2")[0];
			// margin-top is 20, so > 39 (20 + 19) works
			expect(LinkToId.getElementTop(div)).toBeGreaterThan(39);
  	});
		
	});
	
	describe("The isBlock function", function() {

		it("identifies a plain div as a block element", function() {
			var div = $("#div1")[0];
    	expect(LinkToId.isBlock(div)).toEqual(true);
  	});
		
		it("identifies a plain span as NOT being a block element", function() {
			var span = $("#span1")[0];
    	expect(LinkToId.isBlock(span)).toEqual(false);
  	});
  	
  	it("identifies a span with 'display: block' as a block element", function() {
  		var span = $("#blockspan")[0];
  		expect(LinkToId.isBlock(span)).toEqual(true);
  	});
 
	});
	
	describe("the hasId function", function() {
		
		it("finds that an element with a non-empty ID has an ID", function() {
			var div = $("#div1")[0];
			expect(LinkToId.hasId(div)).toEqual(true);
		});
		
		it("finds that an element without an ID does NOT have an ID", function() {
			var anchor = $("[name=anchorWithoutId]")[0];
			expect(LinkToId.hasId(anchor)).toEqual(false);
		});
		
		it("finds that an element with an empty ID does NOT have an ID", function() {
			var anchor = $("[name=anchorWithEmptyId]")[0];
			expect(LinkToId.hasId(anchor)).toEqual(false);
		});

	});
	
	describe("the findTarget function", function() {
		
		it("considers an element with an ID to be a valid target", function() {
			var div = $("#div1")[0];
			expect(LinkToId.findTarget(div)).toBe(div);
		});
		
		it("searches for a parent element with an ID to find a target", function() {
			var anchor = $("[name=anchorWithoutIdWithinSpan]")[0];
			expect(LinkToId.findTarget(anchor)).toBe(anchor.parentNode);
		});
		
		it("stops searching parents as soon as it finds a match", function() {
			var anchor = $("[name=anchorWithoutIdWithinDivsAndSpan]")[0];
			expect(LinkToId.findTarget(anchor).id).toEqual("innerDiv");
		});

		it("searches beyond header tags (i.e., block elements)", function() {
			var h1 = $(".page_title")[0];
			expect(LinkToId.findTarget(h1).id).toEqual("pageTitle");
		});
	});
		
	describe("the update function", function() {

		var evt, loc;
		
		describe("when the trigger keys are pressed", function() {
			
			beforeEach(function() {
				evt = $.Event("mousedown", { ctrlKey: true, altKey: true, target: $("#div1")[0] });
				loc = { hash: "" };
				LinkToId.enter(evt, loc);
				LinkToId.update(evt, loc);
			});
			
			it("sets the fragment/hash to the ID of an element when the trigger keys are pressed", function() {
				expect(loc.hash).toEqual("div1");
			});
			
			it("prevents default event handling", function() {
				expect(evt.isDefaultPrevented()).toEqual(true);
			});
	
			it("stops event propagation", function() {
				expect(evt.isPropagationStopped()).toEqual(true);
			});

			it("removes any showing tooltip", function() {
				expect(findTooltip().length).toEqual(0);
			});
			
		});

		describe("when the trigger keys are NOT pressed", function() {
			
			beforeEach(function() {
				evt = $.Event("mousedown", { ctrlKey: true, altKey: false, target: $("#div1")[0] });
				loc = { hash: "" };
				LinkToId.update(evt, loc);
			});
	
			it("doesn't set the fragment/hash", function() {
				expect(loc.hash).toEqual("");
			});
	
		});
		
		describe("when the fragment/hash is the same as the ID of the element being clicked", function() {
			
			var updatedHash;
			
			beforeEach(function() {
				evt = $.Event("mousedown", { ctrlKey: true, altKey: true, target: $("#div1")[0] });
				loc = { hash: "" };
				Object.defineProperty(loc, "hash", { 
					get: function() { return "#div1"; },
					set: function(value) { updatedHash = value; } 
				});
				LinkToId.update(evt, loc);
			});
			
			it("doesn't re-set the fragment/hash", function() {
				expect(updatedHash).toBe(undefined);
			});
			
		});

	});
	
	describe("the enter function", function() {
		
		var evt, tooltip;

		describe("when the trigger keys are pressed", function() {
			
			beforeEach(function() {
				var elem = $("#div1")[0];
				evt = $.Event("mouseover", { ctrlKey: true, altKey: true, target: elem, pageX: 10, pageY: 10 });
				LinkToId.enter(evt, { hash: "" });
				tooltip = findTooltip();
			});
			
			it("creates a tooltip", function() {
				expect(tooltip.length).toEqual(1);
			});
			
			it("positions the tooltip horizontally a little to the right of the event position", function() {
				// Cannot use css("left") for this for some reason...
				expect(tooltip[0].style.left).toEqual("20px");
			});
	
			it("positions the tooltip vertically on level with the event position", function() {
				// Cannot use css("top") for this for some reason...
				expect(tooltip[0].style.top).toEqual("10px");
			});
	
			it("reuses any existing tooltip when called repeatedly", function() {
				LinkToId.enter(evt, { hash: "" }); // second time
				var newTooltip = findTooltip(); // re-lookup
				expect(newTooltip.length).toEqual(1);
			});
	
			it("includes target element ID in the tooltip text", function() {
				expect(tooltip.text()).toContain("#div1");
			});

			it("makes the tooltip a child of the body element", function() {
				expect(tooltip[0].parentNode.tagName).toEqual("BODY");
			});
			
		});

		describe("when the trigger keys are NOT pressed", function() {
			
			beforeEach(function() {
				var elem = $("#div1")[0];
				var evt1 = $.Event("mouseover", { ctrlKey: true, altKey: true, target: elem, pageX: 10, pageY: 10 });
				evt = $.Event("mouseover", { ctrlKey: true, altKey: false, target: elem, pageX: 10, pageY: 10 });
				LinkToId.enter(evt1, { hash: "" });
				LinkToId.enter(evt, { hash: "" });
				tooltip = findTooltip();
			});
			
			it("removes any existing tooltip", function() {
				expect(tooltip.length).toEqual(0);
			});
			
		});

		
		describe("when the fragment/hash is the same as the ID of the element being entered", function() {
			
			var updatedHash;
			
			beforeEach(function() {
				evt = $.Event("mousedown", { ctrlKey: true, altKey: true, target: $("#div1")[0] });
				loc = { hash: "#div1" };
				LinkToId.enter(evt, loc);
				tooltip = findTooltip();
			});
			
			it("doesn't create a tooltip", function() {
				expect(tooltip.length).toEqual(0);
			});
			
		});

	});

	describe("the leave function", function() {

		var elem, evt, tooltip;
		
		beforeEach(function() {
			elem = $("div1")[0];
			evt = $.Event("mouseover", { ctrlKey: true, altKey: true, target: elem, pageX: 10, pageY: 10 });
			LinkToId.enter(evt, { hash: "" });
			LinkToId.leave(evt);
			tooltip = findTooltip();
		});
		
		it("removes any tooltip", function() {
			expect(tooltip.length).toEqual(0);
		});
		
		it("ignores non-existant tooltip", function() {
			LinkToId.leave(evt);
			expect(findTooltip().length).toEqual(0);
		});

	});
	
	describe("the cancel function", function() {

		var evt, tooltip;

		describe("when the trigger keys are no longer pressed", function() {
			
			beforeEach(function() {
				var elem = $("#div1")[0];
				var evt1 = $.Event("mouseover", { ctrlKey: true, altKey: true, target: elem, pageX: 10, pageY: 10 });
				evt = $.Event("keyup", { ctrlKey: false, altKey: false, target: elem });
				LinkToId.enter(evt1, { hash: "" });
				LinkToId.cancel(evt);
				tooltip = findTooltip();
			});
			
			it("removes any tooltip", function() {
				expect(tooltip.length).toEqual(0);
			});
			
			it("ignores non-existant tooltip", function() {
				LinkToId.cancel(evt);
				expect(findTooltip().length).toEqual(0);
			});
			
		});

		describe("when the trigger keys are still pressed", function() {
			
			beforeEach(function() {
				var elem = $("#div1")[0];
				var evt1 = $.Event("mouseover", { ctrlKey: true, altKey: true, target: elem, pageX: 10, pageY: 10 });
				evt = $.Event("keyup", { ctrlKey: true, altKey: true, target: elem });
				LinkToId.enter(evt1, { hash: "" });
				LinkToId.cancel(evt);
				tooltip = findTooltip();
			});
			
			it("doesn't remove any tooltip", function() {
				expect(tooltip.length).toEqual(1);
			});
			
		});

	});

});

(function() {
	var jasmineEnv = jasmine.getEnv();
	jasmineEnv.updateInterval = 250;

	var htmlReporter = new jasmine.HtmlReporter();
	jasmineEnv.addReporter(htmlReporter);

	jasmineEnv.specFilter = function(spec) {
		return htmlReporter.specFilter(spec);
	};

	$(document).ready(function() {
		jasmineEnv.execute();
	});

})();

