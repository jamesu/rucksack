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

class AlbumPicturesController < ApplicationController
  before_filter :grab_page
  before_filter :grab_album
  
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]
  
  # GET /album_pictures
  # GET /album_pictures.xml
  def index
    @album_pictures = @album.pictures.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @album_pictures }
    end
  end

  # GET /album_pictures/1
  # GET /album_pictures/1.xml
  def show
    @album_picture = @album.pictures.find(params[:id])
    @new_picture = !params[:is_new].nil?
    
    if !@new_picture
      el_id = @album.pictures.find(:first, 
                                   :conditions => ['position < ?', @album_picture.position], 
                                   :select => 'id', 
                                   :order => 'position DESC')
      @insert_element = "album_picture_#{el_id}" unless el_id.nil?
    
    elsif params[:el_id]
      @insert_element = params[:el_id]
    end
    
    @insert_element ||= 'album_picture_form'

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.xml  { render :xml => @album_picture }
    end
  end

  # GET /album_pictures/new
  # GET /album_pictures/new.xml
  def new
    return error_status(true, :cannot_create_albumpicture) unless (AlbumPicture.can_be_created_by(@logged_user, @album))
    
    @album_picture = @album.pictures.build
    @picture = @album_picture

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @album_picture }
    end
  end

  # GET /album_pictures/1/edit
  def edit
    @album_picture = @album.pictures.find(params[:id])
    @picture = @album_picture
    return error_status(true, :cannot_edit_albumpicture) unless (@album_picture.can_be_edited_by(@logged_user))
  end

  # POST /album_pictures
  # POST /album_pictures.xml
  def create
    return error_status(true, :cannot_create_albumpicture) unless (AlbumPicture.can_be_created_by(@logged_user, @album))
    
    @album_picture = @album.pictures.build(params[:picture])
    @album_picture.created_by = @logged_user

    respond_to do |format|
      if @album_picture.save
        flash[:notice] = 'AlbumPicture was successfully created.'
        format.html { redirect_to(@album.page) }
        format.js { render :action => 'create', :content_type => 'text/html'}
        format.xml  { render :xml => @album_picture, :status => :created, :location => page_album_album_picture_path(:page_id => @page.id, :album_id => @album.id, :id => @album_picture.id) }
      else
        format.html { render :action => "new" }
        format.js
        format.xml  { render :xml => @album_picture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /album_pictures/1
  # PUT /album_pictures/1.xml
  def update
    @album_picture = @album.pictures.find(params[:id])
    return error_status(true, :cannot_edit_albumpicture) unless (@album_picture.can_be_edited_by(@logged_user))
    
    @album_picture.updated_by = @logged_user

    respond_to do |format|
      if @album_picture.update_attributes(params[:picture])
        flash[:notice] = 'AlbumPicture was successfully updated.'
        format.html { redirect_to(@album.page) }
        format.js  { render :action => 'update', :content_type => 'text/html'}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js
        format.xml  { render :xml => @album_picture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /album_pictures/1
  # DELETE /album_pictures/1.xml
  def destroy
    @album_picture = @album.pictures.find(params[:id])
    return error_status(true, :cannot_edit_albumpicture) unless (@album_picture.can_be_deleted_by(@logged_user))
    
    @album_picture.updated_by = @logged_user
    @album_picture.destroy

    respond_to do |format|
      format.html { redirect_to(album_pictures_url) }
      format.js
      format.xml  { head :ok }
    end
  end

protected

  def grab_album
    begin
      @album = @page.albums.find(params[:album_id])
    rescue ActiveRecord::RecordNotFound
      error_status(true, :cannot_find_album)
      return false
    end
    
    true
  end
end
