#==
# Copyright (C) 2008 James S Urquhart
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

class AlbumsController < ApplicationController
  before_filter :grab_page
  before_filter :load_album, :except => [:index, :new, :create]
  
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy, :transfer, :reorder]
  
  # GET /albums
  # GET /albums.xml
  def index
    @albums = @page.albums.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @albums }
    end
  end

  # GET /albums/1
  # GET /albums/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.xml  { render :xml => @album }
    end
  end

  # GET /albums/new
  # GET /albums/new.xml
  def new
    return error_status(true, :cannot_create_album) unless (Album.can_be_created_by(@logged_user, @page))
    
    @album = @page.albums.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @album }
    end
  end

  # GET /albums/1/edit
  def edit
    return error_status(true, :cannot_edit_album) unless (@album.can_be_edited_by(@logged_user))
  end

  # POST /albums
  # POST /albums.xml
  def create
    return error_status(true, :cannot_create_album) unless (Album.can_be_created_by(@logged_user, @page))
    
    calculate_position
    
    # Make the darn note
    @album = @page.albums.build(params[:album])
    @album.created_by = @logged_user
    @album.title ||= t('album')
    saved = @album.save
    
    # And the slot, don't forget the slot
    if saved
      save_slot(@album)
      @new_album = true
    end

    respond_to do |format|
      if @album.save
        flash[:notice] = 'Album was successfully created.'
        format.html { redirect_to(@album) }
        format.js {}
        format.xml  { render :xml => @album, :status => :created, :location => page_album_path(:page_id => @page.id, :id => @album.id) }
      else
        format.html { render :action => "new" }
        format.js {}
        format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /albums/1
  # PUT /albums/1.xml
  def update
    return error_status(true, :cannot_edit_album) unless (@album.can_be_edited_by(@logged_user))
    
    @album.updated_by = @logged_user

    respond_to do |format|
      if @album.update_attributes(params[:album])
        flash[:notice] = 'Album was successfully updated.'
        format.html { redirect_to(@album) }
        format.js {}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js {}
        format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /albums/1
  # DELETE /albums/1.xml
  def destroy
    return error_status(true, :cannot_delete_album) unless (@album.can_be_deleted_by(@logged_user))
    
    @slot_id = @album.page_slot.id
    @album.page_slot.destroy
    @album.updated_by = @logged_user
    @album.destroy

    respond_to do |format|
      format.html { redirect_to(albums_url) }
      format.js {}
      format.xml  { head :ok }
    end
  end
  
  # PUT /albums/1/transfer
  def transfer
    @item = AlbumPicture.find(params[:picture][:id])
    
    return error_status(true, :insufficient_permissions) unless (@album.can_be_edited_by(@logged_user) and @item.can_be_edited_by(@logged_user))
    
    @item.album = @album
    @item.save

    respond_to do |format|
      format.html { head :ok }
      format.js { head :ok }
      format.xml  { head :ok }
    end
  end
  
  # POST /albums/1/reorder
  def reorder
    return error_status(true, :cannot_edit_album) unless (@album.can_be_edited_by(@logged_user))
    
    order = params[:pictures].collect { |id| id.to_i }
    
    @album.album_items.each do |item|
      idx = order.index(item.id)
      item.position = idx
      item.position ||= @album.album_items.length
      item.save!
    end
    
    respond_to do |format|
      format.html { head :ok }
      format.json { head :ok }
      format.xml  { head :ok }
    end
  end
  
protected

  def load_album
    begin
      @album = @page.albums.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      error_status(true, :cannot_find_album)
      return false
    end
  end
  
end
