#==
# Copyright (C) 2008-2023 James S Urquhart
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#++

class NotesController < ApplicationController
  before_action :grab_page
  before_action :load_note, except: [:index, :new, :create]
   
  protect_from_forgery except: [:index, :show, :new, :edit]

  # GET /notes
  # GET /notes.xml
  def index
    @notes = @page.notes.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notes }
    end
  end

  # GET /notes/1
  # GET /notes/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @note }
    end
  end

  # GET /notes/new
  # GET /notes/new.xml
  def new
    return error_status(true, :cannot_create_note) unless (Note.can_be_created_by(@logged_user, @page))
    
    @note = @page.notes.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @note }
    end
  end

  # GET /notes/1/edit
  def edit
    return error_status(true, :cannot_edit_note) unless (@note.can_be_edited_by(@logged_user))

    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /notes
  # POST /notes.xml
  def create
    return error_status(true, :cannot_create_note) unless (Note.can_be_created_by(@logged_user, @page))
    
    calculate_position
    
    # Make the darn note
    @note = @page.notes.build(note_params)
    @note.created_by = @logged_user
    saved = @note.save
    
    # And the slot, don't forget the slot
    save_slot(@note) if saved
    
    respond_to do |format|
      if saved
        error_status(false, :success_note_created)
        format.html { redirect_to(@note) }
        format.js {}
        format.json { render json: @note, status: :created, location: page_note_path(page_id: @page.id, id: @note.id) }
      else
        format.html { render action: "new" }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /notes/1
  # PUT /notes/1.xml
  def update
    return error_status(true, :cannot_edit_note) unless (@note.can_be_edited_by(@logged_user))
    
    @note.updated_by = @logged_user

    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to(@note) }
        format.js {}
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.js {}
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    return error_status(true, :cannot_delete_note) unless (@note.can_be_deleted_by(@logged_user))
    
    @slot_id = @note.page_slot.id
    @note.page_slot.destroy
    @note.updated_by = @logged_user
    @note.destroy

    respond_to do |format|
      format.html { redirect_to(notes_url) }
      format.js {}
      format.json { head :ok }
    end
  end

protected

  def note_params
    params.fetch(:note, {}).permit(:title, :rich_content, :content, :show_date)
  end
  
  def load_note
    begin
      @note = @page.notes.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      error_status(true, :cannot_find_note)
      return false
    end
  end

end
