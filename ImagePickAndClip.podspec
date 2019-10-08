

Pod::Spec.new do |spec|

  
  spec.name         = "ImagePickAndClip"
  spec.version      = "0.0.2"
  spec.summary      = "select and clip UIImage on iOS"

  spec.homepage     = "https://github.com/JTWang4778/PickAndClipImage"
  
  spec.license      = "MIT"
  
  spec.author       = { "wangjintao" => "wangjintao@huatu.com" }
  
  spec.source       = { :git => "https://github.com/JTWang4778/PickAndClipImage.git", :tag => "#{spec.version}" }


  
  spec.source_files  = "ImagePickAndClip/ImagePickAndClip/HTClipImageController.h", "ImagePickAndClip/ImagePickAndClip/HTClipImageController.m"

 
  spec.requires_arc = true


end
