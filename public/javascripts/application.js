// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// TODO: re-write and consolidate where needed

Event.observe(window, 'load', function(evt){
    InsertionMarker.init();
    InsertionBar.init();
    HoverHandle.init();
    
    Page.makeSortable();
});


// Handles the hover bar for modifying widgets 
var HoverHandle = {
    enabled: false,
    
    init: function() {
        this.current_handle = null;
        this.current_effect = null;
        this.enabled = true;
    },
    
    setEnabled: function(val) {
        this.enabled = val;
    },
    
    setHandle: function(handle) {
        // Cancel any running effects
        if (this.current_effect)
        {
            this.current_effect.cancel();
            if (this.current_handle)
                this.current_handle.setOpacity(1.0);
            this.current_effect = null;
        }
            
        // Different handle, make sure the old one is gone
        if (this.current_handle && this.current_handle != handle)
            this.current_handle.hide();
        
        // Show the new handle
        if (this.current_handle != handle || handle.style.display == 'none')
        {
            handle.setOpacity(1.0);
            handle.show();
        }
            
        // Disable insertion marker
        if (InsertionMarker.enabled)
        {
            InsertionMarker.setEnabled(false);
            InsertionMarker.hide();
        }
        
        this.current_handle = handle;
    },
    
    clearHandle: function() {
        if (!this.current_handle)
            return;
            
        if (!this.enabled)
        {
            this.current_handle.hide();
            return;
        }
        
        // Make sure the old one vanishes
        if (this.current_effect == null)
            this.current_effect = new Effect.Fade(this.current_handle, 
                                                 {duration: 0.8, 
                                                  afterFinish: function() { this.current_handle = null; this.current_effect = null; } 
                                                 });
        if (!InsertionMarker.enabled)
            InsertionMarker.setEnabled(true);
    }
};

// Insertion bar which appears between slots
var InsertionBar = {
    element: null,
    element_bar: null,
    element_tablet: null,
    current_form: null,
    
    init: function() {
        this.element = $('pageInsertItems');
        this.element_bar  = $('pageInsertItemsBar');
        this.element_tablet = $('pageTabletContainer');
    },
    show: function() {
        InsertionMarker.element.insert({after: this.element});
        this.element_bar.show();
    },
    hide: function() {
        this.element_bar.hide();
    },
    
    // Widget form
    set_widget_form: function(template) {
        if (this.current_form)
            this.clearWidgetForm();
        
        // Set insertion position
        $(template.id + 'Before').value = Page.insert_before ? '1' : '0';
        $(template.id + 'Slot').value = Page.insert_element.getAttribute('slot');
        
        // Form should go in the insertion bar, so we can change the insertion location and maintain
        // state
        this.element_tablet.insert(template);
        this.current_form = template;
    },
    
    clearWidgetForm: function() {
        $('pageWidgetForms').insert(this.current_form);
        this.current_form = null;
    }
};

// Insertion marker which appears between slots
var InsertionMarker = {
    element: null,
    enabled: false,
    
    init: function() {
        this.element = $('pageInsert');
        this.enabled = true;
    },
    setEnabled: function(val) {
        this.enabled = val;
    },
    show: function(el, insert_before) {
        el.insert(insert_before ? { before: this.element } :
                                  { after : this.element });
        this.element.show();
        this.set(el, insert_before);
    },
    hide: function() {
        this.element.hide();
        if (this.enabled)
            this.set(null, true);
    },
    set: function(element, insert_before) {
        var el = element ? element : $('slots').down('.pageSlot');
        
        Page.insert_element = el;
        Page.insert_before = insert_before;
    }
}

// Main page controller
var Page = {
    MARGIN: 20,
    SLOT_VERGE: 20,
    
    init: function() {
        Insertion.set(null);
    },
    
    insertWidget: function(resource) {
        // Insert 
        new Ajax.Request('/pages/' + PAGE_ID + '/' + resource, 
                        {
                            asynchronous:true, evalScripts:true,
                            method: 'post',
                            onComplete:function(request) { Event.addBehaviour.reload(); },
                            parameters: {'position[slot]': this.insert_element.getAttribute('slot') , 
                                         'position[before]': (this.insert_before ? '1' : '0'), 
                                         'authenticity_token' : AUTH_TOKEN}
                        });
    },
    
    makeSortable: function() {
        Sortable.create('slots', {handle: 'slot_handle', tag: 'div', only: 'pageSlot', 
                        onUpdate: function() { 
                          new Ajax.Request('/pages/' + PAGE_ID + '/reorder', 
                          {
                              asynchronous:true, evalScripts:false,
                              onComplete:function(request) {},
                              parameters:Sortable.serialize('slots', {name: 'slots'}) + '&authenticity_token=' + AUTH_TOKEN
                          });
                        
                        } });
    }
}


// Event handlers


// Hover observer for HoverHandle
document.observe('mousemove', function(evt){
    if (!HoverHandle.enabled)
        return;
    
    var el = evt.element();
    
    var hover = null;
    var handler = el.getAttribute('hover_handle');
    if (handler)
        hover = $(handler);
    else
        hover = el.up('.pageSlotHandle');
        
    if (hover)
        HoverHandle.setHandle(hover);
    else
        HoverHandle.clearHandle();
});

// Hover observer for InsertionMarker
document.observe('mousemove', function(evt){    
    if (!InsertionMarker.enabled)
        return;
    
    var el = evt.element();
    var pt = evt.pointer();
    var offset = el.cumulativeOffset();
    
    if (!(pt.x - offset.left > Page.MARGIN))
    {       
        if (el.hasClassName('pageSlot'))
        {   
            var h = el.getHeight(), thr = Math.min(h / 2, Page.SLOT_VERGE);
            var t = offset.top, b = t + h;
        
            if (el.hasClassName('pageFooter')) // before footer
                InsertionMarker.show(el, true);
            else if (pt.y - t <= thr) // before element
                InsertionMarker.show(el, true);
            else if (b - pt.y <= thr) // after element
                InsertionMarker.show(el, false);
            else
               InsertionMarker.hide(); // *poof*
        }
    }
    else
    {
        // Handle offset when hovering over insert bar
        if (el.id == "cpi") 
        {
            if (!(pt.x - offset.left > (48+Page.MARGIN)))
                return;
        }
        
        InsertionMarker.hide(); // *poof*
    }
});


// Behaviors


// Hover bar which appears when hovering over widgets
var HoverSlotBar = Behavior.create({
    onclick: function(e) {
        var el = e.element();
        e.stop();
        
        var url = this.element.up('.pageWidget').readAttribute('url');
        if (el.hasClassName('slot_delete')) return this._doDelete(url);
        if (el.hasClassName('slot_edit')) return this._doEdit(url);
    },
    
    _doDelete: function(resource) {
        new Ajax.Request('/pages/' + PAGE_ID + '/' + resource, 
                        {
                            asynchronous:true, evalScripts:true,
                            method: 'delete',
                            onComplete:function(request) { Event.addBehaviour.reload(); },
                            parameters:'authenticity_token=' + AUTH_TOKEN
                        });
    },
    
    _doEdit: function(resource) {
        //console.log('new ajax request');
        new Ajax.Request('/pages/' + PAGE_ID + '/' + resource + '/edit', 
                        {
                            asynchronous:true, evalScripts:true,
                            method: 'get',
                            onComplete:function(request) { Event.addBehavior.reload(); }
                        });
        
    }
});

// Link-up
Event.addBehavior({
    // Insert widgets
    '.add_List:click' : function(e) {
        Page.insertWidget('lists');
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
    },
    
    '.add_Note:click' : function(e) {
        //console.log('addNote: ');
        //console.log(Page.insert_element);
        // TODO: detect if this is on the bar. if not, reset insert point
        InsertionBar.set_widget_form($('add_NoteForm'));
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
    },
    
    '.addItem form:submit': function(e) {
        var el = e.element();
        e.stop();
        
        el.request({evalScripts:true,
            onComplete: function(transport){
                // 
                
                Event.addBehavior.reload();
                
                return;
            }
            });
    },
    
    // List item completion
    
    '.pageList .checkbox:click': function(e) {
        var el = e.element();
        e.stop();
        
        var list_url = el.up('.pageWidget').getAttribute('url');
        var item_id = el.parentNode.getAttribute('item_id');
        
        new Ajax.Request('/pages/' + PAGE_ID + '/' + list_url + '/items/' + item_id + '/status', 
                        {
                            asynchronous:true, evalScripts:true,
                            method: 'put',
                            onComplete:function(request) { },
                            parameters: {'list_item[completed]': el.checked,
                                        'authenticity_token': AUTH_TOKEN}
                        });
    },
    
    
    // Add list item handlers
    
    '.newItem a:click' : function(e) {
        var el = e.element();
        e.stop();
        
        var newItem = el.parentNode;
        var addItemInner = newItem.up('.addItem').down('.inner');
        
        addItemInner.show();
        newItem.hide();
    },
    
    '.cancel_addItemForm:click' : function(e) {
        var el = e.element();
        e.stop();
        
        var addItemInner = el.up('.inner');
        var newItem = addItemInner.up('.addItem').down('.newItem');
        
        addItemInner.hide();
        newItem.show();
    },
    
    
    // List edit form handlers
    
    '.pageListForm form:submit': function(e) {
        var el = e.element();
        e.stop();
        
        el.request({evalScripts:true,
            onComplete: function(transport){ }
            });
    },
    
    '.cancel_ListForm:click' : function(e) {
        var el = e.element();
        e.stop();
        
        var pageList = el.up('.pageList');
        
        pageList.down('.pageListForm').hide();
        pageList.down('.pageListHeader').show();
    },
    
    
    // Note form handlers
    
    '#add_NoteFormContent:submit': function(e) {
        var el = e.element();
        e.stop();
        
        el.request({evalScripts:true,
            onComplete: function(transport){
                // Clean up state
                InsertionBar.hide();
                InsertionBar.clearWidgetForm();
                
                Event.addBehavior.reload();
                
                return;
            }
            });
    },
    
    '#update_NoteFormContent:submit': function(e) {
        var el = e.element();
        e.stop();
        
        el.request({evalScripts:true,
            onComplete: function(transport){
                Event.addBehavior.reload();
                return;
            }
            });
    },
    
    // Widget forms
    '.cancel_WidgetForm:click' : function(e) {
        InsertionBar.clearWidgetForm();
    },
    
    // Insertion bars
    '#pageInsert:click' : function(e) {
        InsertionBar.show();
        InsertionMarker.setEnabled(false);
        HoverHandle.setEnabled(false);
        HoverHandle.clearHandle();
        InsertionMarker.hide();
    },
    '#pageInsertItemCancel a:click' : function(e) {
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
    },
    
    // Hover bars
    '.pageSlotHandle' : HoverSlotBar(),
});


