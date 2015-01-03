# Copyright (c) 2012-2014 Per Rovegard, http://rovegard.com
# The contents of this file are subject to the terms and conditions of the MIT 
# license, see http://per.mit-license.org/2012.

describe "The LinkToId extension", ->
  
  extId = chrome.i18n.getMessage "@@extension_id"
  LinkToId = window[extId].exports
  findTooltip = -> $(".tt-#{extId}")
  content = null
  
  createMouseEvent = (type, triggerPressed, pageX, pageY) ->
    props =
      view: window
      bubbles: true
      cancelable: true
      ctrlKey: triggerPressed
      altKey: triggerPressed
    props.clientX = pageX if pageX?
    props.clientY = pageY if pageY?
    new MouseEvent type, props
    
  createKeyEvent = (type, triggerPressed) ->
    props =
      view: window
      bubbles: true
      cancelable: true
      ctrlKey: triggerPressed
      altKey: triggerPressed
    new KeyboardEvent type, props
  
  beforeEach ->
    content = document.querySelector('link[rel="import"]').import
    importedBody = $(content).find "body"
    $("body").append "<div id='playground'></div>"
    $("#playground").append importedBody.html()
    window.location.hash = ""
  
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
    
  describe "the mousedown handler", ->

    describe "when the trigger keys are pressed", ->
      
      beforeEach ->
        @evt = createMouseEvent 'mousedown', true
        target = document.getElementById 'div1'
        target.dispatchEvent @evt
      
      it "sets the fragment/hash to the ID of the target", ->
        expect(window.location.hash).toBe "#div1"
      
      it "prevents default event handling", ->
        expect(@evt.defaultPrevented).toBe true
  
      it "removes any showing tooltip", ->
        expect(findTooltip().length).toBe 0

    describe "when the trigger keys are NOT pressed", ->
      
      beforeEach ->
        @evt = createMouseEvent 'mousedown', false
        target = document.getElementById 'div1'
        target.dispatchEvent @evt
  
      it "doesn't set the fragment/hash", ->
        expect(window.location.hash).toBe ""
    
    describe "when the fragment/hash is the same as the ID of the element being clicked", ->
      
      beforeEach ->
        window.location.hash = 'div1'
        @evt = createMouseEvent 'mousedown', true
        target = document.getElementById 'div1'
        target.dispatchEvent @evt
      
      it "ignores the event", ->
        expect(@evt.defaultPrevented).toBe false
  
  describe "the mousemove handler", ->
    
    describe "when the trigger keys are pressed", ->
      
      beforeEach ->
        @evt = createMouseEvent 'mousemove', true, 10, 10
        target = document.getElementById 'div1'
        target.dispatchEvent @evt
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
        target = document.getElementById 'div1'
        target.dispatchEvent createMouseEvent 'mousemove', true, 10, 10
        newTooltip = findTooltip()
        expect(newTooltip.length).toBe 1
  
      it "includes target element ID in the tooltip text", ->
        expect(@tooltip.text()).toContain "#div1"

      it "updates the tooltip text as the mouse is moved to another element", ->
        target = document.getElementById 'level1'
        target.dispatchEvent createMouseEvent 'mousemove', true, 10, 10
        expect(@tooltip.text()).toContain "#level1"

      it "makes the tooltip a child of the body element", ->
        expect(@tooltip[0].parentNode.tagName).toBe "BODY"

    describe "when the trigger keys are NOT pressed", ->
      
      beforeEach ->
        target = document.getElementById 'div1'
        target.dispatchEvent createMouseEvent 'mousemove', true, 10, 10
        target.dispatchEvent createMouseEvent 'mousemove', false, 10, 10
        @tooltip = findTooltip()
      
      it "removes any existing tooltip", ->
        expect(@tooltip.length).toBe 0
    
    describe "when the fragment/hash is the same as the ID of the element being entered", ->
      
      beforeEach ->
        window.location.hash = 'div1'
        target = document.getElementById 'div1'
        target.dispatchEvent createMouseEvent 'mousemove', true, 10, 10
        @tooltip = findTooltip()
      
      it "doesn't create a tooltip", ->
        expect(@tooltip.length).toBe 0

  describe "the mouseout handler", ->

    beforeEach ->
      target = document.getElementById 'div1'
      target.dispatchEvent createMouseEvent 'mousemove', true, 10, 10
      target.dispatchEvent createMouseEvent 'mouseout', true
      @tooltip = findTooltip()
    
    it "removes any tooltip", ->
      expect(@tooltip.length).toBe 0
    
    it "ignores non-existant tooltip", ->
      target = document.getElementById 'div1'
      target.dispatchEvent createMouseEvent 'mouseout', true
      expect(findTooltip().length).toBe 0
  
  describe "the keyup handler", ->

    describe "when the trigger keys are no longer pressed", ->
      
      beforeEach ->
        target = document.getElementById 'div1'
        target.dispatchEvent createMouseEvent 'mousemove', true, 10, 10
        target.dispatchEvent createKeyEvent 'keyup', false
        @tooltip = findTooltip()
      
      it "removes any tooltip", ->
        expect(@tooltip.length).toBe 0
      
      it "ignores non-existant tooltip", ->
        target = document.getElementById 'div1'
        target.dispatchEvent createKeyEvent 'keyup', false
        expect(findTooltip().length).toBe 0

    describe "when the trigger keys are still pressed", ->
      
      beforeEach ->
        target = document.getElementById 'div1'
        target.dispatchEvent createMouseEvent 'mousemove', true, 10, 10
        target.dispatchEvent createKeyEvent 'keyup', true
        @tooltip = findTooltip()
      
      it "doesn't remove any tooltip", ->
        expect(@tooltip.length).toBe 1

