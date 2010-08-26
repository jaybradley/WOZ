require 'rubygems'
require 'sinatra'
require 'erb'
require 'builder'

get '/user_list' do
  builder do |xml|
    xml.instruct!
    xml.names do
      Dir.entries("public/photos/").each do | entry |
        if(entry != "." && entry != "..")
          xml.name entry
        end
      end
    end
  end
end

get '/photo_list/:user' do
  builder do |xml|
    xml.instruct!
    xml.photos do
      Dir.entries("public/photos/" + params[:user]).each do |entry|
        if(entry != "." && entry != "..")
          xml.photo_uri "photos/" + params[:user] + "/" + entry
        end
      end
    end
  end
end

get '/:user_or_wizard/:session_name/?' do
  
  # what interface was requested
  if params[:user_or_wizard] == "user"
    params["chat_swf_path"] = "../userInterface/PhotoPalWizardOfOzUserInterface.swf"
    params["ctm_path"] = "../userInterface/resources/crazyTalkModels/sydney535x600-90PercentImageQuality.ctm"
    params["ctm_path"] = "../" + params["ctm_path"] if request.fullpath.length == (request.fullpath.rindex('/') + 1) # does the path end with a slash?
  elsif params[:user_or_wizard] == "wizard"
    params["chat_swf_path"] = "../wizardInterface/PhotoPalWizardOfOzWizardInterface.swf"
  else
    return "Type of interface (" + params[:user_or_wizard] + ") not recognised. Enter an address such as http://..../photopalwoz/user/bob, http://...../photopalwoz/wizard/jim, http://...../photopalwoz/wizard/sally, etc..."
  end
  
  # photo viewer path
  params["photo_viewer_swf_path"] = "../photoViewer/PhotoPalPhotoViewer.swf"
  
  # does the path end with a slash?
  if request.fullpath.length == (request.fullpath.rindex('/') + 1)
    params["chat_swf_path"] = "../" + params["chat_swf_path"]
    params["photo_viewer_swf_path"] = "../" + params["photo_viewer_swf_path"]
  end
  
  # return the appropriate erb template
  if params[:user_or_wizard] == "user"
      erb :'userInterface/PhotoPalWizardOfOzUserInterface'
  elsif params[:user_or_wizard] == "wizard"
      erb :'wizardInterface/PhotoPalWizardOfOzWizardInterface'
  end
  
end

get '*' do
  "Invalid URI. Enter an address such as http://companions.napier.ac.uk/photopalwoz/user/bib, http://companions.napier.ac.uk/photopalwoz/wizard/jim, http://companions.napier.ac.uk/photopalwoz/wizard/sally, etc..."
end

