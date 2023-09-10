import { Controller } from "@hotwired/stimulus";
import $ from "cash-dom";
import Sortable from 'sortablejs';

import RucksackHelpers from "helpers/rucksack_helpers";
import HoverHandle from "helpers/hover_handle";
import InsertionBar from "helpers/insertion_bar";
import InsertionMarker from "helpers/insertion_marker";
import Velocity from "velocity-animate";

// Main page controller
export default class extends Controller
{
  init() {
    this.MARGIN = 20;
    this.SLOT_VERGE = 20;

    this.isResizing = false;
    this.lastResizePosition = 0;

    this.isSortingWrappedElements = false;
    this.TAG_LIST = [];
    this.ID = null;
    this.TYPE = null;
    this.READONLY = true;

    this.insertionMarker = new InsertionMarker(this);
    this.insertionBar = new InsertionBar(this);
    this.hoverHandle = new HoverHandle(this);

    this.staticBoundEvents = [];
    this.dynamicBoundEvents = [];
    this.listItemSortables = null;

    this.activeTimers = [];
  }

  connect() {
    window.Page = this;

    console.log('Connecting page controller....', this.element);
    this.init();

    this.bindStaticEvent($('#content'), 'mousemove', this.handlePageHoverHandlerFunc.bind(this));
    this.bindStaticEvent($('#content'), 'mouseout', this.handlePageHoverHandlerCancelFunc.bind(this));
    this.bindStaticEvent($('#outerWrapper'), 'mousemove', this.handleInsertionMarkerFunc.bind(this));
    this.bindStaticEvent($('#pageResizeHandle'), 'mousedown', this.startResize.bind(this));

    this.bindStatic();
    this.bindDynamic();

    this.TYPE = this.lookupMeta('page-type', null);
    this.ID = this.lookupMeta('page-id', null);
    this.READONLY = this.lookupMeta('page-readonly', false);
    this.WIDTH = parseInt(this.lookupMeta('page-width', '400'));

    if (this.TYPE == 'page')
    {
      if (!this.READONLY)
      {
        this.insertionMarker.init();
        this.insertionBar.init();
        this.insertionMarker.set(null);
      }
    }
    else if (this.TYPE == 'pages')
    {
        //this.TAG_LIST = $('#tagNewCrumbs .tagCrumb span.pageTagAdd').map(function(){
        //  return $(this).attr('tag');
        //});
    }

    // Set tags if present
    var meta_tags = $('#tagCrumbsWrapper');
    if (meta_tags.length > 0)
    {
      var tags = JSON.parse(meta_tags.attr('meta-search-tags'));
      this.TAG_LIST = tags;
      this.updateTags();
    }

    this.hoverHandle.init();
    this.makeSortable();
  }

  lookupMeta(key, def) {
    var meta = $('meta[name="' + key + '"]');
    return meta.length > 0 ? meta.attr('content') : def;
  }

  updateTags() {
    var filter_tags = this.TAG_LIST;
    if (filter_tags.length == 0)
    {
      $('#pageTable .pageEntry').show();
      return;
    }

    $('#pageTable .pageEntry').each(function(){
      var el = $(this);
      var element_tags = el.attr('tags').split(',');
      var i=0;

      var isAnyItemPresent = filter_tags.some(item => element_tags.includes(item));

      if (isAnyItemPresent)
      {
        el.show();
      }
      else
      {
        el.hide();
      }
    });
  }

  disconnect() {
    this.clearDynamicEvents();
    this.clearStaticEvents();
    this.clearTimers();

    window.Page = null;
  }

  bumpJournalEntries(last_id) {
    $('#userJournalsMore').attr('from', last_id);
  }

  insertJournalEntries(header, content, before) {
    if (before)
    {
      var existing_header = $($('#userJournals h2')[0]);
      if (existing_header.html() == header)
        existing_header.remove();

      $('#userJournals').prepend(content);
    }
    else
    {
      $('#userJournals').append(content);
    }
  }

  endJournalEntries() {
    $("#userJournalsMore").remove();
  }

  completeTimer(timerID) {
    RucksackHelpers.put(this.buildUrl('/journals/' + timerID + '/stop_timer'), {}, null);
  }

  replaceJournalEntry(elementID, content) {
    $(elementID).replaceWith(content);
  }

  clearTimers() {

  }

  stopSortingWrappedElements(item) {
    // Need to re-incorporate the elements
    var elements_after = item.children(":last").children();

    for (var i=elements_after.length-1; i >= 0; i--) {
      $(elements_after[i]).insertAfter(item);
    }

    this.isSortingWrappedElements = false;
  }

  startResize = (evt) => {
    evt.preventDefault();
    this.lastResizePosition = evt.clientX;
    this.isResizing = true;

    this.insertionMarker.setEnabled(false);
    this.hoverHandle.setEnabled(false);

    var content = $('#innerWrapper');
    content.css('margin', '0px 0px 0px ' + content.offset().left + 'px');

    var el = $(evt.target);
    this.bindDynamicEvent(el, 'mouseup', this.endResize.bind(this));
    this.bindDynamicEvent(el, 'mousemove', this.doResize.bind(this));
  }

  endResize = (evt) => {
    evt.preventDefault();
    this.isResizing = false;

    this.insertionMarker.setEnabled(true);
    this.hoverHandle.setEnabled(true);

    var content = $('#innerWrapper');
    content.css('margin', '0px auto');

    this.removeDynamicEvents($(evt.target));

    RucksackHelpers.put(this.buildUrl('/resize'), {'page':{'width': this.WIDTH}}, null);
  }

  doResize(evt) {
    if (!this.isResizing)
      return false;

    var delta = evt.clientX - this.lastResizePosition;
    this.setWidth(this.WIDTH + delta);

    this.lastResizePosition = evt.clientX;
  }

  setWidth(width) {
    this.WIDTH = width;
    $('#content').css('width', this.WIDTH + 'px');
    $('#innerWrapper').css('width', (this.WIDTH + 200) + 'px');
  }

  buildUrl(resource_url) {
    if (this.ID != null && !resource_url.includes('/pages/' + this.ID))
      return '/pages/' + this.ID + resource_url;
    else
      return resource_url;
  }

    //
    // Core re-bindable actions
    //

  onHeaderSubmit(evt) {
    evt.preventDefault();
    

      //await fetch(`/search?query=${query}`);
    RucksackHelpers.request($(evt.target), this.JustRebind.bind(this));

    return false;
  }

  onHeaderCancel(evt) {
    evt.preventDefault();
    
    $('#page_header_form').hide();
    $('#page_header').show();

    return false;
  }

  setFormLoading(form_el, loading) {
    var submit_button = form_el.find('.submit').first();
    if (!loading)
    {
      submit_button.attr('disabled', false);
      form_el.removeClass('loading');
    }
    else
    {
      submit_button.attr('disabled', true);
      form_el.addClass('loading');
    }
  }

  onWidgetFormSubmit(evt) {
    var el = $(evt.target);
    el.find('input[name=is_new]').attr('value', '0');

    this.setFormLoading(el, true);

    if (el.hasClass('upload'))
    {
      RucksackHelpers.request(el, () => {this.setFormLoading(el, false); this.JustRebind.bind(this)});
      return true;
    }
    else
    {
      evt.preventDefault();
      RucksackHelpers.request(el, () => {this.setFormLoading(el, false); this.JustRebind.bind(this)});
    }

    return false;
  }

  onWidgetFormCancel(evt) {
    evt.preventDefault();
    
    var form = $(evt.target).parents('form').first();

    RucksackHelpers.get(form.attr('action'), {}, this.JustRebind.bind(this));

    return false;
  }

  onFixedWidgetFormSubmit(evt) {

    var el = $(evt.target);
    var submit_button = el.find('.submit').first();
    var pageController = this;

    // Loader
    var old_submit = submit_button.html();
    pageController.setFormLoading(el, true);

    // Note: closures used here so that submit button can be reset
    if (el.hasClass('upload')) 
    {
      evt.preventDefault();
      el.find('input[name=is_new]').attr('value', '1');
      RucksackHelpers.request(el, function(data) { 
        pageController.setFormLoading(el, true); 
        pageController.ResetAndRebind(data); 
      });
      return true;
    }
    else
    {
      evt.preventDefault();
      el.find('input[name=is_new]').attr('value', '0');
      RucksackHelpers.request(el, function(data) { 
        pageController.setFormLoading(el, true);
        pageController.ResetAndRebind(data); 
      });
    }

    return false;
  }

  onFixedWidgetFormCancel(evt) {
    evt.preventDefault();

    console.log('onFixedWidgetFormCancel')
    this.insertionBar.clearWidgetForm();

    return false;
  }

  onAddItemSubmit(evt) {
    evt.preventDefault();
    
    var form = $(evt.target);
    RucksackHelpers.request(form, this.JustRebind.bind(this))
    form[0].reset();
    return false;
  }

  onAddItemCancel(evt) {
    evt.preventDefault();
    
    var addItemInner = $(evt.target).parents('.inner').first();
    var newItem = addItemInner.parents('.addItem').first().find('.newItem').first();

    addItemInner.hide();
    addItemInner.children('form')[0].reset();
    newItem.show();

    return false;
  }

  onAddItemLink(evt) {
    evt.preventDefault();
    
    var newItem = $(evt.target.parentNode);
    var addItemInner = newItem.parents('.addItem').first().find('.inner').first();

    addItemInner.show();
    addItemInner.autofocus();
    newItem.hide();

    return false;
  }

  onListSubmit(evt) {
    evt.preventDefault();
    RucksackHelpers.request($(evt.target), this.JustRebind.bind(this));

    return false;
  }

  onListCancel(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    var list_url = el.parents('.pageWidget').first().attr('url');
    var item_id = el.parents('.listItem').first().attr('item_id');

    RucksackHelpers.get(this.buildUrl(list_url + '/items/' + item_id), null, this.JustRebind.bind(this));

    return false;
  }

  onListItemCheck(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    var list_url = el.parents('.pageWidget').first().attr('url');
    var item_id = el.parents('.listItem').first().attr('item_id');

    // Loader gif
    //el.siblings('.itemText').html(this.loader());

    RucksackHelpers.put(this.buildUrl(list_url + '/items/' + item_id + '/status'), {'list_item': {'completed':evt.target.checked}}, this.JustRebind.bind(this));

    return false;
  }

  onListItemDelete(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    var list_url = el.parents('.pageWidget').first().attr('url');
    var item_id = el.parents('.listItem').first().attr('item_id');

    RucksackHelpers.del(this.buildUrl(list_url + '/items/' + item_id), null, this.JustRebind.bind(this));

    return false;
  }

  onListItemShowMore(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    var list_url = el.parents('.pageWidget').first().attr('url');

    el.parent().hide();
    RucksackHelpers.get(this.buildUrl(list_url + '/items'), {'completed':1, 'limit':-1, 'offset': 5}, this.JustRebind.bind(this));

    return false;
  }

  onListItemSubmit(evt) {
    evt.preventDefault();
    RucksackHelpers.request($(evt.target), this.JustRebind.bind(this));

    return false;
  }

  onListItemCancel(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    var pageList = el.parents('.pageList').first();

    pageList.find('.pageListForm').first().hide();
    pageList.find('.pageListHeader').first().show();

    return false;
  }

  onAlbumSubmit(evt) {
    evt.preventDefault();
    RucksackHelpers.request($(evt.target), this.JustRebind.bind(this));  

    return false;
  }

  onAlbumCancel(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    var pageAlbum = el.parents('.pageAlbum').first();

    pageAlbum.find('.pageAlbumForm').first().hide();
    pageAlbum.find('.pageAlbumHeader').first().show();

    return false;
  }

  onAddAlbumPicture(evt) {
    evt.preventDefault();
    var newPicture = $(evt.target.parentNode);
    var addPictureInner = newPicture.parents('.albumPictureForm').first().find('.inner').first();

    addPictureInner.show();
    addPictureInner.autofocus();
    newPicture.hide();

    return false;
  }

  onAlbumPictureSubmit(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    el.find('input[name=is_new]').attr('value', '0');
    el.find('input[name=el_id]').attr('value', '');
    RucksackHelpers.request(el, this.JustRebind.bind(this));
    return true;
  }

  onAlbumPictureCancel(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    RucksackHelpers.get(el.parents('form').first().attr('action'), null, this.JustRebind.bind(this));
    return false;
  }

  onNewAlbumPictureSubmit(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    el.find('input[name=is_new]').attr('value', '1');
    el.find('input[name=el_id]').attr('value', el.parents(".albumPictureForm").first().attr("id"));
    RucksackHelpers.request(el, this.JustRebind.bind(this));
    return true;
  }

  onNewAlbumPictureCancel(evt) {
    evt.preventDefault();
    var newPictureInner = $(evt.target).parents('.inner').first();
    var newPicture = newPictureInner.parents('.albumPictureForm').first().find('.newPicture').first();

    newPictureInner.hide();
    newPictureInner.children('form')[0].reset();
    newPicture.show();

    return false;
  }

  onEditTags(evt) {
    evt.preventDefault();
    RucksackHelpers.request($(evt.target), this.JustRebind.bind(this));

    return false;
  }

  onEditTagsCancel(evt) {
    evt.preventDefault();
    $('#pageTagsForm').hide();
    $('#pageTags').show();
    $('#pageEditTags').show();

    return false;
  }

  onTagAdd(evt) {
    evt.preventDefault();
    var crumb = $(evt.target.parentNode);
    var tagName = crumb.attr('tag');
    if (this.TAG_LIST.indexOf(tagName) >= 0)
      return;

    this.TAG_LIST.push(tagName);
    $('#tagCrumbs').append(crumb);
    this.updateTags();

    return false;
  }

  onTagRemove(evt) {
    evt.preventDefault();
    var crumb = $(evt.target.parentNode);
    var tagName = crumb.attr('tag');

    this.TAG_LIST = this.TAG_LIST.filter((tag) => {
      return (tag != tagName);
    });

    $('#tagNewCrumbs').append(crumb);
    this.updateTags();

    return false;
  }

  onReminderSnooze(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    var reminder_url = el.parents('.reminderEntry').first().attr('url') + '/snooze';
    RucksackHelpers.put(reminder_url, {}, this.JustRebind.bind(this));

    return false;
  }

  onReminderDelete(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    var reminder_url = el.parents('.reminderEntry').first().attr('url');

    RucksackHelpers.del(reminder_url, {}, this.JustRebind.bind(this));

    return false;
  }

  onReminderSubmit(evt) {
    evt.preventDefault();
    RucksackHelpers.request($(evt.target), this.RebindAndHover.bind(this));

    return false;
  }

  onReminderCancel(evt) {
    evt.preventDefault();
    RucksackHelpers.get('/reminders', {}, this.JustRebind.bind(this));

    this.hoverHandle.setEnabled(true);

    return false;
  }

    // User list
  onUserDelete(evt) {
    evt.preventDefault();
    var el = $(evt.target);

    var user_id = el.parents('tr').first().attr('user_id');

    // TODO: need localization
    if (confirm('Are you sure you want to delete this user?'))
      RucksackHelpers.del('/users/' + user_id, {}, this.JustRebind.bind(this));

    return false;
  }


  // Hover bar which appears when hovering over widgets
  handleHoverSlotBar(evt) {
    evt.preventDefault();
    var el = $(evt.target);
    var cur = el;
    console.log("HANDLE SLOT HOVER", el[0]);

    var root = el.closest('.pageSlotHandle');

    var url_element = root.parents(root.attr('restype')).first();
    var url = url_element.attr('url');

    console.log(this.buildUrl(url + '/edit'));

    if (el.hasClass('slot_delete') && confirm("Are you sure you want to delete this item?"))
    {
      RucksackHelpers.del(this.buildUrl(url), null, this.JustRebind.bind(this));
    }
    else if (el.hasClass('slot_edit'))
    {
      RucksackHelpers.get(this.buildUrl(url + '/edit'), null, this.JustRebind.bind(this));
    }
  }

  bindDynamicEvent(el, name, func) {
    this.dynamicBoundEvents.push([el, name, func]);
    el.on(name, func);
  }

  removeDynamicEvents(el) {
    for (var i=this.dynamicBoundEvents.length-1; i>= 0; i--)
    {
      var evt = this.dynamicBoundEvents[i];
      console.log(evt);
      if (evt[0][0] == el[0])
      {
        evt[0].off(evt[1]);
      }

      this.dynamicBoundEvents.splice(i);
    }
  }

  bindStaticEvent(el, name, func) {
    this.staticBoundEvents.push([el, name, func]);
    el.on(name, func);
  }

  clearDynamicEvents() {
    this.dynamicBoundEvents.forEach((item) => {
      item[0].off(item[1], item[2]);
    });
    this.dynamicBoundEvents = [];
  }

  clearStaticEvents() {
    this.staticBoundEvents.forEach((item) => {
      item[0].off(item[1], item[2]);
    });
    this.staticBoundEvents = [];
  }

  bindDynamic() {

    this.clearDynamicEvents();

      // Page header
    this.bindDynamicEvent($('#page_header_form form'), 'submit', this.onHeaderSubmit.bind(this));
    this.bindDynamicEvent($('#page_header_form .cancel'), 'click', this.onHeaderCancel.bind(this));

    this.bindDynamicEvent($('.pageSlotHandle ul.innerHandle li'), 'click', this.handleHoverSlotBar.bind(this));

    this.bindDynamicEvent($('.widgetForm'), 'submit', this.onWidgetFormSubmit.bind(this));
    this.bindDynamicEvent($('.widgetForm .cancel'), 'click', this.onWidgetFormCancel.bind(this));

    this.bindDynamicEvent($('.fixedWidgetForm'), 'submit', this.onFixedWidgetFormSubmit.bind(this));
    this.bindDynamicEvent($('.fixedWidgetForm .cancel'), 'click', this.onFixedWidgetFormCancel.bind(this));

      // Popup form for Add Item
    this.bindDynamicEvent($('.addItem form'), 'submit', this.onAddItemSubmit.bind(this));
    this.bindDynamicEvent($('.addItem form .cancel'), 'click', this.onAddItemCancel.bind(this));

      // Add Item link
    this.bindDynamicEvent($('.newItem a'), 'click', this.onAddItemLink.bind(this));
    this.bindDynamicEvent($('.listItem form'), 'submit', this.onListSubmit.bind(this));
    this.bindDynamicEvent($('.listItem form .cancel'), 'click', this.onListCancel.bind(this));

    this.bindDynamicEvent($('.pageList .checkbox'), 'click', this.onListItemCheck.bind(this));
    this.bindDynamicEvent($('.pageList .itemDelete'), 'click', this.onListItemDelete.bind(this));

    this.bindDynamicEvent($('.pageList .showItems a'), 'click', this.onListItemShowMore.bind(this));

    this.bindDynamicEvent($('.pageListForm form'), 'submit', this.onListItemSubmit.bind(this));
    this.bindDynamicEvent($('.pageListForm form .cancel'), 'click', this.onListItemCancel.bind(this));

      // Page album
    this.bindDynamicEvent($('.pageAlbumForm'), 'submit', this.onAlbumSubmit.bind(this));
    this.bindDynamicEvent($('.pageAlbumForm .cancel'), 'click', this.onAlbumCancel.bind(this));

    this.bindDynamicEvent($('.newPicture a'), 'click', this.onAddAlbumPicture.bind(this));

      // Edit picture form
    this.bindDynamicEvent($('.albumPicture form'), 'submit', this.onAlbumPictureSubmit.bind(this));
    this.bindDynamicEvent($('.albumPicture form .cancel'), 'click', this.onAlbumPictureCancel.bind(this));

      // New picture form
    this.bindDynamicEvent($('.albumPictureForm form'), 'submit', this.onNewAlbumPictureSubmit.bind(this));
    this.bindDynamicEvent($('.albumPictureForm form .cancel'), 'click', this.onNewAlbumPictureCancel.bind(this));

      // Page list tags
    this.bindDynamicEvent($('#pageTagsForm form'), 'submit', this.onEditTags.bind(this));
    this.bindDynamicEvent($('#pageTagsForm .cancel'), 'click', this.onEditTagsCancel.bind(this));  

      // + -
    this.bindDynamicEvent($('.pageTagAdd'), 'click', this.onTagAdd.bind(this));
    this.bindDynamicEvent($('.pageTagRemove'), 'click', this.onTagRemove.bind(this)); 

      // Reminder page

    this.bindDynamicEvent($('.reminderSnooze'), 'click', this.onReminderSnooze.bind(this));
    this.bindDynamicEvent($('.reminderDelete'), 'click', this.onReminderDelete.bind(this));
    this.bindDynamicEvent($('.reminderForm'), 'submit', this.onReminderSubmit.bind(this));
    this.bindDynamicEvent($('.reminderForm .cancel'), 'click', this.onReminderCancel.bind(this));

      // User list
    this.bindDynamicEvent($('#userList .userDelete'), 'click', this.onUserDelete.bind(this));

    // Journal time
    this.bindDynamicEvent($('.journalEntry .entryTime.active'), 'click', (evt) => { this.completeTimer($(evt.target).parents('.journalEntry').first().attr('journal_id')); } );
  }

  // Handlers

  handleAddList(evt) {
    evt.preventDefault();
    // Set to top of page if on top toolbar
    if ($(evt.target).hasClass('atTop'))
      this.insertionMarker.set(null, true);

    this.insertWidget('lists');
    this.insertionBar.hide();
    this.insertionMarker.setEnabled(true);
    this.hoverHandle.setEnabled(true);

    return false;
  }

  bindStatic() {

    var pageController = this;

    console.log('bindStatic called');

      // Insert widgets
    this.bindStaticEvent($('.add_List'), 'click', function(evt) {
      evt.preventDefault();

      // Set to top of page if on top toolbar
      if ($(this).hasClass('atTop'))
        pageController.insertionMarker.set(null, true);

      pageController.insertWidget('lists');
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      return false;
    });

    this.bindStaticEvent($('.add_Note'), 'click', function(evt) {
      evt.preventDefault();
      
        // Set to top of page if on top toolbar
      if ($(this).hasClass('atTop'))
        pageController.insertionMarker.set(null, true);

      var form = $('#add_NoteForm');

      pageController.insertionBar.setWidgetForm(form);
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      form.autofocus();

      return false;
    });

    this.bindStaticEvent($('.add_Separator'), 'click', function(evt) {
      evt.preventDefault();
      
        // Set to top of page if on top toolbar
      if ($(this).hasClass('atTop'))
        pageController.insertionMarker.set(null, true);

      var form = $('#add_SeparatorForm');

      pageController.insertionBar.setWidgetForm(form);
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      form.autofocus();

      return false;
    });

    this.bindStaticEvent($('.add_UploadedFile'), 'click', function(evt) {
      evt.preventDefault();
      
        // Set to top of page if on top toolbar
      if ($(this).hasClass('atTop'))
        pageController.insertionMarker.set(null, true);

      var form = $('#add_UploadedFileForm');

      pageController.insertionBar.setWidgetForm(form);
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      form.autofocus();

      return false;
    });

    this.bindStaticEvent($('.add_Album'), 'click', function(evt) {
      evt.preventDefault();
      
        // Set to top of page if on top toolbar
      if ($(this).hasClass('atTop'))
        pageController.insertionMarker.set(null, true);

      var form = $('#add_AlbumForm');

      pageController.insertionBar.setWidgetForm(form);
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      form.autofocus();

      return false;
    });

      // Page

    this.bindStaticEvent($('#pageInsert'), 'click', function(evt) {
      evt.preventDefault();
      
      pageController.insertionBar.show();
        //console.log('IM SET');
      pageController.insertionMarker.setEnabled(false);
      pageController.insertionMarker.hide();
        //console.log('IM DONE');
      pageController.hoverHandle.setEnabled(false);
      pageController.hoverHandle.clearHandle();

      return false;
    });

    this.bindStaticEvent($('#pageInsertItemCancel a'), 'click', function(evt) {
      evt.preventDefault();
      
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      return false;
    });

    this.bindStaticEvent($('#pageSetFavourite'), 'click', function(evt) {
      evt.preventDefault();
      
      RucksackHelpers.put(pageController.buildUrl('/favourite'), {'page':{'is_favourite': 1}}, null);
      return false;
    });

    this.bindStaticEvent($('#pageSetNotFavourite'), 'click', function(evt) {
      evt.preventDefault();
      
      RucksackHelpers.put(pageController.buildUrl('/favourite'), {'page':{'is_favourite': 0}}, null);
      return false;
    });

    this.bindStaticEvent($('#pageDuplicate'), 'click', function(evt) {
      evt.preventDefault();
      
      RucksackHelpers.post(pageController.buildUrl('/duplicate'), {'foo':1}, null);
      return false;
    });

    this.bindStaticEvent($('#pageDelete'), 'click', function(evt) {
      evt.preventDefault();
      
      if (confirm("Are you sure you want to delete this page?"))
        RucksackHelpers.del(pageController.buildUrl(''), {}, null);
      return false;
    });

    this.bindStaticEvent($('#pageAddress'), 'click', function(evt) {
      evt.preventDefault();
      
      if (evt.target.id == 'pageReset') {
        RucksackHelpers.put(pageController.buildUrl('/reset_address'), {}, null);
        return false;
      }

      return true;
    });

      // Page list tags
    this.bindStaticEvent($('#pageEditTags .edit'), 'click', function(evt) {
      evt.preventDefault();
      RucksackHelpers.get(pageController.buildUrl('/tags'), {}, pageController.JustRebind.bind(pageController));
      return false;
    });

      // Reminder page

    this.bindStaticEvent($('#add_ReminderForm'), 'submit', function(evt) {
      evt.preventDefault();
      
      RucksackHelpers.request($(this), pageController.JustRebind.bind(pageController));

      return false;
    });

      // Journal
    this.bindStaticEvent($('#edit_UserStatus'), 'submit', function(evt) {
      evt.preventDefault();
      
      RucksackHelpers.request($(this), pageController.JustRebind.bind(pageController));

      return false;
    });

    this.bindStaticEvent($('#edit_UserStatus .cancel'), 'click', function(evt) {
      evt.preventDefault();

      $('#user_status_form').hide();
      $('#user_status').show();

      return false;
    });

    this.bindStaticEvent($('#user_status'), 'click', function(evt) {
      if (this.tagName == 'A')
        return true;

      evt.preventDefault();
      
      $('#user_status_form').show();
      $('#user_status').hide();

      return false;
    });

    this.bindStaticEvent($('#userJournal form'), 'submit', function(evt) {
      evt.preventDefault();
      
      var el = $(this);
      if (!el)
        return false;

      RucksackHelpers.request(el, pageController.JustRebind.bind(pageController));

      el[0].reset();

      return false;
    });

    this.bindStaticEvent($('#statusBar'), 'click', function(evt) {
      evt.preventDefault();
      
      $(this).hide('slow');

      return false;
    });

      // Journal
    this.bindStaticEvent($('#userJournalsMore a'), 'click', function(evt) {
      evt.preventDefault();
      
      var element = $(this);
      var toggleLoader = function(el, visible){
        var parent = el.parent();
        if (visible)
        {
          parent.children('a').hide();
          parent.children('.loader').show();
        }
        else
        {
          parent.children('a').show();
          parent.children('.loader').hide();
        }
      };

      toggleLoader(element, true);

      RucksackHelpers.get("/journals",
        {'from': $('#userJournalsMore').attr('from')},
        function(data) {
          toggleLoader(element, false);
          pageController.ResetAndRebind(data);
        }
      );

      return false;
    });

    // Page sidebar
    this.bindStaticEvent($('.addPageLink a'), 'click', function(evt) {
      evt.preventDefault();
      
      var newPage = $(evt.target.parentNode);
      var addPageInner = newPage.parents('.addPage').first().find('.inner').first();

      addPageInner.show();
      addPageInner.autofocus();
      newPage.hide();

      return false;
    });

    this.bindStaticEvent($('.addPage form'), 'submit', function(evt) {
      evt.preventDefault();
      
      var el = $(this);
      var submit_button = el.find('.submit').first();
      var root = el.parents('.addPage').first();
      var newPage = root.find('.addPageLink').first();
      var addPageInner = root.find('.inner').first();

      // Loader
      var old_submit = submit_button.html();
      pageController.setFormLoading(el, true);

      RucksackHelpers.request($(this), function(data){
        addPageInner.hide(); 
        newPage.show();
        pageController.setFormLoading(el, false);
        pageController.ResetAndRebind(data);
      });

      return false;
    });

    this.bindStaticEvent($('.addPage form .cancel'), 'click', function(evt) {
      evt.preventDefault();
      
      var root = $(evt.target.parentNode).parents('.addPage').first();
      var newPage = root.find('.addPageLink').first();
      var addPageInner = root.find('.inner').first();

      addPageInner.hide();
      newPage.show();

      return false;
    });
  }

  rebind () {
    this.clearDynamicEvents();
    this.bindDynamic();
  }

  setFavourite(favourite) {
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
  }

  insertWidget(resource) {
    if (this.READONLY)
      return;

        // Insert
    RucksackHelpers.post('/pages/' + this.ID + '/' + resource, 
      {'position': {'slot': $(this.insert_element).attr('slot') , 
       'before': (this.insert_before ? '1' : '0')}
      }, this.ResetAndRebind.bind(this));
  }

  dropSlotFunction (ev, ui) {
    // Add all of the wrapped elements
    if (this.isSortingWrappedElements) {
      var page_id = $(this).attr('page_id');
      ui.draggable.children(":last").children().each(function() {
        this.moveSlotTo($(this).attr('slot'), page_id);
      });
    }
    this.moveSlotTo(ui.draggable.attr('slot'), $(this).attr('page_id'));
  }

  makePageItemsSortable() {

        // Add droppables
    $('#stdPageListItems li').each(function(i) {
      var el = $(this);
      if (!el.hasClass('current'))
      {
            //el.droppable('destroy');
        el.droppable({ hoverClass:'hover', accept:'.pageSlot', tolerance: 'pointer', drop:this.dropSlotFunction});
      }
    });

    $('#usrPageListItems li').each(function(i) {
      var el = $(this);
      if (!el.hasClass('current'))
      {
        el.droppable({ hoverClass:'hover', accept:'.pageSlot', tolerance: 'pointer', drop:this.dropSlotFunction});
      }
    });

    // Make sidebar sortable
    if ($('#usrPageListItems').data('sortable'))
    {
      $('#usrPageListItems').sortable('destroy');
    }

    $('#usrPageListItems').sortable({
      axis: 'y',
      handle: '.usr_page_handle',
      items: '> .sidebar_page',
      opacity: 0.75,
      update(e, ui)
      {
        RucksackHelpers.post('/pages/reorder_sidebar', $('#usrPageListItems').sortable('serialize', {key: 'page_ids[]'}));
      }
    });
  }

  makePageSlotsSortable() {
    var slots = [...$('#slots')];
    var lists = [...$('.pageList .openItems .listItems')];
    var pageController = this;

    //slots = slots.concat(lists);

    //el.droppable({ hoverClass:'hover', accept:'.pageSlot', tolerance: 'pointer', drop:this.dropSlotFunction});

    $('#stdPageListItems li').each(function(i, el) {
      if (!el.classList.contains('current'))
      {
        slots.push(el);
      }
    });

    $('#usrPageListItems li').each(function(i, el) {
      if (!el.classList.contains('current'))
      {
        slots.push(el);
      }
    });

    // Clear out old slots
    if (this.listItemSortables != null)
    {
      this.listItemSortables.forEach((el) => {
        el.destroy();
      });
    }

    // Clear out old slots
    if (this.slotItemSortables != null)
    {
      this.slotItemSortables.forEach((el) => {
        el.destroy();
      });
    }

    this.listItemSortables =  [];
    this.slotItemSortables =  [];

    var slotItems = this.slotItemSortables;
    var listItems = this.listItemSortables;

    var cloneNoHandle = function(evt) {
      var origEl = evt.item;
      var cloneEl = evt.clone;
      var tagToRemove = origEl.querySelector('.pageSlotHandle'); // Select the tag you want to remove

      // Make sure tag is off
      if (tagToRemove) {
        tagToRemove.classList.add('hidden');
      }
    };

    var startNoHandle = (event) => {
      this.hoverHandle.enabled = false;
    }

    var endListItemNoHandle = (event) => {
      this.hoverHandle.enabled = true;

      if (event.to.classList.contains('listItems'))
      {
        if (event.from == event.to)
        {
          var itemID = event.item.getAttribute('item_id');
          var listID = event.to.getAttribute('list_id');
          pageController.reorderList(listID);
        }
        else
        {
          var itemID = event.item.getAttribute('item_id');
          var listID = event.to.getAttribute('list_id');
          pageController.moveListItemTo(itemID, listID);
        }
      }
    }

    var endSlotNoHandle = (event) => {
      this.hoverHandle.enabled = true;

      if (event.to.classList.contains('sidebar_page'))
      {
        var toSlotID = event.item.getAttribute('slot');
        var toPageID = event.to.getAttribute('page_id');
        pageController.moveSlotTo(toSlotID, toPageID);
        $(event.item).remove();
      }
      else if (event.to.classList.contains('pageSlots'))
      {
        pageController.reorderPage();
      }
    }

    slots.forEach((slot) => {
      slotItems.push(new Sortable(slot, {
            draggable: ".pageSlot",
            handle: '.slot_handle',
            group: 'pageSlots',
            mirror: false,
            onClone: cloneNoHandle,
            onStart: startNoHandle,
            onEnd: endSlotNoHandle
          }));
    });

    lists.forEach((slot) => {
      listItems.push(new Sortable(slot, {
            draggable: '.listItem',
            handle: '.slot_list_item_handle',
            group: 'listItems',
            mirror: false,
            onClone: cloneNoHandle,
            onStart: startNoHandle,
            onEnd: endListItemNoHandle
          }));
    });
  }

  makeSortable() {
    if (this.READONLY)
      return;

    this.makePageSlotsSortable();
  }

  reorderPage() {
      // Just reorder whole thing
      var new_order = [];
      [...$('.pageSlots').children()].forEach((el) => {
        if (el.classList.contains('draggable-mirror') || el.classList.contains('draggable--original'))
        {
          return;
        }

        new_order.push(el.getAttribute('slot'));
      });

      RucksackHelpers.post('/pages/' + this.ID + '/reorder', 
                          {'slots': new_order});
  }

  reorderList(list_id) {
      // Just reorder whole thing
      var new_order = [];
      [...$('#list_' + list_id).find('.openItems .listItem')].forEach((el) => {
        if (el.classList.contains('draggable-mirror') || el.classList.contains('draggable--original'))
        {
          return;
        }

        new_order.push(el.getAttribute('item_id'));
      });

      RucksackHelpers.post('/pages/' + this.ID + '/lists/' + list_id + '/reorder', 
                          {'items': new_order});
  }

  moveListItemTo(item_id, target_list_id) {
    RucksackHelpers.put('/pages/' + this.ID + '/lists/' + target_list_id + '/transfer', 
                        {'list_item': {'id': item_id}});
  }

  moveSlotTo(slot_id, page_id) {
    if (page_id != '0' && page_id != 0)
    {
      RucksackHelpers.put('/pages/' + page_id + '/' + 'transfer', {'page_slot': {'id': slot_id } }, null);
    }
  }


  // Event handlers


  // Hover observer for HoverHandle
  handlePageHoverHandlerFunc(evt){
    if (!this.hoverHandle.enabled)
      return;

    var el = $(evt.target);

    var hover = null;
    var handler = el.attr('hover_handle');
    if (handler)
      hover = $('#' + handler);
    else if (el.hasClass('innerHandle'))
      hover = el.parents('.pageSlotHandle')[0];

    if (hover)
      this.hoverHandle.setHandle(hover);
    else
      this.hoverHandle.clearHandle();
  }

  handlePageHoverHandlerCancelFunc(evt){
    this.hoverHandle.clearHandle();
  }

  // Hover observer for InsertionMarker
  handleInsertionMarkerFunc(evt){
    if (!this.insertionMarker.enabled)
      return;

    var el = $(evt.target);
    var pt = [evt.clientX, evt.clientY];
    pt.x = pt[0]; pt.y = pt[1];
    var offset = el.offset();

    if (!(pt.x - offset.left > this.MARGIN))
    {
      if (el.hasClass('pageSlot'))
      {
        var h = el.height(), thr = Math.min(h / 2, this.SLOT_VERGE);
        var t = offset.top, b = t + h;

        if (el.hasClass('pageFooter')) // before footer
          this.insertionMarker.show(el, true);
        else if (pt.y - t <= thr) // before element
          this.insertionMarker.show(el, true);
        else if (b - pt.y <= thr) // after element
          this.insertionMarker.show(el, false);
        else
           this.insertionMarker.hide(); // *poof*           
       }
     }
     else
     {
    // Handle offset when hovering over insert bar
      if (el.attr('id') == "cpi") 
      {
        if (!(pt.x - offset.left > (90+this.MARGIN)))
          return;
      }

      this.insertionMarker.hide(); // *poof*
    }
  }

  sel(selector) {
    return $(selector);
  }

  JustRebind(data) {
    this.rebind();
  }

  RebindAndHover(data) {
    this.rebind();
    this.hoverHandle.setEnabled(true);
  }

  ResetAndRebind(data) {
    // Clean up state
    if (this.TYPE == 'page')
    {
      this.insertionBar.hide();
      this.insertionBar.clearWidgetForm();
    }

    this.rebind();
  }
};

