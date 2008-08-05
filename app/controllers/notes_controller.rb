class NotesController < ApplicationController
  before_filter :grab_page
  
  # GET /notes
  # GET /notes.xml
  def index
    @notes = @page.notes.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notes }
    end
  end

  # GET /notes/1
  # GET /notes/1.xml
  def show
    @note = @page.notes.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @note }
    end
  end

  # GET /notes/new
  # GET /notes/new.xml
  def new
    @note = @page.notes.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @note }
    end
  end

  # GET /notes/1/edit
  def edit
    @note = @page.notes.find(params[:id])

    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /notes
  # POST /notes.xml
  def create
    # Calculate target position
    # TODO: move to main controller as util function?
    if !params[:position].nil?
        pos = params[:position]
        insert_id = pos[:slot].to_i
        @insert_before = insert_id == 0 ? true : (pos[:before].to_i == 1)
    else
        insert_id = nil
        @insert_before = true
    end
    
    # Make the darn note
    @note = @page.notes.build(params[:note])
    saved = @note.save
    
    # And the slot, don't forget the slot
    if saved
        @slot = @page.new_slot_at(@note, insert_id, @insert_before)
        @insert_element = insert_id == 0 ? 'page_slot_footer' : "page_slot_#{insert_id}"
    end
    
    respond_to do |format|
      if saved
        error_status(false, :success_note_created)
        format.html { redirect_to(@note) }
        format.js {}
        format.xml  { render :xml => @note, :status => :created, :location => @note }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /notes/1
  # PUT /notes/1.xml
  def update
    @note = @page.notes.find(params[:id])

    respond_to do |format|
      if @note.update_attributes(params[:note])
        flash[:notice] = 'Note was successfully updated.'
        format.html { redirect_to(@note) }
        format.js {}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js {}
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    @note = @page.notes.find(params[:id])
    @slot_id = @note.page_slot.id
    @note.page_slot.destroy
    @note.destroy

    respond_to do |format|
      format.html { redirect_to(notes_url) }
      format.js {}
      format.xml  { head :ok }
    end
  end
end
