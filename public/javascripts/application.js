// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// TODO: re-write and consolidate where needed

// Quick jQuery extensions for missing prototype functions

jQuery.fn.extend({
  request: function( callback, type ) {
   var el = $(this[0]);
	 return jQuery.ajax({
	   type: el.attr('method'),
	   url: el.attr('action'),
	   data: el.serialize(),
	   success: callback,
	   dataType: type
	 });
	},
	
	autofocus: function() {
	  this.find('.autofocus:first').focus();
	}
});

/**
 * .disableTextSelect - Disable Text Select Plugin
 *
 * Version: 1.1
 * Updated: 2007-11-28
 *
 * Used to stop users from selecting text
 *
 * Copyright (c) 2007 James Dempster (letssurf@gmail.com, http://www.jdempster.com/category/jquery/disabletextselect/)
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 **/
(function($) {
    if ($.browser.mozilla) {
        $.fn.disableTextSelect = function() {
            return this.each(function() {
                $(this).css({
                    'MozUserSelect' : 'none'
                });
            });
        };
        $.fn.enableTextSelect = function() {
            return this.each(function() {
                $(this).css({
                    'MozUserSelect' : ''
                });
            });
        };
    } else if ($.browser.msie) {
        $.fn.disableTextSelect = function() {
            return this.each(function() {
                $(this).bind('selectstart.disableTextSelect', function() {
                    return false;
                });
            });
        };
        $.fn.enableTextSelect = function() {
            return this.each(function() {
                $(this).unbind('selectstart.disableTextSelect');
            });
        };
    } else {
        $.fn.disableTextSelect = function() {
            return this.each(function() {
                $(this).bind('mousedown.disableTextSelect', function() {
                    return false;
                });
            });
        };
        $.fn.enableTextSelect = function() {
            return this.each(function() {
                $(this).unbind('mousedown.disableTextSelect');
            });
        };
    }
})(jQuery);
/** END OF disableTextSelect **/


// jQuery object extensions

jQuery.extend({
  del: function( url, data, callback, type ) {
		if ( jQuery.isFunction( data ) ) {
			callback = data;
			data = {};
		}
		
		data = data == null ? {} : data;
		if (!data['_method'])
		{
		  if (typeof data == 'string')
		    data += '&_method=DELETE';
		  else
		    data['_method'] = 'DELETE';
		}

		return jQuery.ajax({
			type: "POST",
			url: url,
			data: data,
			success: callback,
			dataType: type
		});
	},
	
	put: function( url, data, callback, type ) {
		if ( jQuery.isFunction( data ) ) {
			callback = data;
			data = {};
		}
		
		data = data == null ? {} : data;
		if (!data['_method'])
		{
		  if (typeof data == 'string')
		    data += '&_method=PUT';
		  else
		    data['_method'] = 'PUT';
		}
		
		return jQuery.ajax({
			type: "POST",
			url: url,
			data: data,
			success: callback,
			dataType: type
		});
	}
});

// authenticity_token fix

$(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined" || request.type == 'GET') return;
  settings.data = settings.data ? (settings.data + '&') : "";
  settings.data += "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});

// Main entrypoint

$(document).ready(function(){
    InsertionMarker.init();
    InsertionBar.init();
    HoverHandle.init();
    
    Page.makeSortable();
    
    $('#content').mousemove(PageHoverHandlerFunc);
    $('#content').mouseout(PageHoverHandlerCancelFunc);
    
    $(this).mousemove(InsertionMarkerFunc);
    
    Page.bind();
    
    $('#pageResizeHandle').mousedown(Page.startResize);
});

// Handles the hover bar for modifying widgets 
var HoverHandle = {
    enabled: false,
    
    init: function() {
        this.current_handle = null;
        this.enabled = true;
    },
    
    setEnabled: function(val) {
        this.enabled = val;
    },
    
    setHandle: function(handle) {
        // Cancel any running effects
        if (this.current_handle)
            this.current_handle.stop().show().css('opacity', 1.0);
        
        var is_new = this.current_handle == null || (this.current_handle[0] != handle[0]);
        //if (is_new)
          //console.log('handle=' + handle.attr('id'), 'current_handle=' + (this.current_handle == null ? null : this.current_handle.attr('id')));
        
        // Different handle, make sure the old one is gone
        if (this.current_handle && is_new)
            this.current_handle.hide();
        
        // Show the new handle
        if (is_new || handle.is(':hidden'))
            handle.css('opacity', 1.0).show();
           
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
        if (!this.current_handle.is(':animated'))
           this.current_handle.fadeOut(800, function() { this.current_handle = null; });
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
        this.element = $('#pageInsertItems');
        this.element_bar  = $('#pageInsertItemsBar');
        this.element_tablet = $('#pageTabletContainer');
    },
    show: function() {
        InsertionMarker.element.before(this.element);
        this.element_bar.show();
    },
    hide: function() {
        this.element_bar.hide();
    },
    
    // Widget form
    setWidgetForm: function(template) {
        if (this.current_form)
            this.clearWidgetForm();
        
        // Set insertion position
        $('#' + template.attr('id') + 'Before').attr('value', Page.insert_before ? '1' : '0');
        $('#' + template.attr('id') + 'Slot').attr('value', Page.insert_element.attr('slot'));
        
        // Form should go in the insertion bar, so we can change the insertion location and maintain
        // state
        this.element_tablet.append(template);
        this.current_form = template;
    },
    
    clearWidgetForm: function() {
        if (!this.current_form)
          return;
        
        this.current_form.children('form').reset();
        $('#pageWidgetForms').append(this.current_form);
        this.current_form = null;
    }
};

// Insertion marker which appears between slots
var InsertionMarker = {
    element: null,
    enabled: false,
    visible: false,
    
    init: function() {
        this.element = $('#pageInsert');
        this.enabled = true;
        this.visible = false;
    },
    setEnabled: function(val) {
        this.enabled = val;
    },
    show: function(el, insert_before) {
        if (insert_before)
          el.before(this.element);
        else
          el.after(this.element);
        
        this.element.show();
        this.visible = true;
        this.set(el, insert_before);
    },
    hide: function() {
        if (this.visible) {
            this.element.hide();
            this.visible = false;
            if (this.enabled)
                this.set(null, true);
        }
    },
    set: function(element, insert_before) {
        var el = element ? element : $('#slots').children('.pageSlot:first');
        
        Page.insert_element = el;
        Page.insert_before = insert_before;
    }
}

// Main page controller
var Page = {
    MARGIN: 20,
    SLOT_VERGE: 20,
    
    isResizing: false,
    lastResizePosition: 0,
    
    init: function() {
      Insertion.set(null);
    },
    
    startResize: function(e) {
      var evt = e.originalEvent;
      Page.lastResizePosition = evt.clientX;
      Page.isResizing = true;
      
      InsertionMarker.setEnabled(false);
      HoverHandle.setEnabled(false);
      
      $('#body').css('cursor', 'move').disableTextSelect();
      $(document).mousemove(Page.doResize).mouseup(Page.endResize);
    },
    
    endResize: function(e) {
      Page.isResizing = false;
      
      InsertionMarker.setEnabled(true);
      HoverHandle.setEnabled(true);
      
      $('#body').css('cursor', 'default').enableTextSelect();
      
      $(document).unbind('mouseup', Page.endResize);
      $(document).unbind('mousemove', Page.doResize);
      
      $.put(Page.buildUrl('/resize'), {'page[width]': PAGE_WIDTH}, null, 'script');
    },
    
    doResize: function(e) {
      if (!Page.isResizing)
        return false;
      
      var evt = e.originalEvent;
      var delta = evt.clientX - Page.lastResizePosition;
      Page.setWidth(PAGE_WIDTH + delta);
      
      Page.lastResizePosition = evt.clientX;
    },
    
    setWidth: function(width) {
      PAGE_WIDTH = width;
      $('#content').css('width', PAGE_WIDTH + 'px');
      $('#innerWrapper').css('width', (PAGE_WIDTH + 200) + 'px');
    },
    
    buildUrl: function(resource_url) {
      if (PAGE_ID != null)
        return '/pages/' + PAGE_ID + resource_url;
      else
        return resource_url;
    },
    
    bind: function() {
      // NOTE: this is a mess, especially considering there are a ton
      //       of closures here. Need to tidy it up!
      
      $('.pageSlotHandle').click(HoverSlotBar);

      $('.widgetForm').submit(function(evt) {
        $(this).request(JustRebind, 'script');  
  
        return false;
      });

      $('.widgetForm .cancel').click(function(evt) {
        var form = $(evt.target).parents('form:first');
        
        $.get(form.attr('action'), {}, JustRebind, 'script');
        return false;
      });

      $('.fixedWidgetForm').submit(function(evt) {
        $(this).request(ResetAndRebind, 'script');
        
        return false;
      });

      $('.fixedWidgetForm .cancel').click(function(evt) {
        InsertionBar.clearWidgetForm();
        
        return false;
      });
      
      // Page header
      $('#page_header_form form').submit(function(evt) {
        $(this).request(JustRebind, 'script');

        return false;
      });

      $('#page_header_form .cancel').click(function(evt) {        
        $('#page_header_form').hide();
        $('#page_header').show();
        
        return false;
      });

// Insert widgets
      $('.add_List').click(function(evt) {
        // Set to top of page if on top toolbar
        if ($(this).hasClass('atTop'))
          InsertionMarker.set(null, false);

        Page.insertWidget('lists');
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
          
        return false;
      });

      $('.add_Note').click(function(evt) {
  // Set to top of page if on top toolbar
        if ($(this).hasClass('atTop'))
          InsertionMarker.set(null, false);
        
        var form = $('#add_NoteForm');
  
        InsertionBar.setWidgetForm(form);
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
        
        form.autofocus();
  
        return false;
      });

      $('.add_Separator').click(function(evt) {
        // Set to top of page if on top toolbar
        if ($(this).hasClass('atTop'))
          InsertionMarker.set(null, false);
        
        var form = $('#add_SeparatorForm');
  
        InsertionBar.setWidgetForm(form);
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
        
        form.autofocus();
  
        return false;
      });
      
      $('#pageInsert').click(function(evt) {
        InsertionBar.show();
        //console.log('IM SET');
        InsertionMarker.setEnabled(false);
        InsertionMarker.hide();
        //console.log('IM DONE');
        HoverHandle.setEnabled(false);
        HoverHandle.clearHandle();
        
        return false;
      });
      
      $('#pageInsertItemCancel a').click(function(evt) {
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
        
        return false;
      });
      
      $('#pageSetFavourite').click(function(evt) {
        $.put(Page.buildUrl('/favourite'), {'page[is_favourite]': '1'}, null, 'script');
        return false;
      });
      
      $('#pageSetNotFavourite').click(function(evt) {
        $.put(Page.buildUrl('/favourite'), {'page[is_favourite]': '0'}, null, 'script');
        return false;
      });
      
      $('#pageDuplicate').click(function(evt) {
        $.post(Page.buildUrl('/duplicate'), {'foo':1}, null, 'script');
        return false;
      });
      
      $('#pageDelete').click(function(evt) {
        if (confirm("Are you sure you want to delete this page?"))
          $.del(Page.buildUrl(''), {}, null, 'script');
        return false;
      });
      
      // Popup form for Add Item
      $('.addItem form').submit(function(evt) {
        var form = $(this);
        form.request(JustRebind, 'script')
        form.reset();
        return false;
      });
      
      $('.addItem form .cancel').click(function(evt) {
        var addItemInner = $(evt.target).parents('.inner:first');
        var newItem = addItemInner.parents('.addItem:first').find('.newItem:first');
        
        addItemInner.hide();
        addItemInner.children('form').reset();
        newItem.show();
        
        return false;
      });
      
      // Add Item link
      $('.newItem a').click(function(evt) {
        var newItem = $(evt.target.parentNode);
        var addItemInner = newItem.parents('.addItem:first').find('.inner:first');
        
        addItemInner.show();
        addItemInner.autofocus();
        newItem.hide();
        
        return false;
      });
      
      $('.listItem form').submit(function(evt) {
        $(this).request(JustRebind, 'script');
        
        return false;
      });
    
      $('.listItem form .cancel').click(function(evt) {
        var el = $(evt.target);
        var list_url = el.parents('.pageWidget:first').attr('url');
        var item_id = el.parents('.listItem:first').attr('item_id');
        
        $.get(Page.buildUrl(list_url + '/items/' + item_id), null, JustRebind, 'script');
        
        return false;
      });
      
      $('.pageList .checkbox').click(function(evt) {
        var el = $(evt.target);
        var list_url = el.parents('.pageWidget:first').attr('url');
        var item_id = el.parents('.listItem:first').attr('item_id');
        
        $.put(Page.buildUrl(list_url + '/items/' + item_id + '/status'), {'list_item[completed]':evt.target.checked}, JustRebind, 'script');
        
        return false;
      });
      
      $('.pageList .itemDelete').click(function(evt) {
        var el = $(evt.target);
        var list_url = el.parents('.pageWidget:first').attr('url');
        var item_id = el.parents('.listItem:first').attr('item_id');
        
        $.del(Page.buildUrl(list_url + '/items/' + item_id), null, JustRebind, 'script');
        
        return false;
      });
      
      $('.pageListForm form').submit(function(evt) {
        $(this).request(JustRebind, 'script');
        
        return false;
      });
    
      $('.pageListForm form .cancel').click(function(evt) {
        var el = $(evt.target);
        var pageList = el.parents('.pageList:first');
        
        pageList.find('.pageListForm:first').hide();
        pageList.find('.pageListHeader:first').show();
        
        return false;
      });
      
      // Page list tags
      $('.pageTagAdd').click(function(evt) {
        TAG_LIST.push($(evt.target).attr('tag'));
        
        $.get('/pages', {'tags[]': TAG_LIST}, JustRebind, 'script');
        return false;
      });
    
      $('.pageTagRemove').click(function(evt) {
        var removed_tag = $(evt.target).attr('tag');
        
        TAG_LIST = $.grep(TAG_LIST, function(tag){
          return (tag != removed_tag);
        });
        
        $.get('/pages', {'tags[]': TAG_LIST}, JustRebind, 'script');
        return false;
      });
     
      $('#pageEditTags .edit').click(function(evt) {
        $.get(Page.buildUrl('/tags'), {}, JustRebind, 'script');
        return false;
      });
    
      $('#pageTagsForm form').submit(function(evt) {
        $(this).request(JustRebind, 'script');
               
        return false;
      });
    
      $('#pageTagsForm .cancel').click(function(evt) {
        $('#pageTagsForm').hide();
        $('#pageTags').show();
        $('#pageEditTags').show();
        
        return false;
      });      
      
      // Reminder page
      
      $('#add_ReminderForm').submit(function(evt) {
        $(this).request(JustRebind, 'script');
        
        return false;
      });
      
      $('.reminderSnooze').click(function(evt) {
        var el = $(evt.target);
        var reminder_url = el.parents('.reminderEntry:first').attr('url') + '/snooze';
        $.put(reminder_url, {}, JustRebind, 'script');
        
        return false;
      });
      
      $('.reminderDelete').click(function(evt) {
        var el = $(evt.target);
        var reminder_url = el.parents('.reminderEntry:first').attr('url');
        
        $.del(reminder_url, {}, JustRebind, 'script');
        
        return false;
      });
      
      // Journal
      $('#edit_UserStatus').submit(function(evt) {
        $(this).request(JustRebind, 'script');
        
        return false;
      });
      
      $('#edit_UserStatus .cancel').click(function(evt) {
        
        $('#user_status_form').hide();
        $('#user_status').show();
        
        return false;
      });
    
      $('#user_status').click(function(evt) {
        if (this.tagName == 'A')
          return true;
        
        $('#user_status').hide();
        $('#user_status_form').show();
        
        return false;
      });
    
      $('#userJournal form').submit(function(evt) {
        var el = $(this);
        
        el.request(JustRebind, 'script');
            
        el.reset();
       
        return false;
      });
      
      // User list
      $('#userList .userDelete').click(function(evt) {
        var el = $(this);
        
        var user_id = el.parents('tr:first').attr('user_id');
        
        // TODO: need localization
        if (confirm('Are you sure you want to delete this user?'))
          $.del('/users/' + user_id, {}, JustRebind, 'script');
        
        return false;
      });
      
      $('#statusBar').click(function(evt) {
        $(this).hide('slow');
        
        return false;
      });
    
    
    },
    
    rebind: function () {
      $('.pageSlotHandle').unbind();
      $('.add_List').unbind();
      $('.add_Note').unbind();
      $('.add_Separator').unbind();
      $('.widgetForm').unbind();
      $('.fixedWidgetForm .cancel').unbind();
      $('.fixedWidgetForm').unbind();
      $('.fixedWidgetForm .cancel').unbind();
      $('#page_header_form form').unbind();
      $('#page_header_form .cancel').unbind();
      
      $('#pageInsert').unbind();
      $('#pageInsertItemCancel a').unbind();
      
      $('#pageSetFavourite').unbind();
      $('#pageSetNotFavourite').unbind();
      $('#pageDuplicate').unbind();
      $('#pageDelete').unbind();
      
      $('.addItem form').unbind();
      $('.addItem form .cancel').unbind();
      
      $('.newItem a').unbind();
      $('.listItem form').unbind();
      $('.listItem form .cancel').unbind();
      
      $('.pageList .checkbox').unbind();
      
      $('.pageListForm form').unbind();
      $('.pageListForm form .cancel').unbind();


      $('.pageTagAdd').unbind();
      $('.pageTagRemove').unbind();
      $('#pageEditTags .edit').unbind();
      $('#pageTagsForm form').unbind();
      $('#pageTagsForm .cancel').unbind();
      
      $('#add_ReminderForm').unbind();
      $('.reminderSnooze').unbind();
      $('.reminderDelete').unbind();

      $('#edit_UserStatus').unbind();
      $('#edit_UserStatus .cancel').unbind();
      $('#user_status').unbind();
      $('#userJournal form').unbind();
      
      $('#userList .userDelete').unbind();
      
      $('#statusBar').unbind();
      Page.bind();
    },
    
    setFavourite: function(favourite) {
        if (favourite)
        {
            $('#pageSetFavourite').hide();
            $('#pageSetNotFavourite').show();
        }
        else
        {
            $('#pageSetNotFavourite').hide();
            $('#pageSetFavourite').show();
        }
    },
    
    insertWidget: function(resource) {
        if (PAGE_READONLY)
            return;
        
        // Insert
        $.post('/pages/' + PAGE_ID + '/' + resource, 
              {'position[slot]': this.insert_element.attr('slot') , 
               'position[before]': (this.insert_before ? '1' : '0')}, ResetAndRebind, 'script');
    },
    
    makeSortable: function() {
        if (PAGE_READONLY)
            return;
        
        var lists = $('.pageList .openItems .listItems');
        
        lists.each(function(i) {
          Page.makeListSortable($(this));
        });
        
        // Refresh so we can drag between
        lists.each(function(i) {//console.log(this);
          $(this).sortable('refresh');
        });
        
        // Add droppables
       $('#pageListItems li').each(function(i) {
        var el = $(this);
        if (!el.hasClass('current')) {
          el.droppable('destroy');
          el.droppable({ hoverClass:'hover', accept:'.pageSlot', drop: function(ev, ui) { Page.moveSlotTo(ui.draggable.attr('slot'), $(this).attr('page_id')); } });
        }
       });
       
       $('#slots').sortable('destroy');
       $('#slots').sortable({
         axis: 'y',
         handle: '.slot_handle',
         items: '> .pageSlot',
         opacity: 0.75,
         update: function(e, ui) {
           $.post('/pages/' + PAGE_ID + '/reorder', $('#slots').sortable('serialize', {key: 'slots'}));
         }
       });                           
    },
    
    moveSlotTo: function(slot_id, page_id) {
        $.put('/pages/' + page_id + '/' + 'transfer', {'page_slot[id]': slot_id }, null, 'script');
    },
    
    makeListSortable: function(el) {
        var list_url = el.parents('.pageWidget:first').attr('url');
        
        el.sortable('destroy');
        el.sortable({
          axis: 'y',
          handle: '.slot_handle',
          connectWith: ['.pageList .openItems .listItems'],
          opacity: 0.75,
          update: function(e, ui) {
            // Check for item movement vs item update. Note that the 
            // list the item is moved to will do its own update after.
            
            var list = ui.item.parent('.listItems');
            if (list.attr('id') !=
                ui.element.attr('id'))
              $.put('/pages/' + PAGE_ID + list.parents('.pageWidget:first').attr('url') + '/transfer', {'list_item[id]': ui.item.attr('item_id')});
            else
              $.post('/pages/' + PAGE_ID + list_url + '/reorder', el.sortable('serialize', {key: 'items'}));
          }
        }); 
    }
}


// Event handlers


// Hover observer for HoverHandle
var PageHoverHandlerFunc = function(evt){
    if (!HoverHandle.enabled)
        return;
    
    var el = $(evt.target);
    
    var hover = null;
    var handler = el.attr('hover_handle');
    if (handler)
        hover = $('#' + handler);
    else if (el.hasClass('innerHandle'))
        hover = el.parents('.pageSlotHandle:first');
    
    if (hover)
        HoverHandle.setHandle(hover);
    else
        HoverHandle.clearHandle();
};

var PageHoverHandlerCancelFunc = function(evt){
    HoverHandle.clearHandle();
};

// Hover observer for InsertionMarker
var InsertionMarkerFunc = function(evt){    
    if (!InsertionMarker.enabled)
        return;
    
    var el = $(evt.target);
    var pt = [evt.clientX, evt.clientY];
    pt.x = pt[0]; pt.y = pt[1];
    var offset = el.offset();
    
    if (!(pt.x - offset.left > Page.MARGIN))
    {
        if (el.hasClass('pageSlot'))
        {
            var h = el.height(), thr = Math.min(h / 2, Page.SLOT_VERGE);
            var t = offset.top, b = t + h;
        
            if (el.hasClass('pageFooter')) // before footer
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
        if (el.attr('id') == "cpi") 
        {
            if (!(pt.x - offset.left > (48+Page.MARGIN)))
                return;
        }
        
        InsertionMarker.hide(); // *poof*
    }
};

function JustRebind(data) {
  Page.rebind();
}

function ResetAndRebind(data) {
  // Clean up state
  InsertionBar.hide();
  InsertionBar.clearWidgetForm();
  
  Page.rebind();
}

// Hover bar which appears when hovering over widgets

function HoverSlotBar(evt) {
  var el = $(evt.target);
  var cur = $(this);
  
  var url = cur.parents(cur.attr('restype') + ':first').attr('url');
  
  if (el.hasClass('slot_delete'))
    $.del(Page.buildUrl(url), null, JustRebind, 'script');
  else if (el.hasClass('slot_edit'))
    $.get(Page.buildUrl(url + '/edit'), null, JustRebind, 'script');
  else
    return false;
  
  return true;
}
