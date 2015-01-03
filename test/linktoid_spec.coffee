# Copyright (c) 2012-2014 Per Rovegard, http://rovegard.com
# The contents of this file are subject to the terms and conditions of the MIT 
# license, see http://per.mit-license.org/2012.

describe "The LinkToId extension", ->
  
  extId = chrome.i18n.getMessage "@@extension_id"
  LinkToId = window[extId].exports
  findTooltip = -> $(".tt-#{extId}")
  content = null
  
  beforeEach ->
    content = document.querySelector('link[rel="import"]').import
    importedBody = $(content).find "body"
    $("body").append "<div id='playground'></div>"
    $("#playground").append importedBody.html()
  
  afterEach ->
    $("#playground").remove()
  
    # Global cleanup, so that individual tests don't need to
    # bother cleaning up after themselves.
    findTooltip().remove()
  
  describe "The getElementTop function", ->

    it "calculates the top coordinate for an element", ->
      div = $("#level1")[0]
      # margin-top is 20, so > 19 works
      expect(LinkToId.getElementTop div).toBeGreaterThan 19

    it "calculates the top coordinate for a nested element", ->
      div = $("#level2")[0]
      # margin-top is 20, so > 39 (20 + 19) works
      expect(LinkToId.getElementTop div).toBeGreaterThan 39

  describe "The isBlock function", ->

    it "identifies a plain div as a block element", ->
      div = $("#div1")[0]
      expect(LinkToId.isBlock div).toBe true
    
    it "identifies a plain span as NOT being a block element", ->
      span = $("#span1")[0]
      expect(LinkToId.isBlock span).toBe false
    
    it "identifies a span with 'display: block' as a block element", ->
      span = $("#blockspan")[0]
      expect(LinkToId.isBlock span).toBe true
  
  describe "the hasId function", ->
  
    it "finds that an element with a non-empty ID has an ID", ->
      div = $("#div1")[0]
      expect(LinkToId.hasId div).toBe true
    
    it "finds that an element without an ID does NOT have an ID", ->
      anchor = $("[name=anchorWithoutId]")[0]
      expect(LinkToId.hasId anchor).toBe false
    
    it "finds that an element with an empty ID does NOT have an ID", ->
      anchor = $("[name=anchorWithEmptyId]")[0]
      expect(LinkToId.hasId anchor).toBe false
  
  describe "the findTarget function", ->
    
    it "considers an element with an ID to be a valid target", ->
      div = $("#div1")[0]
      expect(LinkToId.findTarget div).toBe div
    
    it "searches for a parent element with an ID to find a target", ->
      anchor = $("[name=anchorWithoutIdWithinSpan]")[0]
      expect(LinkToId.findTarget anchor).toBe anchor.parentNode
    
    it "stops searching parents as soon as it finds a match", ->
      anchor = $("[name=anchorWithoutIdWithinDivsAndSpan]")[0]
      expect(LinkToId.findTarget(anchor).id).toBe "innerDiv"

    it "searches beyond header tags (i.e., block elements)", ->
      h1 = $(".page_title")[0]
      expect(LinkToId.findTarget(h1).id).toBe "pageTitle"
    
  describe "the update function", ->

    describe "when the trigger keys are pressed", ->
      
      beforeEach ->
        @evt = $.Event "mousedown",
          ctrlKey: true
          altKey: true
          target: $("#div1")[0]
        @loc = hash: ""
        LinkToId.enter @evt, @loc
        LinkToId.update @evt, @loc
      
      it "sets the fragment/hash to the ID of an element when the trigger keys are pressed", ->
        expect(@loc.hash).toBe "div1"
      
      it "prevents default event handling", ->
        expect(@evt.isDefaultPrevented()).toBe true
  
      it "stops event propagation", ->
        expect(@evt.isPropagationStopped()).toBe true

      it "removes any showing tooltip", ->
        expect(findTooltip().length).toBe 0

    describe "when the trigger keys are NOT pressed", ->
      
      beforeEach ->
        @evt = $.Event "mousedown",
          ctrlKey: true
          altKey: false
          target: $("#div1")[0]
        @loc = hash: ""
        LinkToId.update @evt, @loc
  
      it "doesn't set the fragment/hash", ->
        expect(@loc.hash).toBe ""
    
    describe "when the fragment/hash is the same as the ID of the element being clicked", ->
      
      beforeEach ->
        @evt = $.Event "mousedown",
          ctrlKey: true
          altKey: true
          target: $("#div1")[0]
        @loc = hash: ""
        Object.defineProperty @loc, "hash",
          get: -> "#div1"
          set: (value) => @updatedHash = value
        LinkToId.update @evt, @loc
      
      it "doesn't re-set the fragment/hash", ->
        expect(@updatedHash).toBeUndefined()
  
  describe "the enter function", ->
    
    describe "when the trigger keys are pressed", ->
      
      beforeEach ->
        @elem = document.getElementById 'div1'
        @evt = $.Event "mouseover",
          ctrlKey: true
          altKey: true
          target: @elem
          pageX: 10
          pageY: 10
        LinkToId.enter @evt, hash: ""
        @tooltip = findTooltip()
      
      it "creates a tooltip", ->
        expect(@tooltip.length).toBe 1
      
      it "positions the tooltip horizontally a little to the right of the event position", ->
        # Cannot use css("left") for this for some reason...
        expect(@tooltip[0].style.left).toBe "20px"
  
      it "positions the tooltip vertically on level with the event position", ->
        # Cannot use css("top") for this for some reason...
        expect(@tooltip[0].style.top).toBe "10px"
  
      it "reuses any existing tooltip when called repeatedly", ->
        LinkToId.enter @evt, hash: "" # second time
        newTooltip = findTooltip()
        expect(newTooltip.length).toBe 1
  
      it "includes target element ID in the tooltip text", ->
        expect(@tooltip.text()).toContain "#div1"

      it "updates the tooltip text as the mouse is moved to another element", ->
        elem = document.getElementById 'level1'
        evt = $.Event "mouseover",
          ctrlKey: true
          altKey: true
          target: elem
          pageX: 10
          pageY: 10
        LinkToId.enter evt, hash: ""
        expect(@tooltip.text()).toContain "#level1"

      it "makes the tooltip a child of the body element", ->
        expect(@tooltip[0].parentNode.tagName).toBe "BODY"

    describe "when the trigger keys are NOT pressed", ->
      
      beforeEach ->
        @elem = $("#div1")[0]
        @evt1 = $.Event "mouseover", 
          ctrlKey: true
          altKey: true
          target: @elem
          pageX: 10
          pageY: 10
        @evt = $.Event "mouseover",
          ctrlKey: true
          altKey: false
          target: @elem
          pageX: 10
          pageY: 10
        LinkToId.enter @evt1, hash: ""
        LinkToId.enter @evt, hash: ""
        @tooltip = findTooltip()
      
      it "removes any existing tooltip", ->
        expect(@tooltip.length).toBe 0

    
    describe "when the fragment/hash is the same as the ID of the element being entered", ->
      
      beforeEach ->
        @evt = $.Event "mousedown",
          ctrlKey: true 
          altKey: true
          target: $("#div1")[0]
        @loc = hash: "#div1"
        LinkToId.enter @evt, @loc
        @tooltip = findTooltip();
      
      it "doesn't create a tooltip", ->
        expect(@tooltip.length).toBe 0

  describe "the leave function", ->

    beforeEach ->
      @elem = $("div1")[0]
      @evt = $.Event "mouseover", 
        ctrlKey: true
        altKey: true
        target: @elem
        pageX: 10
        pageY: 10
      LinkToId.enter @evt, hash: ""
      LinkToId.leave @evt
      @tooltip = findTooltip()
    
    it "removes any tooltip", ->
      expect(@tooltip.length).toBe 0
    
    it "ignores non-existant tooltip", ->
      LinkToId.leave @evt
      expect(findTooltip().length).toBe 0
  
  describe "the cancel function", ->

    describe "when the trigger keys are no longer pressed", ->
      
      beforeEach ->
        @elem = $("#div1")[0]
        @evt1 = $.Event "mouseover", 
          ctrlKey: true
          altKey: true
          target: @elem
          pageX: 10
          pageY: 10
        @evt = $.Event "keyup", 
          ctrlKey: false
          altKey: false
          target: @elem
        LinkToId.enter @evt1, hash: ""
        LinkToId.cancel @evt
        @tooltip = findTooltip()
      
      it "removes any tooltip", ->
        expect(@tooltip.length).toBe 0
      
      it "ignores non-existant tooltip", ->
        LinkToId.cancel @evt
        expect(findTooltip().length).toBe 0

    describe "when the trigger keys are still pressed", ->
      
      beforeEach ->
        @elem = $("#div1")[0]
        @evt1 = $.Event "mouseover", 
          ctrlKey: true
          altKey: true
          target: @elem
          pageX: 10
          pageY: 10
        @evt = $.Event "keyup", 
          ctrlKey: true
          altKey: true
          target: @elem
        LinkToId.enter @evt1, hash: ""
        LinkToId.cancel @evt
        @tooltip = findTooltip()
      
      it "doesn't remove any tooltip", ->
        expect(@tooltip.length).toBe 1

