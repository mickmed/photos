class PhotosController < ApplicationController
  before_action :authenticate, except: [:index, :show]
  impressionist :actions=>[:index, :show]
  # impressionist :actions=>[:index, :show], :unique => [:session_hash, :impressionable_id]
  

  def index
    @category = params[:category] 
    @cat_names = Category.pluck(:name)
    
      # render :text => @cat_names       
    if @category == 'favorites'
      favorites
      @photo_flick = photo_flick_favorites
    end        
    
    if @category == 'newest'
      newest
      @photo_flick = photo_flick_newest
    end
    
    if @category !=  'favorites' && params[:category] != 'newest'
      photo_category
      @photo_flick = photo_flick_category
    end
    
    if request.xhr?
      
    end
     
    # @slider_photos = @photos
    # @og = @photos.shuffle[1]
    # @og_image = @og.picture
    # @og_title = @og.title
    # @og_message = Message.all.shuffle[1].message
    # @about = Message.find(1).message
    session[:photo_flick] = @photo_flick
    session[:category] = @category
    # session[:current_page] = @photos.current_page
    # ahoy.track "Home Views", title: "Home page viewed"
    # @home_views = Ahoy::Event.where(name: "Home Views").count
  end


  def show
  #  render plain: @photos.inspect
    @photo = Photo.find(params[:id]) 
    
    # @next = @photo.id + 1
    # @next = Photo.find(params[:@next])
    # render plain: @next
    @photos = session[:photo_flick]
    @category = session[:category]
    @count = Impression.where("action_name = 'index'").count
    flicker
    
    
   




    @photos.each_with_index do |photo, index|
      
      if @photo.id == photo["id"]
        
          @index = index.to_i
        
      end
    end

    


      @next = @photos[(@index)+1]
     
      @prev = @photos[(@index)-1]
      

    if (@next == NIL) 
      @next = @photos[@index[0]]
     
    end
    

   
   
    
    # @i = @photos.index(@photo)
    # @i = @i.to_i
    # @from_id = @photos[@i..-1]
    # @i = @i-1

    # @to_id = @photos[0..@i]
    # @i = @i+2

    # @slider_photos = @from_id + @to_id
    
    # @current_page = session[:current_page]
    # @og_title = @photo.description
    # @og_image = @photo.picture.url
  end
  
  def new
    @photo = Photo.new
    @categories = Category.all
  end
  
  def create
    @photo_new = Photo.new(photo_params)
    if @photo_new.save
      flash[:info] = "saved"
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def edit
    @photo = Photo.find(params[:id])
  end
  
  def update
    @photo = Photo.find(params[:id])
    if @photo.update_attributes(photo_params)
      # Handle a successful update.
      flash[:success] = "Photo updated"
      redirect_to photo_path
    else
      render 'edit'
    end
  end
  
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    flash[:success] = "photo deleted"
    redirect_to root_path
  end
  
  
  private
  
  def photo_params
    params.require(:photo).permit(:title, :description, :picture, :date_taken, category_ids:[])
  end
  
  def authenticate
    @shoonga = authenticate_or_request_with_http_basic do |username, password|
        username == "we8vds" && password == "4vght"
    end
  end
  
  def newest
    @photos = Photo.all.includes(:categories).order('date_taken desc')
  end
  
  def favorites
    #@photos = Photo.all.joins(:impressions).group('photos.id').order('count(photos.id) desc').paginate(:page => params[:page], :per_page => 60) 
      @photos = Photo.all
      #@photos = Photo.select("photos.id, title, picture, count(impressions.impressionable_id) AS listens_count").joins("LEFT OUTER JOIN impressions ON impressions.impressionable_id = photos.id AND impressions.impressionable_type = 'Photo'").group("photos.id").order("listens_count DESC").paginate(:page => params[:page], :per_page => 8)
  end
  
  def photo_category
     @photos = Photo.where(categories: {name: params[:category]}).includes(:categories)
  end

  def photo_flick_favorites
    Photo.all.where.not(categories: {id: 1}).includes(:categories)
  end
  
  def photo_flick_newest
    Photo.all.includes(:categories).order('date_taken desc')
  end
  
  def photo_flick_category
     Photo.where(categories: {name: params[:category]}).includes(:categories)
  end
  

end
  def flicker
    @photos.each_with_index do |photo, index|
      
             "#{index}: #{photo['id']}"  
              
      
       end  
    # @photos.each_with_index do |(photo, key, value), index| 
    #     # "#{index}: #{key} => #{value}" + photo.id.to_s 
    #     "#{index}: #{key} => #{value}"  
    #     "hi there"


    #     #IF SELECTED PHOTO ID MATCHES ID OF PHOTO IN ARRAY @PHOTOS
    #     #  if @photo.id == photo.id 
    #     #      @hey = "#{index}: #{key} => #{value}" + photo.id.to_s
    #     #      #THEN SET @INDEX TO THE THE NEXT INDEX IN THE ARRAY 
    #     #      @index = index
    #     #      @indexnext = index + 1
             
    #     #  end 


    #     #  #SELECT NEXT IN ARRAY
    #     #  if index == @indexnext 
    #     #      @photonext = photo.id 
    #     #  end 
        
    #     #  if !Photo.exists?(@photonext) 
    #     #      @photonext = @photo.id
    #     #  end
    # end 
    
    
    
    # @photos.reverse.each_with_index do |(photo, key, value), index| 
    #       "#{index}: #{key} => #{value}" + photo.id.to_s 
    #       #IF SELECTED PHOTO ID MATCHES ID OF PHOTO IN ARRAY @PHOTOS
    #        if @photo.id == photo.id 
    #            "#{index}: #{key} => #{value}" + photo.id.to_s
    #            #THEN SET @INDEX TO THE THE NEXT INDEX IN THE ARRAY 
    #            @indexback = index+1
    #        end 
    #        #SELECT NEXT IN ARRAY
    #        if index == @indexback 
    #            @photoback = photo.id 
    #        end 
    #        if !Photo.exists?(@photoback) 
    #            @photoback = @photo.id
    #        end
    #   end   
    
  end
