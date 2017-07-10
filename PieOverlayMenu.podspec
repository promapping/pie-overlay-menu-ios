Pod::Spec.new do |s|
    s.name         = "PieOverlayMenu"
    s.version      = "1.3.2"
    s.summary      = "Pie mapping fullscreen overlay menu"

    s.homepage     = "https://github.com/piemapping/pie-overlay-menu-ios"
    s.license      = { :type => "MIT", :file => "LICENSE" }

    s.author             = { "Anas AIT ALI" => "contact@aitali.co" }
    s.social_media_url   = "http://twitter.com/anasaitali"

    s.platform     = :ios, "8.0"
    s.requires_arc = true

    s.module_name  = 'PieOverlayMenu'
    s.source	 = { :git => "https://github.com/piemapping/pie-overlay-menu-ios.git", :tag => s.version.to_s }

    s.source_files = 'Source/*.swift'
    s.resource_bundle = { 'PieOverlayMenu' => 'Source/*.xcassets' }
end
