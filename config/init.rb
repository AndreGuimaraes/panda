# Make the app's "gems" directory a place where gems are loaded from
Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")

# Make the app's "lib" directory a place where ruby files get "require"d from
$LOAD_PATH.unshift(Merb.root / "lib")


Merb::Config.use do |c|
  
  ### Sets up a custom session id key, if you want to piggyback sessions of other applications
  ### with the cookie session store. If not specified, defaults to '_session_id'.
  # c[:session_id_key] = '_session_id'
  
  c[:session_secret_key]  = '4d5e9b90d9e92c236a2300d718059aef3a9b9cbe'
  c[:session_store] = 'cookie'
end

use_orm :activerecord

dependencies 'merb_helpers', 'merb-mailer', 'uuid', 'to_simple_xml', 'rog'

# Not sure why dependencies won't load AWS::S3
require 'aws/s3'

Merb::BootLoader.after_app_loads do
  # Panda specific

  unless Merb.environment == "test"
    require File.join(Merb.root, '..', 'aws_connect')

    AWS::S3::Base.establish_connection!(
      :access_key_id     => ACCESS_KEY_ID,
      :secret_access_key => SECRET_ACCESS_KEY
    )

    Rog.prefix = "HQ"
    Rog.host = PANDA_LOG_SERVER
    Rog.port = 3333
    Rog.log :info, "Panda HQ app awake"
    
    Merb::Mailer.config = {
      :host=>'localhost',
      :domain => 'pandastream.com',
      :port=>'25'         
      # :user=>'',
      # :pass=>'',
      # :auth=>:plain # :plain, :login, :cram_md5, the default is no auth
    }
  end
end



EMAIL_SENDER = "Panda <info@pandastream.com>"