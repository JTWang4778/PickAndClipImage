

Pod::Spec.new do |spec|

  
  spec.name         = "ImagePickAndClip"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of ImagePickAndClip."

  spec.homepage     = "https://github.com/JTWang4778/PickAndClipImage"
  
  spec.license      = "MIT"
  
  spec.author       = { "wangjintao" => "wangjintao@huatu.com" }
  
  spec.source       = { :git => "https://github.com/JTWang4778/PickAndClipImage.git", :tag => "#{spec.version}" }


  
  spec.source_files  = "ImagePickAndClip", "ImagePickAndClip/**/*.{h,m}"

 
  spec.requires_arc = true


end
