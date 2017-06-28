require 'yaml'
require 'webrick'
require 'deep_merge'

class Webash
    def self.show_sample_config
        matches = Gem::Specification.find_all_by_name 'webash'
        spec = matches.first
        filename = File.expand_path('examples/config.yaml.sample', spec.full_gem_path)
        puts "Please specify config file. Sample config file can be found at #{filename}"
    end

    def self.configure(config_file)
        begin
            if File.exists?(config_file)
                if File.file?(config_file)
                    puts "Loading #{config_file}"
                    @config = YAML::load(IO.read(config_file))
                else
                    config_file.chomp!("/")
                    @config = {}
                    Dir["#{config_file}/*.yaml"].each do |cfg|
                        puts "Loading #{cfg}"
                        @config.deep_merge! YAML::load(IO.read(cfg)) 
                    end
                end
            else
                puts "YAML configuration file couldn't be found at #{config_file}. Nothing to serve."
                exit
            end
        rescue Psych::SyntaxError
            puts "YAML configuration file at #{config_file} contains invalid syntax."
            exit
        end
    end

    def self.run(config_file)
        puts "Starting Webash"
        configure(config_file)
        @server = WEBrick::HTTPServer.new :Port => nil, :DoNotListen => true, Logger: WEBrick::Log.new("/dev/null")
        trap 'INT' do @server.shutdown end

        @config["listeners"].each do |listener, listener_config|
            puts "Listening on #{listener}"
            @server.listen("0.0.0.0", listener)
            vhost = WEBrick::HTTPServer.new :Port => listener, :DoNotListen => true, :ServerName => nil, Logger: WEBrick::Log.new("/dev/null")

            listener_config.each do |url_config|
                puts "Registering #{url_config["url"]} on #{listener}"
                vhost.mount_proc url_config["url"] do |req, res|
                    export_params = []
                    req.query.each do |key, value|
                        export_params.push("export #{key}=#{value}")
                    end
                    if export_params.any?
                        export_string = export_params.join(";") + ";"
                    else
                        export_string = ""
                    end
                    res.body = %x(#{export_string} #{url_config["command"]})
                    exit_code = $?.exitstatus
                    if url_config["exit_codes"]
                        http_code = url_config["exit_codes"].select do |http_status, codes| 
                            codes.include?(exit_code)
                        end.keys.first
                    else
                        http_code = nil
                    end

                    if http_code
                        res.status = http_code
                    else
                        if exit_code == 0
                            res.status = 200
                        else
                            res.status = 503
                        end
                    end
                end
            end

            @server.virtual_host vhost
        end
        @server.start
    end
end
